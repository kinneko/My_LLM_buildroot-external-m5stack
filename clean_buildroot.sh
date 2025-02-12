#!/bin/bash
#
# Module_LLM_buildroot と external_resources ディレクトリを削除
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of https://github.com/kinneko/My_LLM_buildroot-external-m5stack.
# Licensed under the GNU General Public License v3.0.
# See <https://www.gnu.org/licenses/gpl-3.0.html>.
# copyright (c) 2025 kinneko kinneko@gmail.com

# root 権限で実行されているか確認
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root. use sudo." >&2
    exit 1
fi

TARGETS=("Module_LLM_buildroot")

echo "=== Clean Buildroot Script ==="

for target in "${TARGETS[@]}"; do
    if [ -d "$target" ]; then
        echo "Removing '$target' directory..."
        rm -rf "$target"
        echo "Done."
    else
        echo "Directory '$target' does not exist. Nothing to remove."
    fi
done

echo "Clean Buildroot finished."

