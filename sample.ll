; ModuleID = './sample.c'
source_filename = "./sample.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx11.0.0"

@.str = private unnamed_addr constant [30 x i8] c"=== Test quantum circuit ===\0A\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"Measurement[%d] = %d\0A\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 3, ptr %2, align 4
  store ptr null, ptr %3, align 8
  %6 = call i32 (ptr, ...) @printf(ptr noundef @.str)
  %7 = load ptr, ptr %3, align 8
  %8 = load i32, ptr %2, align 4
  call void @qc_h(ptr noundef %7, i32 noundef %8, i32 noundef 0)
  %9 = load ptr, ptr %3, align 8
  %10 = load i32, ptr %2, align 4
  call void @qc_cnot(ptr noundef %9, i32 noundef %10, i32 noundef 0, i32 noundef 1)
  %11 = load ptr, ptr %3, align 8
  %12 = load i32, ptr %2, align 4
  call void @qc_x(ptr noundef %11, i32 noundef %12, i32 noundef 2)
  store i32 0, ptr %4, align 4
  br label %13

13:                                               ; preds = %25, %0
  %14 = load i32, ptr %4, align 4
  %15 = load i32, ptr %2, align 4
  %16 = icmp slt i32 %14, %15
  br i1 %16, label %17, label %28

17:                                               ; preds = %13
  %18 = load ptr, ptr %3, align 8
  %19 = load i32, ptr %2, align 4
  %20 = load i32, ptr %4, align 4
  %21 = call i32 @qc_measure(ptr noundef %18, i32 noundef %19, i32 noundef %20)
  store i32 %21, ptr %5, align 4
  %22 = load i32, ptr %4, align 4
  %23 = load i32, ptr %5, align 4
  %24 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %22, i32 noundef %23)
  br label %25

25:                                               ; preds = %17
  %26 = load i32, ptr %4, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, ptr %4, align 4
  br label %13, !llvm.loop !5

28:                                               ; preds = %13
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

declare void @qc_h(ptr noundef, i32 noundef, i32 noundef) #1

declare void @qc_cnot(ptr noundef, i32 noundef, i32 noundef, i32 noundef) #1

declare void @qc_x(ptr noundef, i32 noundef, i32 noundef) #1

declare i32 @qc_measure(ptr noundef, i32 noundef, i32 noundef) #1

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
