#!/usr/bin/env sh

set -e

echo "🚀 Claude Code configuration"

mkdir -p "${HOME}/.claude"
ln -sfn "${XDG_CONFIG_HOME}/claude/rules" "${HOME}/.claude/rules"
ln -sfn "${XDG_CONFIG_HOME}/claude/agents" "${HOME}/.claude/agents"
ln -sfn "${XDG_CONFIG_HOME}/claude/skills" "${HOME}/.claude/skills"
ln -sfn "${XDG_CONFIG_HOME}/claude/commands" "${HOME}/.claude/commands"
ln -sfn "${XDG_CONFIG_HOME}/claude/scripts" "${HOME}/.claude/scripts"

# settings.json is NOT symlinked: Claude Code rewrites it at runtime, which would
# break the symlink. Instead our managed config lives in settings.base.json and is
# merged into the live file here and on every SessionStart (see merge-settings.sh).
"${XDG_CONFIG_HOME}/claude/scripts/merge-settings.sh"
