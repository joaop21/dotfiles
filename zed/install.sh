#!/usr/bin/env sh

set -e

echo "🚀 Zed configuration"

mkdir -p "${HOME}/.config/zed/"
ln -sf "${XDG_CONFIG_HOME}/zed/settings.json" "${HOME}/.config/zed/settings.json"
ln -sf "${XDG_CONFIG_HOME}/zed/keybindings.json" "${HOME}/.config/zed/keymap.json"
ln -sf "${XDG_CONFIG_HOME}/zed/tasks.json" "${HOME}/.config/zed/tasks.json"
