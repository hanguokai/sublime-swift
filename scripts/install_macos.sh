#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$HOME/Library/Application Support/Sublime Text/Packages"
TARGET_LINK="$PACKAGES_DIR/Swift"

if [[ ! -d "$PACKAGES_DIR" ]]; then
    echo "错误: 未找到 Sublime Text Packages 目录: $PACKAGES_DIR"
    echo "请先确认已安装并至少启动过一次 Sublime Text。"
    exit 1
fi

if [[ -L "$TARGET_LINK" ]]; then
    CURRENT_SRC="$(readlink "$TARGET_LINK")"
    if [[ "$CURRENT_SRC" == "$REPO_DIR" ]]; then
        echo "已就绪: $TARGET_LINK 已经指向 $REPO_DIR"
        exit 0
    else
        echo "更新现有软链接: $TARGET_LINK -> $REPO_DIR (原指向: $CURRENT_SRC)"
        rm "$TARGET_LINK"
    fi
elif [[ -e "$TARGET_LINK" ]]; then
    BACKUP_PATH="${TARGET_LINK}.backup.$(date +%Y%m%d%H%M%S)"
    echo "发现已有同名目录，正在备份至: $BACKUP_PATH"
    mv "$TARGET_LINK" "$BACKUP_PATH"
fi

ln -s "$REPO_DIR" "$TARGET_LINK"
echo "安装成功! 已创建软链接:"
echo "  $TARGET_LINK -> $REPO_DIR"
