---
name: grab-issue
description: Pick up a GitHub issue by number — read scope, detect repo conventions, rebase, drive with failing tests, commit, push, open PR. Use when the user says "grab issue #N", "pick up issue N", or invokes /grab-issue.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Skill, AskUserQuestion
---

# Grab a GitHub issue end-to-end

Grab GitHub issue `#$ARGUMENTS` and ship it: read scope, implement with TDD, commit, push, open PR matching the repo's conventions.

## Steps

1. **Read scope.** Run `gh issue view $ARGUMENTS`. Read full body. Note `Depends on` / `Out of scope` / `Acceptance criteria` sections. Stop and tell the user if:
   - Issue closed
   - Open PR already exists: `gh pr list --search "fixes #$ARGUMENTS in:body"`
   - Issue blocked by an open dependency

2. **Detect workspace.** Run `pwd` and `git rev-parse --abbrev-ref HEAD`.
   - If pwd contains `worktrees/` or `.worktrees/` → pre-staged worktree, use as-is
   - If branch is `main`/`master`/default → create branch `issue-$ARGUMENTS-<slug>` (slug from issue title, kebab-case, ≤40 chars) and `git checkout -b`
   - Else → reuse current branch, but confirm with user first

3. **Rebase on main.**
   ```
   git fetch origin
   git rebase origin/$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
   ```
   Conflicts → stop, ask user.

4. **Detect repo conventions.** Read in this order, first hit wins:
   - `CLAUDE.md`, `AGENTS.md`, `.github/CONTRIBUTING.md`, `CONTRIBUTING.md` → commit/PR style rules
   - `.claude/rules/*.md` → project-specific rules
   - `git log --oneline -30` → infer commit message style (Conventional Commits? prefix? imperative subject? body format?)
   - `gh pr list --state merged --limit 5 --json title,body` → PR title + body conventions
   Cache findings in conversation for steps 7-9. Do NOT assume Conventional Commits; match what the repo actually does.

5. **Detect test command.** Pick first that exists:
   - `mix.exs` → `mix test` (or `mix precommit` if defined in `mix.exs` aliases)
   - `package.json` → script in this order: `test`, `check`, `ci`
   - `Cargo.toml` → `cargo test`
   - `go.mod` → `go test ./...`
   - `pyproject.toml` / `setup.py` → `pytest` or script from `[tool.poetry.scripts]`
   - `Makefile` with `test` target → `make test`
   - `Justfile` with `test` recipe → `just test`
   None found → ask user.

6. **Read referenced code.** Open every file path, module, function, and PR/issue link mentioned in the issue body before writing code.

7. **Grill open questions.** If scope ambiguous, acceptance criteria fuzzy, or issue contradicts code from step 6 — invoke `grill-me:grill-me` to pressure-test with user before touching code. Skip if scope is unambiguous.

8. **Switch to Sonnet for execution.** Run `/model claude-sonnet-4-6`. Planning is Opus; mechanical execution runs faster/cheaper on Sonnet. Skip if already Sonnet/Haiku.

9. **TDD.** Invoke `superpowers:test-driven-development`. Write failing test → watch fail with expected error → make pass. Run the test command from step 5 before declaring done.
   Pure tooling/config changes with no testable behavior → state that explicitly and skip. Do not fabricate tests.

10. **Commit.** Match the style from step 4. If no style detected, use a short imperative subject (≤50 chars) and a body only when "why" isn't obvious.

11. **Push & open PR.**
    ```
    git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
    ```
    Then `gh pr create` with title + body in the repo's style (step 4). Body MUST end with `Closes #$ARGUMENTS` (or `Fixes #$ARGUMENTS` if the repo uses that form).

12. **Report.** Print PR URL. Stop. Do NOT merge.

## Rules

- One issue per PR. Out-of-scope work → new branch, new issue.
- Never `--force-push` unless user asks.
- Never skip hooks (`--no-verify`).
- If `gh` not authenticated → stop, tell user to run `gh auth login`.
- If repo conventions conflict with these defaults, repo wins.
