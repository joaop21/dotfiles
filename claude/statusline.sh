#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

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

# model segment (dim white)
[ -n "$model" ] && parts+=("$(printf '\033[2m%s\033[0m' "$model")")

# context usage segment (yellow when > 0)
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  parts+=("$(printf '\033[33mctx:%s%%\033[0m' "$used_int")")
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
