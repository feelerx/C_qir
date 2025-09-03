; ModuleID = 'sample.ll'
source_filename = "./sample.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx11.0.0"

@.str = private unnamed_addr constant [38 x i8] c"=== Bell pair + extra gates test ===\0A\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"Measurement[%d] = %d\0A\00", align 1
@__quantum__rt__result_one = external global ptr

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main() #0 {
  %1 = call ptr @__quantum__rt__qubit_allocate_array(i64 4)
  %qubit_array_ptr = alloca ptr, align 8
  store ptr %1, ptr %qubit_array_ptr, align 8
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, ptr %2, align 4
  store i32 4, ptr %3, align 4
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
  %14 = load ptr, ptr %4, align 8
  %15 = load i32, ptr %3, align 4
  %loaded_qubit_array5 = load ptr, ptr %qubit_array_ptr, align 8
  %qe_ptr_i86 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array5, i64 3)
  %qbit7 = load ptr, ptr %qe_ptr_i86, align 8
  call void @__quantum__qis__h__body(ptr %qbit7)
  %16 = load ptr, ptr %4, align 8
  %17 = load i32, ptr %3, align 4
  %loaded_qubit_array8 = load ptr, ptr %qubit_array_ptr, align 8
  %tgt_qe_i89 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array8, i64 2)
  %tgt_q10 = load ptr, ptr %tgt_qe_i89, align 8
  %controls_arr11 = call ptr @__quantum__rt__qubit_allocate_array(i64 1)
  %ctrl_elem_i812 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %controls_arr11, i64 0)
  %ctrl_src_i813 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array8, i64 3)
  %ctrl_q14 = load ptr, ptr %ctrl_src_i813, align 8
  store ptr %ctrl_q14, ptr %ctrl_elem_i812, align 8
  call void @__quantum__qis__x__ctl(ptr %controls_arr11, ptr %tgt_q10)
  store i32 0, ptr %5, align 4
  br label %18

18:                                               ; preds = %29, %0
  %19 = load i32, ptr %5, align 4
  %20 = load i32, ptr %3, align 4
  %21 = icmp slt i32 %19, %20
  br i1 %21, label %22, label %32

22:                                               ; preds = %18
  %23 = load ptr, ptr %4, align 8
  %24 = load i32, ptr %3, align 4
  %25 = load i32, ptr %5, align 4
  %loaded_qubit_array15 = load ptr, ptr %qubit_array_ptr, align 8
  %idx_64 = sext i32 %25 to i64
  %qe_ptr_i816 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %loaded_qubit_array15, i64 %idx_64)
  %qbit17 = load ptr, ptr %qe_ptr_i816, align 8
  %resptr = call ptr @__quantum__qis__mz__body(ptr %qbit17)
  %result_one = load ptr, ptr @__quantum__rt__result_one, align 8
  %isone = call i1 @__quantum__rt__result_equal(ptr %resptr, ptr %result_one)
  %m_i32 = zext i1 %isone to i32
  store i32 %m_i32, ptr %6, align 4
  %26 = load i32, ptr %5, align 4
  %27 = load i32, ptr %6, align 4
  %28 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %26, i32 noundef %27)
  br label %29

29:                                               ; preds = %22
  %30 = load i32, ptr %5, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, ptr %5, align 4
  br label %18, !llvm.loop !5

32:                                               ; preds = %18
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
