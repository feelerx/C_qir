cmake_minimum_required(VERSION 3.10)
project(CToQIRPass)

find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_DIR}")
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})

add_library(CToQIRPass SHARED CToQIRPass.cpp)
target_compile_features(CToQIRPass PRIVATE cxx_std_17)
llvm_map_components_to_libnames(llvm_libs support core irreader passes)
target_link_libraries(CToQIRPass PRIVATE ${llvm_libs})