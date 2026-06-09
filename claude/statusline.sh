#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tok_used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
tok_max=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Format a token count compactly: 820 -> 820, 45234 -> 45.2k, 1000000 -> 1M.
# Whole values drop the decimal (177000 -> 177k). Mode "round" always does.
fmt_tokens() {
  awk -v n="$1" -v mode="$2" 'BEGIN {
    if (n >= 1000000)   { div=1000000; suf="M" }
    else if (n >= 1000) { div=1000;    suf="k" }
    else                { printf "%d", n; exit }
    v = n/div
    if (mode == "round" || v == int(v)) printf "%g%s", v, suf
    else                                printf "%.1f%s", v, suf
  }'
}

# Directory: basename of cwd
dir=$(basename "$cwd")

# Git branch from cwd (skip lock to avoid contention)
branch=""
branch_extra=""
if git --no-optional-locks -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git() { command git --no-optional-locks -C "$cwd" "$@"; }
  branch=$(git branch --show-current 2>/dev/null)

  # Dirty marker for tracked changes (staged or unstaged); untracked ignored
  if ! git diff --quiet --ignore-submodules 2>/dev/null \
     || ! git diff --cached --quiet --ignore-submodules 2>/dev/null; then
    branch_extra="*"
  fi

  # Ahead/behind vs upstream (left=behind, right=ahead); silent if no upstream
  ab=$(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
  if [ -n "$ab" ]; then
    behind=${ab%%[[:space:]]*}
    ahead=${ab##*[[:space:]]}
    [ "${ahead:-0}" -gt 0 ] && branch_extra="${branch_extra}↑${ahead}"
    [ "${behind:-0}" -gt 0 ] && branch_extra="${branch_extra}↓${behind}"
  fi
  unset -f git
fi

# Build parts
parts=()

# dir segment (cyan)
[ -n "$dir" ] && parts+=("$(printf '\033[36m%s\033[0m' "$dir")")

# git branch segment (magenta), with dirty + ahead/behind markers
[ -n "$branch" ] && parts+=("$(printf '\033[35m%s%s\033[0m' "$branch" "$branch_extra")")

# model segment (dim white), with effort level when present
if [ -n "$model" ]; then
  label="$model"
  [ -n "$effort" ] && label="$model ($effort)"
  parts+=("$(printf '\033[2m%s\033[0m' "$label")")
fi

# context usage segment: tokens + percentage (yellow)
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  if [ -n "$tok_used" ] && [ -n "$tok_max" ]; then
    seg=$(printf 'ctx:%s/%s (%s%%)' "$(fmt_tokens "$tok_used")" "$(fmt_tokens "$tok_max" round)" "$used_int")
  else
    seg=$(printf 'ctx:%s%%' "$used_int")
  fi
  parts+=("$(printf '\033[33m%s\033[0m' "$seg")")
fi

# Join with separator
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="$result $(printf '\033[2m|\033[0m') $part"
  fi
done

printf '%s' "$result"
