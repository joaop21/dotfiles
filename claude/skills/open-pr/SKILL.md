---
name: open-pr
description: Use when the user asks to commit and open a PR, push a branch and open a PR, or says "open a PR" / "open-pr" — in any repo.
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# Open PR

Branch, commit, push, `gh pr create`, print the URL. One PR per logical change.

## Steps

1. `git status --porcelain` — the change is these paths.
2. On the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`)?
   Create one: short kebab-case, with the user's prefix if given (`js/`).
3. Stage those paths by name. Never `git add -A`, `git add .`, `commit -a`.
4. Commit: one line, under 50 characters, in the title form below. No body,
   no trailer.
5. Draft title and body, then one `general-purpose` subagent: "Invoke the
   `humanizer:humanizer` skill on this text and return only the rewritten
   title and body." Use what comes back as-is.
6. `git push -u origin <branch>`, `gh pr create` with that title and body,
   print the URL. Stop — no `--web`, no merge.

## Title

First source that answers:

1. `CLAUDE.md` or `CONTRIBUTING.md` states a PR title format.
2. `gh pr list --state merged --limit 10 --json title -q '.[].title'` has a
   dominant shape (`feat(scope): …`, `ABC-123: …`, `[bug] …`, `Tool - …`):
   copy it. A ticket key in the branch name (`ABC-123-…`, `issue-42-…`) goes
   where those titles put it.
3. Neither: a one-sentence TL;DR of the change.

The commit subject takes the same shape.

## Body

`.github/pull_request_template.md` exists: fill it. Otherwise exactly this,
nothing before, between, or after:

```markdown
## Why:

<what was wrong or missing — one or two sentences, a paragraph at most>

## This change addresses the need by:

- <what changed and how it meets the need — one bullet per change, one or
  two sentences each, a paragraph at most>
```

No test plan, no changed-files list, no footer.
