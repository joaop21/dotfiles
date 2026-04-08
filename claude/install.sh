#!/usr/bin/env sh

set -e

echo "🚀 Claude Code configuration"

mkdir -p "${HOME}/.claude"
ln -sf "${XDG_CONFIG_HOME}/claude/settings.json" "${HOME}/.claude/settings.json"
ln -sf "${XDG_CONFIG_HOME}/claude/rules" "${HOME}/.claude/rules"
ln -sf "${XDG_CONFIG_HOME}/claude/agents" "${HOME}/.claude/agents"
ln -sf "${XDG_CONFIG_HOME}/claude/skills" "${HOME}/.claude/skills"
ln -sf "${XDG_CONFIG_HOME}/claude/commands" "${HOME}/.claude/commands"
