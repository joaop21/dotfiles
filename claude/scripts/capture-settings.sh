#!/usr/bin/env sh
# Capture Claude's live settings back into our tracked base file (SessionEnd).
#
# Two-way sync companion to merge-settings.sh: after each session, base mirrors
# whatever Claude wrote to the live file (new plugins, marketplaces, ...). Output
# is canonical (sorted keys) so Claude's key ordering doesn't churn git diffs.
# Guards never clobber base with missing/invalid data.
set -eu

BASE="${MERGE_SETTINGS_BASE:-${XDG_CONFIG_HOME:-$HOME/.config}/claude/settings.base.json}"
LIVE="${MERGE_SETTINGS_LIVE:-$HOME/.claude/settings.json}"

command -v jq >/dev/null 2>&1 || exit 0   # no jq → can't capture safely
[ -f "$LIVE" ] || exit 0                   # no live → nothing to capture

tmp="$(mktemp)"
if jq -S . "$LIVE" > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
  mv -f "$tmp" "$BASE"
else
  rm -f "$tmp"                             # invalid live JSON → leave base intact
fi
