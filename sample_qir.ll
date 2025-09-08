; ModuleID = 'sample_opt.ll'
source_filename = "./sample.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx11.0.0"

@.str.1 = private unnamed_addr constant [22 x i8] c"Measurement[%d] = %d\0A\00", align 1
@str = private unnamed_addr constant [29 x i8] c"=== Test quantum circuit ===\00", align 1
@__quantum__rt__result_one = external global ptr

; Function Attrs: nounwind ssp uwtable
define noundef i32 @main() local_unnamed_addr #0 {
  %1 = call ptr @__quantum__rt__qubit_allocate_array(i64 3) #4
  %2 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)
  %qe_ptr = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 0) #4
  %qbit = load ptr, ptr %qe_ptr, align 8
  call void @__quantum__qis__h__body(ptr %qbit) #4
  %tgt_qe = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 1) #4
  %tgt_q = load ptr, ptr %tgt_qe, align 8
  %controls_arr = call ptr @__quantum__rt__qubit_allocate_array(i64 1) #4
  %ctrl_elem = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %controls_arr, i64 0) #4
  %ctrl_src = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 0) #4
  %ctrl_q = load ptr, ptr %ctrl_src, align 8
  store ptr %ctrl_q, ptr %ctrl_elem, align 8
  call void @__quantum__qis__x__ctl(ptr %controls_arr, ptr %tgt_q) #4
  call void @__quantum__rt__qubit_release_array(ptr %controls_arr) #4
  %qe_ptr3 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 2) #4
  %qbit4 = load ptr, ptr %qe_ptr3, align 8
  call void @__quantum__qis__x__body(ptr %qbit4) #4
  %qe_ptr6 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 0) #4
  %qbit7 = load ptr, ptr %qe_ptr6, align 8
  %resptr = call ptr @__quantum__qis__mz__body(ptr %qbit7) #4
  %result_one = load ptr, ptr @__quantum__rt__result_one, align 8
  %isone = call i1 @__quantum__rt__result_equal(ptr %resptr, ptr %result_one) #4
  %m_i32 = zext i1 %isone to i32
  %3 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 0, i32 noundef %m_i32)
  %qe_ptr9 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 1) #4
  %qbit10 = load ptr, ptr %qe_ptr9, align 8
  %resptr11 = call ptr @__quantum__qis__mz__body(ptr %qbit10) #4
  %result_one12 = load ptr, ptr @__quantum__rt__result_one, align 8
  %isone13 = call i1 @__quantum__rt__result_equal(ptr %resptr11, ptr %result_one12) #4
  %m_i3214 = zext i1 %isone13 to i32
  %4 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 1, i32 noundef %m_i3214)
  %qe_ptr16 = call ptr @__quantum__rt__array_get_element_ptr_1d(ptr %1, i64 2) #4
  %qbit17 = load ptr, ptr %qe_ptr16, align 8
  %resptr18 = call ptr @__quantum__qis__mz__body(ptr %qbit17) #4
  %result_one19 = load ptr, ptr @__quantum__rt__result_one, align 8
  %isone20 = call i1 @__quantum__rt__result_equal(ptr %resptr18, ptr %result_one19) #4
  %m_i3221 = zext i1 %isone20 to i32
  %5 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 2, i32 noundef %m_i3221)
  ret i32 0
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #1

declare void @qc_h(ptr noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

declare void @qc_cnot(ptr noundef, i32 noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

declare void @qc_x(ptr noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

declare i32 @qc_measure(ptr noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr noundef readonly captures(none)) local_unnamed_addr #3

declare ptr @__quantum__rt__qubit_allocate_array(i64)

declare ptr @__quantum__rt__array_get_element_ptr_1d(ptr, i64)

declare void @__quantum__rt__qubit_release_array(ptr)

declare void @__quantum__qis__h__body(ptr)

declare void @__quantum__qis__x__body(ptr)

declare void @__quantum__qis__x__ctl(ptr, ptr)

declare ptr @__quantum__qis__mz__body(ptr)

declare i1 @__quantum__rt__result_equal(ptr, ptr)

attributes #0 = { nounwind ssp uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"clang version 21.1.0"}
