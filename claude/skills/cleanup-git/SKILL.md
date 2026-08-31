---
name: cleanup-git
description: Clean up stale local branches and worktrees already merged remotely
model: haiku
---

# Git Cleanup

Delete local branches and worktrees whose work has already landed on the remote default branch.

## Steps

1. Sync, and resolve the default branch instead of hardcoding `main`:
   ```bash
   git fetch --prune
   DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD) || { git remote set-head origin -a; DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD); }
   LOCAL=${DEFAULT#origin/}
   ```
   Stop if `$DEFAULT` is still empty — do not run the queries below with an unset default. An empty `$LOCAL` makes step 3's `grep -vx "$LOCAL"` filter nothing, so the default branch itself shows up as a deletion candidate.

   Always compare against the remote ref, never the local branch: local is often behind, and then these queries silently come back empty.

2. Find branches whose upstream is deleted — where squash-merged PRs land:
   ```bash
   git for-each-ref --format='%(refname:short) %(upstream:track,nobracket)' refs/heads | awk '$2=="gone"{print $1}'
   ```
   Do not parse `git branch -vv` for this: the current branch's line starts with `* `, so `awk '{print $1}'` yields a bare `*` instead of a name.

3. Find branches already contained in the default branch:
   ```bash
   git for-each-ref --format='%(refname:short)' --merged "$DEFAULT" refs/heads | grep -vx "$LOCAL"
   ```
   Both queries are required. A squash-merged branch never appears in step 3, because the squash rewrote its history. A branch that never had an upstream never appears in step 2, because `%(upstream:track)` is empty rather than `[gone]`.

4. For each candidate, establish whether deleting it could lose work:
   ```bash
   git diff --stat "$DEFAULT" <branch>     # empty = identical trees, nothing to lose
   ```
   This is the only trustworthy signal. Do NOT judge from `git log "$DEFAULT"..<branch>`: a squash-merged branch still lists its original commits there, so that output reads as unmerged work when nothing is at risk. Use `git log` only to quote commit subjects back to the user.

5. List worktrees with `git worktree list`. The first entry is the primary worktree and can never be removed. A linked worktree is a candidate when its branch is one, and it must be removed *before* that branch, since a checked-out branch cannot be deleted.

6. Present the candidates with `AskUserQuestion` and `multiSelect: true`. Give each one's reason ("upstream gone, merged as #74" / "contained in origin/main") and its step 4 verdict. If a candidate's diff was non-empty, say prominently that it holds work found nowhere else. Branches that matched neither query are not candidates and are not offered — mention them only as explicitly kept.

   Ask before touching anything. Everything up to here is read-only; the working tree is not moved and no branch is deleted until the user has answered.

7. Only once the user has selected, and only if the current branch is among what they chose, move off it — being checked out is a reason to move, not a reason to spare it:
   ```bash
   git status --porcelain --untracked-files=no     # stash anything this lists
   git checkout "$LOCAL"
   git pull --ff-only || true                      # useful, but never block cleanup on it
   ```
   Tracked changes only: untracked files never block a checkout, so do not stash them. Stash rather than commit — committing onto a branch you are about to delete buries the work.

8. Delete what the user selected:
   - Worktrees first: `git worktree remove <path>`
   - Then `git branch -d <branch>`. If it refuses with "not fully merged" and step 4 came back empty, the branch was squash-merged and `git branch -D` is safe. If step 4 was non-empty, do not force.

9. Report what was cleaned up, passing on the `(was <sha>)` that `git branch` prints for anything force-deleted so it can be recovered from the reflog.

## Rules

- List before deleting — never delete without showing the user first
- Never delete the default branch
- Let `git worktree remove` refuse worktrees with uncommitted changes; it fails safely
- If nothing is stale, say so
