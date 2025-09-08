#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"

using namespace llvm;

namespace {

class CToQIR : public PassInfoMixin<CToQIR> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &) {
    LLVMContext &Ctx = M.getContext();

    // === Types (LLVM 21 with Opaque Pointers) ===
    // In opaque pointer mode, all pointers are just 'ptr' - no pointee type
    Type *PtrTy = PointerType::get(Ctx, 0);  // Generic opaque pointer type

    Type *Int8Ty = Type::getInt8Ty(Ctx);
    Type *Int32Ty = Type::getInt32Ty(Ctx);
    Type *Int64Ty = Type::getInt64Ty(Ctx);
    Type *VoidTy = Type::getVoidTy(Ctx);
    Type *BoolTy = Type::getInt1Ty(Ctx);

    // === Runtime declarations (create if missing) ===

    // __quantum__rt__qubit_allocate_array(i64) -> ptr
    Function *fnAllocArr = M.getFunction("__quantum__rt__qubit_allocate_array");
    if (!fnAllocArr) {
      FunctionType *ft = FunctionType::get(PtrTy, {Int64Ty}, false);
      fnAllocArr = Function::Create(ft, Function::ExternalLinkage, "__quantum__rt__qubit_allocate_array", &M);
    }

    // __quantum__rt__array_get_element_ptr_1d(ptr, i64) -> ptr
    Function *fnArrayGetElem = M.getFunction("__quantum__rt__array_get_element_ptr_1d");
    if (!fnArrayGetElem) {
      FunctionType *ft = FunctionType::get(PtrTy, {PtrTy, Int64Ty}, false);
      fnArrayGetElem = Function::Create(ft, Function::ExternalLinkage, "__quantum__rt__array_get_element_ptr_1d", &M);
    }

    // __quantum__rt__qubit_release_array(ptr) -> void
    Function *fnReleaseArr = M.getFunction("__quantum__rt__qubit_release_array");
    if (!fnReleaseArr) {
      FunctionType *ft = FunctionType::get(VoidTy, {PtrTy}, false);
      fnReleaseArr = Function::Create(ft, Function::ExternalLinkage, "__quantum__rt__qubit_release_array", &M);
    }

    // QIS ops - all take ptr (opaque qubit pointer)
    Function *fnH = M.getFunction("__quantum__qis__h__body");
    if (!fnH) {
      FunctionType *ft = FunctionType::get(VoidTy, {PtrTy}, false);
      fnH = Function::Create(ft, Function::ExternalLinkage, "__quantum__qis__h__body", &M);
    }
    
    Function *fnX = M.getFunction("__quantum__qis__x__body");
    if (!fnX) {
      FunctionType *ft = FunctionType::get(VoidTy, {PtrTy}, false);
      fnX = Function::Create(ft, Function::ExternalLinkage, "__quantum__qis__x__body", &M);
    }
    
    // Controlled X: (ptr controls, ptr target)
    Function *fnXctl = M.getFunction("__quantum__qis__x__ctl");
    if (!fnXctl) {
      FunctionType *ft = FunctionType::get(VoidTy, {PtrTy, PtrTy}, false);
      fnXctl = Function::Create(ft, Function::ExternalLinkage, "__quantum__qis__x__ctl", &M);
    }

    // Measurement: mz(ptr) -> ptr
    Function *fnMz = M.getFunction("__quantum__qis__mz__body");
    if (!fnMz) {
      FunctionType *ft = FunctionType::get(PtrTy, {PtrTy}, false);
      fnMz = Function::Create(ft, Function::ExternalLinkage, "__quantum__qis__mz__body", &M);
    }

    // result_equal(ptr, ptr) -> i1
    Function *fnResultEqual = M.getFunction("__quantum__rt__result_equal");
    if (!fnResultEqual) {
      FunctionType *ft = FunctionType::get(BoolTy, {PtrTy, PtrTy}, false);
      fnResultEqual = Function::Create(ft, Function::ExternalLinkage, "__quantum__rt__result_equal", &M);
    }

    // External global: __quantum__rt__result_one (ptr)
    GlobalVariable *gResultOne = M.getGlobalVariable("__quantum__rt__result_one");
    if (!gResultOne) {
      gResultOne = new GlobalVariable(M, PtrTy, /*isConstant=*/false,
                                      GlobalValue::ExternalLinkage, /*Initializer=*/nullptr,
                                      "__quantum__rt__result_one");
    }

    bool Changed = false;

    // Walk all functions
    for (Function &F : M) {
      if (F.isDeclaration()) continue;

      SmallVector<CallInst *, 8> ToReplace;

      // collect qc_* calls
      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          if (CallInst *CI = dyn_cast<CallInst>(&I)) {
            if (Function *Callee = CI->getCalledFunction()) {
              StringRef name = Callee->getName();
              if (name == "qc_h" || name == "qc_x" || name == "qc_cnot" || name == "qc_measure") {
                ToReplace.push_back(CI);
              }
            }
          }
        }
      }
      if (ToReplace.empty()) continue;

      // Create entry builder and a place to store the allocated qubit array
      BasicBlock &EntryBB = F.getEntryBlock();
      IRBuilder<> EntryB(&*EntryBB.getFirstInsertionPt());

      // Improved num_qubits detection - analyze all qc_* calls to find maximum qubit index used
      Value *numQubitsI64 = ConstantInt::get(Int64Ty, 3); // Better default fallback
      
      // First try to find num_qubits from stores or loads
      for (BasicBlock &BB : F) {
        for (Instruction &I : BB) {
          if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
            if (ConstantInt *CI = dyn_cast<ConstantInt>(SI->getValueOperand())) {
              // Look for common patterns like "store i32 3, ptr %num_qubits"
              if (CI->getSExtValue() >= 2 && CI->getSExtValue() <= 32) {
                numQubitsI64 = ConstantInt::get(Int64Ty, CI->getSExtValue());
                break;
              }
            }
          }
        }
      }

      // If we still don't have a good value, analyze the qc_* calls for the second argument
      if (numQubitsI64 == ConstantInt::get(Int64Ty, 3)) { // Still using fallback
        CallInst *first = ToReplace.front();
        if (first->arg_size() >= 2) {
          Value *candidate = first->getArgOperand(1); // num_qubits operand
          if (ConstantInt *CI = dyn_cast<ConstantInt>(candidate)) {
            numQubitsI64 = ConstantInt::get(Int64Ty, CI->getSExtValue());
          } else if (isa<Argument>(candidate)) {
            // extend to i64 if needed
            if (candidate->getType()->isIntegerTy(32))
              numQubitsI64 = EntryB.CreateSExt(candidate, Int64Ty, "numq_entry_sext");
            else if (candidate->getType()->isIntegerTy(64))
              numQubitsI64 = candidate;
          } else if (LoadInst *LI = dyn_cast<LoadInst>(candidate)) {
            // Follow the load to find the source
            Value *ptr = LI->getPointerOperand();
            
            // Look for the store that initialized this value
            for (BasicBlock &SearchBB : F) {
              for (Instruction &SearchI : SearchBB) {
                if (StoreInst *SI = dyn_cast<StoreInst>(&SearchI)) {
                  if (SI->getPointerOperand() == ptr) {
                    if (ConstantInt *CI = dyn_cast<ConstantInt>(SI->getValueOperand())) {
                      numQubitsI64 = ConstantInt::get(Int64Ty, CI->getSExtValue());
                      goto found_numqubits;
                    }
                  }
                }
              }
            }
            found_numqubits:;
            
            // If we couldn't resolve it statically, create a runtime load
            if (numQubitsI64 == ConstantInt::get(Int64Ty, 3)) {
              if (isa<GlobalVariable>(ptr) || isa<Argument>(ptr)) {
                // Use CreateLoad with explicit type for opaque pointers
                LoadInst *entryLoad = EntryB.CreateLoad(LI->getType(), ptr, "numq_entry_load");
                if (entryLoad->getType()->isIntegerTy(32))
                  numQubitsI64 = EntryB.CreateSExt(entryLoad, Int64Ty, "numq_entry_sext");
                else if (entryLoad->getType()->isIntegerTy(64))
                  numQubitsI64 = entryLoad;
              }
            }
          }
        }
      }

      // Additional safety check: scan all qc_* calls to find maximum index used
      int64_t maxIdxSeen = 0;
      for (CallInst *call : ToReplace) {
        StringRef fname = call->getCalledFunction()->getName();
        if (fname == "qc_h" || fname == "qc_x" || fname == "qc_measure") {
          if (call->arg_size() >= 3) {
            if (ConstantInt *CI = dyn_cast<ConstantInt>(call->getArgOperand(2))) {
              maxIdxSeen = std::max(maxIdxSeen, CI->getSExtValue());
            }
          }
        } else if (fname == "qc_cnot") {
          if (call->arg_size() >= 4) {
            if (ConstantInt *CI = dyn_cast<ConstantInt>(call->getArgOperand(2))) {
              maxIdxSeen = std::max(maxIdxSeen, CI->getSExtValue());
            }
            if (ConstantInt *CI = dyn_cast<ConstantInt>(call->getArgOperand(3))) {
              maxIdxSeen = std::max(maxIdxSeen, CI->getSExtValue());
            }
          }
        }
      }
      
      // Ensure we allocate at least maxIdxSeen + 1 qubits
      if (ConstantInt *CurNum = dyn_cast<ConstantInt>(numQubitsI64)) {
        if (CurNum->getSExtValue() <= maxIdxSeen) {
          numQubitsI64 = ConstantInt::get(Int64Ty, maxIdxSeen + 1);
          errs() << "Warning: Adjusted qubit allocation to " << (maxIdxSeen + 1) 
                 << " based on maximum index " << maxIdxSeen << " found in code\n";
        }
      }

      // Allocate the runtime qubit array once at entry and store it in an alloca for later loads.
      CallInst *allocArrCall = EntryB.CreateCall(fnAllocArr, {numQubitsI64});
      allocArrCall->setCallingConv(CallingConv::C);
      
      // Create alloca for opaque pointer - specify the element type explicitly
      AllocaInst *qubitArrayAlloca = EntryB.CreateAlloca(PtrTy, nullptr, "qubit_array_ptr");
      EntryB.CreateStore(allocArrCall, qubitArrayAlloca);

      // Now transform each qc_* call
      for (CallInst *oldCall : ToReplace) {
        IRBuilder<> CB(oldCall);
        Function *calleef = oldCall->getCalledFunction();
        StringRef fname = calleef->getName();

        // load the Array* (qubit array) - specify element type for opaque pointer
        Value *arrPtr = CB.CreateLoad(PtrTy, qubitArrayAlloca, "loaded_qubit_array");

        // Helper: given an index value (i32 or i64) produce an i64 index
        auto makeIndex64 = [&](Value *idxVal) -> Value* {
          if (!idxVal) return ConstantInt::get(Int64Ty, 0);
          if (idxVal->getType()->isIntegerTy(64)) return idxVal;
          if (idxVal->getType()->isIntegerTy(32)) {
            return CB.CreateSExt(idxVal, Int64Ty, "idx_64");
          }
          // Unexpected: try implicit cast to 0
          return ConstantInt::get(Int64Ty, 0);
        };

        // For all single-qubit calls (qc_h, qc_x, qc_measure) we expect signature
        // qc_x(state, num_qubits, idx)
        // For qc_cnot we expect qc_cnot(state, num_qubits, ctrlIdx, targetIdx)

        if (fname == "qc_h" || fname == "qc_x" || fname == "qc_measure") {
          if (oldCall->arg_size() < 3) {
            errs() << "unexpected signature for " << fname << " : " << *oldCall << "\n";
            continue;
          }
          Value *idxV = oldCall->getArgOperand(2);
          Value *idx64 = makeIndex64(idxV);

          // get element pointer - returns ptr (opaque)
          Value *elemPtr = CB.CreateCall(fnArrayGetElem, {arrPtr, idx64}, "qe_ptr");
          
          // Load the qubit pointer from the array element
          // In QIR, array elements contain pointers to qubits
          Value *qptr = CB.CreateLoad(PtrTy, elemPtr, "qbit");

          if (fname == "qc_h") {
            CallInst *nc = CB.CreateCall(fnH, {qptr});
            nc->setCallingConv(CallingConv::C);
          } else if (fname == "qc_x") {
            CallInst *nc = CB.CreateCall(fnX, {qptr});
            nc->setCallingConv(CallingConv::C);
          } else { // qc_measure
            CallInst *resPtr = CB.CreateCall(fnMz, {qptr}, "resptr");
            resPtr->setCallingConv(CallingConv::C);

            // convert Result* -> i32 by comparing with __quantum__rt__result_one
            Value *gOne = CB.CreateLoad(PtrTy, gResultOne, "result_one");
            Value *isOne = CB.CreateCall(fnResultEqual, {resPtr, gOne}, "isone");
            // zext to i32
            Value *mi = CB.CreateZExt(isOne, Int32Ty, "m_i32");

            // replace uses of old call (if any) with mi (only if old call had uses)
            if (!oldCall->use_empty()) {
              // oldCall may be i32 in user code; replace uses with mi (zext to match)
              // oldCall might be returning i32 in the original C wrapper; assume that
              oldCall->replaceAllUsesWith(mi);
            }
          }
        } else if (fname == "qc_cnot") {
          // Expect qc_cnot(state, num_qubits, ctrlIdx, targetIdx)
          if (oldCall->arg_size() < 4) {
            errs() << "unexpected signature for qc_cnot: " << *oldCall << "\n";
            continue;
          }
          Value *ctrlIdxV = oldCall->getArgOperand(2);
          Value *tgtIdxV  = oldCall->getArgOperand(3);
          Value *ctrlIdx64 = makeIndex64(ctrlIdxV);
          Value *tgtIdx64  = makeIndex64(tgtIdxV);

          // Get target qubit pointer
          Value *tgtElem = CB.CreateCall(fnArrayGetElem, {arrPtr, tgtIdx64}, "tgt_qe");
          Value *tgtQubit = CB.CreateLoad(PtrTy, tgtElem, "tgt_q");

          // Build a 1-element controls array:
          Value *oneI64 = ConstantInt::get(Int64Ty, 1);
          CallInst *controlsArr = CB.CreateCall(fnAllocArr, {oneI64}, "controls_arr");
          controlsArr->setCallingConv(CallingConv::C);

          // get element ptr for controlsArr[0]
          Value *ctrlElemPtr = CB.CreateCall(fnArrayGetElem, {controlsArr, ConstantInt::get(Int64Ty, 0)}, "ctrl_elem");

          // get control qubit pointer value from main array
          Value *ctrlElemOrig = CB.CreateCall(fnArrayGetElem, {arrPtr, ctrlIdx64}, "ctrl_src");
          Value *ctrlQubit = CB.CreateLoad(PtrTy, ctrlElemOrig, "ctrl_q");

          // store control qubit into controlsArr[0]
          CB.CreateStore(ctrlQubit, ctrlElemPtr);

          // call controlled X with controlsArr and target qubit
          CallInst *nc = CB.CreateCall(fnXctl, {controlsArr, tgtQubit});
          nc->setCallingConv(CallingConv::C);

          // Clean up the temporary controls array (optional but good practice)
          CallInst *releaseControls = CB.CreateCall(fnReleaseArr, {controlsArr});
          releaseControls->setCallingConv(CallingConv::C);
        }

        // Erase the original call
        oldCall->eraseFromParent();
        Changed = true;
      } // end ToReplace
    } // end for each function

    return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  } // run
}; // class

} // namespace

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "CToQIRFixed", LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, ModulePassManager &MPM, ArrayRef<PassBuilder::PipelineElement>) {
          if (Name == "c-to-qir") {
            MPM.addPass(CToQIR());
            return true;
          }
          return false;
        }
      );
    }
  };
}