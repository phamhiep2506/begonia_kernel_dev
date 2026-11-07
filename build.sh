#!/bin/bash

# Download clang
if [ ! -d "$PWD/clang" ]; then
    if [ ! -f "$PWD/clang-r547379.tar.gz" ]; then
        curl -L "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz" -o $PWD/clang-r547379.tar.gz
    fi
    mkdir $PWD/clang
    tar -xzf $PWD/clang-r547379.tar.gz -C $PWD/clang
fi

# Export
export ARCH="arm64"
export CC="$PWD/clang/bin/clang"
export CROSS_COMPILE="$PWD/clang/bin/aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32="$PWD/clang/bin/arm-linux-gnueabi-"
export LD="$PWD/clang/bin/ld.lld"
export LLVM="1"
export LLVM_IAS="1"
export AR="$PWD/clang/bin/llvm-ar"
export NM="$PWD/clang/bin/llvm-nm"
export OBJCOPY="$PWD/clang/bin/llvm-objcopy"
export OBJDUMP="$PWD/clang/bin/llvm-objdump"
export READELF="$PWD/clang/bin/llvm-readelf"
export OBJSIZE="$PWD/clang/bin/llvm-size"
export STRIP="$PWD/clang/bin/llvm-strip"
export LDGOLD="$PWD/clang/bin/aarch64-linux-gnu-ld.gold"
export LLVM_AR="$PWD/clang/bin/llvm-ar"
export LLVM_DIS="$PWD/clang/bin/llvm-dis"
export PATH="$PWD/clang/bin:$PATH"

# Submodule update
git submodule init
git submodule update

# Patch susfs for ksu
if [ ! -f "$PWD/10_enable_susfs_for_ksu.patch" ]; then
    curl -L https://github.com/phamhiep2506/begonia_kernel_dev/releases/download/v1.0.0/10_enable_susfs_for_ksu.patch -o $PWD/10_enable_susfs_for_ksu.patch
fi
patch -d $PWD/KernelSU -R -p1 -N --dry-run --silent < $PWD/10_enable_susfs_for_ksu.patch > /dev/null 2>&1
PATCH_SUSFS_FOR_KSU_STATUS=$?
if [ $PATCH_SUSFS_FOR_KSU_STATUS -ne 0 ]; then
    patch -d $PWD/KernelSU -p1 < $PWD/10_enable_susfs_for_ksu.patch
fi

# Build kernel
make -j$(nproc --all) O=out begonia_user_defconfig
make -j$(nproc --all) O=out