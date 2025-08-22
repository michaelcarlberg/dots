#!/usr/bin/bash -ex

# echo TODO(jaagr):
# > integrate build environment into script so that it will be
# > possible to override our defaults without changing the build scripts

# -DCMAKE_C_COMPILER=clang
# -DCMAKE_CXX_COMPILER=clang++
# -DCMAKE_BUILD_TYPE="Release"
# -DCMAKE_INSTALL_PREFIX="/usr/local"
# -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

pushd "$1" # <1:working-dir>

if [ ! -d llvm-project ]; then
  git clone --depth 1 https://github.com/llvm/llvm-project.git
fi

pushd llvm-project # <2:project-dir>

# Build dir
mkdir -p build

cmake -G Ninja -S runtimes -B build \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_INSTALL_PREFIX="/usr/local" \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"

# Build
ninja -C build cxx cxxabi unwind
# Test
ninja -C build check-cxx check-cxxabi check-unwind
# Install
ninja -C build install-cxx install-cxxabi install-unwind

#
# install cetc etc
#

popd # <2:project-dir>
popd # <1:working-dir>
