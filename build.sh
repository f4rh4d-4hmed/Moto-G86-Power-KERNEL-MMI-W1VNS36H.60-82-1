#!/bin/bash
set -e

export ARCH=arm64
export LLVM=1
export CROSS_COMPILE=aarch64-linux-gnu-

echo "Installing dependencies..."
sudo apt install -y flex bison libssl-dev libelf-dev lld bc tar xz-utils cpio dwarves

echo "Setting up Clang..."
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b android14-release prebuilts/clang/host/linux-x86

export PATH="$(pwd)/prebuilts/clang/host/linux-x86/clang-r487747c/bin:$PATH"

echo "Building kernel..."
make gki_defconfig ARCH=arm64 LLVM=1
make -j$(nproc) ARCH=arm64 LLVM=1

echo "Done! Image: arch/arm64/boot/Image"
