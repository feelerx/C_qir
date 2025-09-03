; ModuleID = './sample.c'
source_filename = "./sample.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx11.0.0"

@.str = private unnamed_addr constant [38 x i8] c"=== Bell pair + extra gates test ===\0A\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"Measurement[%d] = %d\0A\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 4, ptr %2, align 4
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
  %13 = load ptr, ptr %3, align 8
  %14 = load i32, ptr %2, align 4
  call void @qc_h(ptr noundef %13, i32 noundef %14, i32 noundef 3)
  %15 = load ptr, ptr %3, align 8
  %16 = load i32, ptr %2, align 4
  call void @qc_cnot(ptr noundef %15, i32 noundef %16, i32 noundef 3, i32 noundef 2)
  store i32 0, ptr %4, align 4
  br label %17

17:                                               ; preds = %29, %0
  %18 = load i32, ptr %4, align 4
  %19 = load i32, ptr %2, align 4
  %20 = icmp slt i32 %18, %19
  br i1 %20, label %21, label %32

21:                                               ; preds = %17
  %22 = load ptr, ptr %3, align 8
  %23 = load i32, ptr %2, align 4
  %24 = load i32, ptr %4, align 4
  %25 = call i32 @qc_measure(ptr noundef %22, i32 noundef %23, i32 noundef %24)
  store i32 %25, ptr %5, align 4
  %26 = load i32, ptr %4, align 4
  %27 = load i32, ptr %5, align 4
  %28 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %26, i32 noundef %27)
  br label %29

29:                                               ; preds = %21
  %30 = load i32, ptr %4, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, ptr %4, align 4
  br label %17, !llvm.loop !5

32:                                               ; preds = %17
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
