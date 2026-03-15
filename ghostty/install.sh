#!/usr/bin/env sh

set -e

echo "🚀 Ghostty configuration"

mkdir -p "${HOME}/Library/Application Support/com.mitchellh.ghostty"
ln -sf "${XDG_CONFIG_HOME}/ghostty/config.ghostty" "${HOME}/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
