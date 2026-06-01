#!/bin/bash
set -e

export ARCH=arm64
export LLVM=1
export CROSS_COMPILE=aarch64-linux-gnu-


echo "Setting up Clang..."
# Only clone if the GitHub actions cache did not restore the directory
if [ ! -d "prebuilts/clang/host/linux-x86/clang-r487747c" ]; then
  echo "Cache miss: Cloning Clang toolchain..."
  rm -rf prebuilts/clang/host/linux-x86 # Avoid conflicts if a partial directory exists
  git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b android14-release prebuilts/clang/host/linux-x86
else
  echo "Cache hit: Using cached Clang toolchain."
fi

export PATH="$(pwd)/prebuilts/clang/host/linux-x86/clang-r487747c/bin:$PATH"

echo "Building kernel..."
make gki_defconfig ARCH=arm64 LLVM=1

# Intercept the compiler using ccache while respecting LLVM=1
make -j$(nproc) ARCH=arm64 LLVM=1 CC="ccache clang" HOSTCC="ccache clang"

echo "Done! Image: arch/arm64/boot/Image"
