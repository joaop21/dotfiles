#!/usr/bin/env sh

set -e

echo "🚀 Claude Code configuration"

mkdir -p "${HOME}/.claude"
ln -sfn "${XDG_CONFIG_HOME}/claude/settings.json" "${HOME}/.claude/settings.json"
ln -sfn "${XDG_CONFIG_HOME}/claude/rules" "${HOME}/.claude/rules"
ln -sfn "${XDG_CONFIG_HOME}/claude/agents" "${HOME}/.claude/agents"
ln -sfn "${XDG_CONFIG_HOME}/claude/skills" "${HOME}/.claude/skills"
ln -sfn "${XDG_CONFIG_HOME}/claude/commands" "${HOME}/.claude/commands"
ln -sfn "${XDG_CONFIG_HOME}/claude/scripts" "${HOME}/.claude/scripts"
