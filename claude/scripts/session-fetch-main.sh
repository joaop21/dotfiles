#!/usr/bin/env bash
set -e

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
default_branch=${default_branch:-main}

git fetch --quiet origin 2>/dev/null || exit 0

current=$(git branch --show-current 2>/dev/null)
current=${current:-"(detached)"}
behind=$(git rev-list --count "HEAD..origin/$default_branch" 2>/dev/null || echo "?")
ahead=$(git rev-list --count "origin/$default_branch..HEAD" 2>/dev/null || echo "?")

msg="Fetched origin. Branch '$current' is $behind commits behind and $ahead commits ahead of origin/$default_branch."

# Fast-forward only when nothing can be lost: a named branch, clean tree,
# no commits of its own. Feature branches with work stay where they are.
if [ "$current" != "(detached)" ] && [ "$ahead" = 0 ] && [ "$behind" != 0 ] && [ "$behind" != "?" ] \
  && [ -z "$(git status --porcelain --untracked-files=no 2>/dev/null)" ] \
  && git merge --ff-only --quiet "origin/$default_branch" >/dev/null 2>&1; then
  msg="Fetched origin. Branch '$current' fast-forwarded to origin/$default_branch (+$behind)."
fi

jq -n --arg msg "$msg" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $msg}}'
