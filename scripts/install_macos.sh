#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$HOME/Library/Application Support/Sublime Text/Packages"
TARGET_LINK="$PACKAGES_DIR/Swift"

if [[ ! -d "$PACKAGES_DIR" ]]; then
    echo "Error: Sublime Text Packages directory not found: $PACKAGES_DIR"
    echo "Please make sure Sublime Text is installed and has been launched at least once."
    exit 1
fi

if [[ -L "$TARGET_LINK" ]]; then
    CURRENT_SRC="$(readlink "$TARGET_LINK")"
    if [[ "$CURRENT_SRC" == "$REPO_DIR" ]]; then
        echo "Already installed: $TARGET_LINK -> $REPO_DIR"
        exit 0
    else
        echo "Updating existing symlink: $TARGET_LINK -> $REPO_DIR (was: $CURRENT_SRC)"
        rm "$TARGET_LINK"
    fi
elif [[ -e "$TARGET_LINK" ]]; then
    BACKUP_PATH="${TARGET_LINK}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Existing directory found, backing up to: $BACKUP_PATH"
    mv "$TARGET_LINK" "$BACKUP_PATH"
fi

ln -s "$REPO_DIR" "$TARGET_LINK"
echo "Installed successfully! Symlink created:"
echo "  $TARGET_LINK -> $REPO_DIR"
