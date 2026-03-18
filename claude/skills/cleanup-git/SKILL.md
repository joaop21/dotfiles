---
name: cleanup-git
description: Clean up stale local branches and worktrees already merged remotely
model: haiku
---

# Git Cleanup

Clean up stale local branches and worktrees that have already been merged and deleted remotely.

## Steps

1. Run `git fetch --prune` to sync remote tracking references
2. Find local branches whose remote has been deleted:
   ```bash
   git branch -vv | grep ': gone]' | awk '{print $1}'
   ```
3. Find worktrees on branches that are merged into main:
   ```bash
   git worktree list
   git branch --merged main
   ```
4. Present the found branches and worktrees to the user using `AskUserQuestion` with `multiSelect: true`, so the user can checkbox which ones to delete
5. Only delete the ones the user selected:
   - Remove stale worktrees: `git worktree remove <path>`
   - Delete stale branches: `git branch -D <branch>`
6. Report what was cleaned up

## Rules

- Always list before deleting — never delete without showing the user first
- Skip main and the current branch
- Skip worktrees with uncommitted changes (use `git worktree remove` which will fail safely)
- If nothing to clean up, just say so
