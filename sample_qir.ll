; ModuleID = 'sample.ll'
source_filename = "./sample.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx11.0.0"

@.str = private unnamed_addr constant [30 x i8] c"=== Test quantum circuit ===\0A\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"Measurement[%d] = %d\0A\00", align 1
@__quantum__rt__result_one = external global ptr

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main() #0 {
  %1 = call ptr @__quantum__rt__qubit_allocate_array(i64 3)
  %qubit_array_ptr = alloca ptr, align 8
  store ptr %1, ptr %qubit_array_ptr, align 8
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, ptr %2, align 4
  store i32 3, ptr %3, align 4
  store ptr null, ptr %4, align 8
  %7 = call i32 (ptr, ...) @printf(ptr noundef @.str)
  %8 = load ptr, ptr %4, align 8
  %9 = load i32, ptr %3, align 4
  %loaded_qubit_array = load ptr, ptr %qubit_array_ptr, align 8
  %qe_ptr_i8 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array, i64 0)
  %qbit = load ptr, ptr %qe_ptr_i8, align 8
  call void @__quantum__qis__h__body(ptr %qbit)
  %10 = load ptr, ptr %4, align 8
  %11 = load i32, ptr %3, align 4
  %loaded_qubit_array1 = load ptr, ptr %qubit_array_ptr, align 8
  %tgt_qe_i8 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array1, i64 1)
  %tgt_q = load ptr, ptr %tgt_qe_i8, align 8
  %controls_arr = call ptr @__quantum__rt__qubit_allocate_array(i64 1)
  %ctrl_elem_i8 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %controls_arr, i64 0)
  %ctrl_src_i8 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array1, i64 0)
  %ctrl_q = load ptr, ptr %ctrl_src_i8, align 8
  store ptr %ctrl_q, ptr %ctrl_elem_i8, align 8
  call void @__quantum__qis__x__ctl(ptr %controls_arr, ptr %tgt_q)
  %12 = load ptr, ptr %4, align 8
  %13 = load i32, ptr %3, align 4
  %loaded_qubit_array2 = load ptr, ptr %qubit_array_ptr, align 8
  %qe_ptr_i83 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array2, i64 2)
  %qbit4 = load ptr, ptr %qe_ptr_i83, align 8
  call void @__quantum__qis__x__body(ptr %qbit4)
  store i32 0, ptr %5, align 4
  br label %14

14:                                               ; preds = %25, %0
  %15 = load i32, ptr %5, align 4
  %16 = load i32, ptr %3, align 4
  %17 = icmp slt i32 %15, %16
  br i1 %17, label %18, label %28

18:                                               ; preds = %14
  %19 = load ptr, ptr %4, align 8
  %20 = load i32, ptr %3, align 4
  %21 = load i32, ptr %5, align 4
  %loaded_qubit_array5 = load ptr, ptr %qubit_array_ptr, align 8
  %idx_64 = sext i32 %21 to i64
  %qe_ptr_i86 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array5, i64 %idx_64)
  %qbit7 = load ptr, ptr %qe_ptr_i86, align 8
  %resptr = call ptr @__quantum__qis__mz__body(ptr %qbit7)
  %result_one = load ptr, ptr @__quantum__rt__result_one, align 8
  %isone = call i1 @__quantum__rt__result_equal(ptr %resptr, ptr %result_one)
  %m_i32 = zext i1 %isone to i32
  store i32 %m_i32, ptr %6, align 4
  %22 = load i32, ptr %5, align 4
  %23 = load i32, ptr %6, align 4
  %24 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %22, i32 noundef %23)
  br label %25

25:                                               ; preds = %18
  %26 = load i32, ptr %5, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, ptr %5, align 4
  br label %14, !llvm.loop !5

28:                                               ; preds = %14
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

declare void @qc_h(ptr noundef, i32 noundef, i32 noundef) #1

declare void @qc_cnot(ptr noundef, i32 noundef, i32 noundef, i32 noundef) #1

declare void @qc_x(ptr noundef, i32 noundef, i32 noundef) #1

declare i32 @qc_measure(ptr noundef, i32 noundef, i32 noundef) #1

declare ptr @__quantum__rt__qubit_allocate_array(i64)

declare ptr @__quantum__rt__array_get_element_ptr_1d(ptr, i64)

declare void @__quantum__qis__h__body(ptr)

declare void @__quantum__qis__x__body(ptr)

declare void @__quantum__qis__x__ctl(ptr, ptr)

declare ptr @__quantum__qis__mz__body(ptr)

declare i1 @__quantum__rt__result_equal(ptr, ptr)

attributes #0 = { noinline nounwind optnone ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"clang version 21.1.0"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
