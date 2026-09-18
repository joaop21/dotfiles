---
name: pre-pr-check
description: Use when a feature branch is finished and about to become a PR — the code is written but not yet cleaned up or reviewed. Use when the user says "pre-pr-check", "check before PR", or invokes /pre-pr-check.
allowed-tools: Bash, Read, Grep, Glob, Agent, Skill
---

# Pre-PR check

Simplify, then review, each in its own subagent so their diffs and findings
never enter this context. Then hand back. Nothing is committed, pushed, or
turned into a PR.

## Preflight

```bash
BRANCH=$(git branch --show-current)
DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) \
  || { git remote set-head origin -a 2>/dev/null; DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); }
if [ -z "$BRANCH" ]; then echo "BAIL: detached HEAD"
elif [ -z "$DEFAULT" ]; then echo "BAIL: no default branch resolves"
elif [ "$BRANCH" = "${DEFAULT#origin/}" ]; then echo "BASE $(git rev-parse HEAD) on $BRANCH (default branch: uncommitted changes only)"
else echo "BASE $(git merge-base HEAD "$DEFAULT") on $BRANCH"; fi
```

Act on the printed line. Copy the SHA out of `BASE …` and write it literally
into every dispatch — shell variables do not survive between Bash calls, and a
bare `git diff` silently reviews nothing.

The change under check is the working tree, not HEAD: `git diff <SHA>` plus
the untracked files in `git status --porcelain`.

## Stages

Sequential, one `general-purpose` subagent each, never `fork`:

1. `simplify` — applies its own fixes to the working tree, uncommitted
2. `superpowers:requesting-code-review` — findings reported, not applied

Dispatch with these slots and nothing else:

```
Repo: <absolute path>
Skill: <the one skill to invoke, by name; if it will not resolve, report blocked — never approximate it by hand>
Base: <the literal SHA from preflight>
Scope: <"The change is the working tree against <SHA>: git diff <SHA> plus the untracked files in git status --porcelain. Never git diff <SHA>..HEAD — earlier edits and uncommitted work are not in HEAD. Hand this same range to any reviewer you dispatch, read-only: do not commit to manufacture a head SHA.">
Commit policy: <"Do not commit, stage, push, or open a PR.">
Report contract: <the three sections below, verbatim>
```

Every stage returns exactly:

```
## DID
one line per action taken

## FINDINGS
<severity> | repo-relative file:line | one line     (none if no findings)

## STATUS
done | blocked — with the refusal text, verbatim
```

`blocked` halts the chain: name the skill that failed and stop.

## Verify

Invoke `verify` once with the Skill tool, from this thread. It is
`disable-model-invocation`: expect the refusal, never replicate its workflow.

## Hand back

Print stage 1's DID, stage 2's FINDINGS by severity, and the `verify` result.
Then:

> Simplify and review are done, nothing committed. Run `/verify` yourself — it
> is user-only — then commit and open the PR.

Stop. No commit, no push, no PR.
