#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of https://github.com/kinneko/My_LLM_buildroot-external-m5stack.
# Licensed under the GNU General Public License v3.0.
# See <https://www.gnu.org/licenses/gpl-3.0.html>.
# copyright (c) kinneko kinneko@gmail.com

BUILD_DIR="Module_LLM_buildroot"
DEFCONFIG="m5stack_module_llm_4_19_defconfig"
CURRENTDIR=$(pwd)
EXT_DIR="${CURRENTDIR}external_resources"

BUILDROOT_FILE="buildroot-st2023.02.10.zip"
BUILDROOT_SRC="https://github.com/bootlin/buildroot/archive/refs/heads/st/2023.02.10.zip"
BUILDROOT_DIR="$BUILD_DIR/buildroot"

DL7Z_FILE="dl.7z"
DL7Z_SRC="https://m5stack.oss-cn-shenzhen.aliyuncs.com/resource/linux/llm/dl.7z"

RESET="\e[0m"  # リセット
REVERSE="\e[7m"  # 反転

# ログメッセージを出力する関数
recho() {
    printf "${REVERSE}>>> %s${RESET}\n" "$1"
}


# 共通関数: ファイルのダウンロード
download_file() {
    local filename="$1"
    local src_url="$2"
    local filepath="$EXT_DIR/$filename"

    # ファイルが存在するか確認
    if [ -f "$filepath" ]; then
        recho "Found existing file: $filepath"
    else
        recho "File not found: $filepath"
        recho "Downloading from $src_url..."
        if command -v curl &> /dev/null; then
            curl -L -s -o "$filepath" "$src_url"
        elif command -v wget &> /dev/null; then
            wget -q -O "$filepath" "$src_url"
        else
            recho "Error: wget or curl is required to download the file."
            exit 1
        fi
        recho "Download complete: $filename"
    fi
}

# 共通関数: ファイルの展開
extract_file() {
    local filename="$1"
    local dest_dir="$2"
    local extract_command="$3"
    # ファイルの展開
    recho "Extracting $filename..."
    eval "$extract_command"
    
    # 展開が成功したか確認
    if [ -d "$dest_dir" ]; then
        recho "Extraction complete: $dest_dir"
    else
        recho "Error: Extraction failed for $filename."
        exit 1
    fi
}

# 共通関数: ファイルのダウンロードと展開
download_and_extract() {
    local filename="$1"
    local src_url="$2"
    local dest_dir="$3"
    local extract_command="$4"

    local filepath="$EXT_DIR/$filename"

    # ファイルが存在するか確認
    if [ -f "$filepath" ]; then
        recho "Found existing file: $filepath"
    else
        recho "File not found: $filepath"
        recho "Downloading from $src_url..."
        if command -v curl &> /dev/null; then
            curl -L -s -o "$filepath" "$src_url"
        elif command -v wget &> /dev/null; then
            wget -q -O "$filepath" "$src_url"
        else
            recho "Error: wget or curl is required to download the file."
            exit 1
        fi
        recho "Download complete: $filename"
    fi

    # ファイルの展開
    recho "Extracting $filename..."
    eval "$extract_command"
    
    # 展開が成功したか確認
    if [ -d "$dest_dir" ]; then
        recho "Extraction complete: $dest_dir"
    else
        recho "Error: Extraction failed for $filename."
        exit 1
    fi
}

recho "Script Start !"
# 必要なディレクトリの作成
for dir in "$BUILD_DIR" "$EXT_DIR"; do
    if [ ! -d "$dir" ]; then
        recho "Creating pool directory: $dir"
        mkdir -p "$dir"
    else
        recho "Directory already exists: $dir"
    fi
done

# 依存パッケージのインストール
recho "Install packages..."
sudo apt-get install debianutils sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio unzip rsync file bc git cmake p7zip-full python3 python3-pip expect libssl-dev qemu-user-static zip simg2img android-sdk-libsparse-utils mtools e2fsprogs libpcre3 -y -qq

# Buildroot のダウンロードと展開
recho "Download and extract Buildroot"
if [ ! -d "$BUILDROOT_DIR" ]; then
    recho "Buildroot directory does not exist. Extracting..."
    download_and_extract "$BUILDROOT_FILE" "$BUILDROOT_SRC" "$BUILDROOT_DIR" \
        "unzip -o '$EXT_DIR/$BUILDROOT_FILE' -d '$BUILD_DIR' > /dev/null 2>&1 && mv '$BUILD_DIR/buildroot-st-2023.02.10' '$BUILDROOT_DIR'"
else
    recho "Buildroot directory already exists. Skipping extraction."
fi

# dl.7z のダウンロードと展開
recho "Download and extract some files"
if [ ! -d "$BUILDROOT_DIR/dl" ]; then
    recho "dl directory does not exist. Extracting..."
    download_and_extract "$DL7Z_FILE" "$DL7Z_SRC" "$BUILDROOT_DIR/dl" \
        "7z x '$EXT_DIR/$DL7Z_FILE' -o'$BUILDROOT_DIR/dl' -bsp0 -bse0 -aos"
else
    recho "dl directory already exists. Skipping extraction."
fi

# uboot のダウンロード
recho "Download uboot files"
UBOOT_FILE="120d25a7105454d381030fa4a24f9ab9267f36a2.tar.gz"
UBOOT_SRC="https://github.com/dianjixz/module_LLM_uboot/archive/120d25a7105454d381030fa4a24f9ab9267f36a2.tar.gz"
download_file "$UBOOT_FILE" "$UBOOT_SRC"

# Buildroot の実行
recho " "
recho "Buildroot start!"
recho " "
cd $BUILDROOT_DIR
#EXT_DIR="${CURRENTDIR}external_resources"
#BUILD_DIR="Module_LLM_buildroot"
#DEFCONFIG="m5stack_module_llm_4_19_defconfig"

make BR2_EXTERNAL="${CURRENTDIR}" "${DEFCONFIG}"
# ROOTFS_SIZEが設定されている場合に.configを上書き
if [ -n "$ROOTFS_SIZE" ]; then
    recho "Updating root filesystem size to ${ROOTFS_SIZE}"
    
    # .config内のBR2_TARGET_ROOTFS_EXT2_SIZEをROOTFS_SIZEに置き換え
    sed -i "s/^BR2_TARGET_ROOTFS_EXT2_SIZE=.*/BR2_TARGET_ROOTFS_EXT2_SIZE=\"${ROOTFS_SIZE}\"/" .config
    
    recho "Update complete: BR2_TARGET_ROOTFS_EXT2_SIZE=${ROOTFS_SIZE}"
else
    recho "ROOTFS_SIZE is not set. Skipping update."
fi
MAKEFLAGS="-j$(nproc)" make

recho " "
recho "Buildroot finished!"
recho " "
