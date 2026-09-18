---
name: open-pr
description: Use when the user asks to commit and open a PR, push a branch and open a PR, or says "open a PR" / "open-pr" — in any repo.
allowed-tools: Bash, Read, Grep, Glob
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
4. Commit. The message is one line, under 50 characters, in the PR title
   form below. No body, no trailer.
5. `git push -u origin <branch>`, then `gh pr create` with the title and body
   below. Print the PR URL. Stop — no `--web`, no merge.

## Title

`<Tool> - <Short description>` — tool or area touched, a space-hyphen-space,
then what changed. `Nvim - Fix Elixir setup`, `ZSH - Add history options`,
`Git - Ignore wrangler state`.

## Body

Exactly these two sections, nothing before, between, or after:

```markdown
## Why:

<the need: what was wrong or missing, in one short paragraph>

## This change addresses the need by:

- <what changed and how it meets the need, one bullet per change>
```

That is the whole body. A test plan, a changed-files list, or a footer is
not part of it.
