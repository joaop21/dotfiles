---
name: open-pr
description: Use when the user asks to commit and open a PR, push a branch and open a PR, or says "open a PR" / "open-pr" — in any repo.
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# Open PR

Branch, commit, push, `gh pr create`, print the URL. One PR per logical change.

## Steps

1. `git status --porcelain` — know exactly which paths are the change.
2. On the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`)?
   Create one: short kebab-case from the change, with the user's prefix if
   they gave one (e.g. `js/`). Already on a feature branch: stay.
3. Stage the change's paths by name. Never `git add -A`, `git add .`, or
   `commit -a` — the tree may hold unrelated work.
4. Commit. The message is one line, under 50 characters, in the title form
   below. No body, no trailer.
5. Draft the title and body below, then hand both to one `general-purpose`
   subagent: "Invoke the `humanizer:humanizer` skill on this text and return
   only the rewritten title and body." Use what comes back as-is.
6. `git push -u origin <branch>`, then `gh pr create` with that title and
   body. Print the PR URL. Stop — no `--web`, no merge.

## Title

Match the repo's convention. Resolve it from the first source that answers:

1. The repo's `CLAUDE.md` or `CONTRIBUTING.md` states a PR title format.
2. `gh pr list --state merged --limit 10 --json title -q '.[].title'` — copy
   the dominant shape: `feat(scope): …`, `ABC-123: …`, `[bug] …`,
   `Tool - …`, whatever it is. A ticket key in the branch name
   (`ABC-123-…`, `issue-42-…`) goes where those titles put it.
3. Nothing stated and no consistent shape in the history: a one-sentence
   TL;DR of the change.

The commit subject takes the same shape.

## Body

If `.github/pull_request_template.md` exists, fill that template.
Otherwise, exactly these two sections, nothing before, between, or after:

```markdown
## Why:

<what was wrong or missing — one or two sentences, a paragraph at most>

## This change addresses the need by:

- <what changed and how it meets the need — one bullet per change, one or
  two sentences each, a paragraph at most>
```

That is the whole body. The reader has the diff: say what changed, not how
the code does it. A test plan, a changed-files list, or a footer is not part
of it.
