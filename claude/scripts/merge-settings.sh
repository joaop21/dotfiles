#!/usr/bin/env sh
# Merge our managed Claude Code settings (base) into the live file Claude owns.
#
# Claude Code rewrites ~/.claude/settings.json at runtime (plugins, effort, ...),
# so we cannot symlink it. Instead we keep our managed config in settings.base.json
# and re-assert it into the live file on every SessionStart. base wins on conflicts;
# Claude's runtime additions (extra plugins/marketplaces) in live are preserved.
set -eu

BASE="${MERGE_SETTINGS_BASE:-${XDG_CONFIG_HOME:-$HOME/.config}/claude/settings.base.json}"
LIVE="${MERGE_SETTINGS_LIVE:-$HOME/.claude/settings.json}"

# Nothing to apply without a base — never break a session.
[ -f "$BASE" ] || exit 0

tmp="$(mktemp)"

if command -v jq >/dev/null 2>&1 && [ -f "$LIVE" ] && [ ! -L "$LIVE" ]; then
  # Recursive object merge; base (RHS) wins on conflicts, live extras survive.
  jq -s '.[0] * .[1]' "$LIVE" "$BASE" > "$tmp" || cp "$BASE" "$tmp"
else
  # No jq, or live missing / still a symlink → bootstrap from base.
  cp "$BASE" "$tmp"
fi

mv -f "$tmp" "$LIVE"
