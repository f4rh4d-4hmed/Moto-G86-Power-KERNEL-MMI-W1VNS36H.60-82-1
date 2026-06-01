#!/bin/bash
set -e

# Grab choice from GitHub actions environment (fallback to 'none' if executed locally)
KSU_TYPE="${KSU_TYPE:-none}"

export ARCH=arm64
export LLVM=1
export CROSS_COMPILE=aarch64-linux-gnu-

echo "Setting up Clang..."
if [ ! -d "prebuilts/clang/host/linux-x86/clang-r487747c" ]; then
  echo "Cache miss: Cloning Clang toolchain..."
  rm -rf prebuilts/clang/host/linux-x86
  git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b android14-release prebuilts/clang/host/linux-x86
else
  echo "Cache hit: Using cached Clang toolchain."
fi

export PATH="$(pwd)/prebuilts/clang/host/linux-x86/clang-r487747c/bin:$PATH"

# Route KernelSU installation choices
if [ "$KSU_TYPE" = "ksu" ]; then
    echo "Integrating Official KernelSU..."
    curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
elif [ "$KSU_TYPE" = "ksunext" ]; then
    echo "Integrating KernelSU Next..."
    curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
else
    echo "Skipping KernelSU integration (Build type: Stock/None)."
fi

echo "Building kernel..."
make gki_defconfig ARCH=arm64 LLVM=1

# Tweak configurations depending on selected inputs
if [ "$KSU_TYPE" != "none" ]; then
    echo "Enabling KSU & Kprobes configuration flags..."
    scripts/config --file .config -e KSU
    scripts/config --file .config -e KPROBES
    scripts/config --file .config -e HAVE_KPROBES
    scripts/config --file .config -e KPROBE_EVENTS
fi

# Run the compilation step using ccache
make -j$(nproc) ARCH=arm64 LLVM=1 CC="ccache clang" HOSTCC="ccache clang"

echo "Done! Image generated at arch/arm64/boot/Image"
