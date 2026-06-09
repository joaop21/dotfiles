#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: basename of cwd
dir=$(basename "$cwd")

# Git branch from cwd (skip lock to avoid contention)
branch=""
if git --no-optional-locks -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
fi

# Build parts
parts=()

# dir segment (cyan)
[ -n "$dir" ] && parts+=("$(printf '\033[36m%s\033[0m' "$dir")")

# git branch segment (magenta)
[ -n "$branch" ] && parts+=("$(printf '\033[35m%s\033[0m' "$branch")")

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
