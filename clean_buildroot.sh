#!/bin/bash
#
# Module_LLM_buildroot と external_resources ディレクトリを削除
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of https://github.com/kinneko/My_LLM_buildroot-external-m5stack.
# Licensed under the GNU General Public License v3.0.
# See <https://www.gnu.org/licenses/gpl-3.0.html>.
# copyright (c) kinneko kinneko@gmail.com

TARGETS=("Module_LLM_buildroot" "external_resources")

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

