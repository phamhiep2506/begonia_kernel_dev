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

# Build kernel
sed -i 's/# CONFIG_KALLSYMS_ALL is not set/CONFIG_KALLSYMS_ALL=y/' arch/arm64/configs/begonia_user_defconfig
sed -i 's/# CONFIG_KALLSYMS_BASE_RELATIVE is not set/CONFIG_KALLSYMS_BASE_RELATIVE=y/' arch/arm64/configs/begonia_user_defconfig
make -j$(nproc --all) O=out begonia_user_defconfig
make -j$(nproc --all) O=out