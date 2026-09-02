---
name: ship-check
description: Use when a change is finished on a feature branch and is about to become a PR — the code is written but has not been cleaned up, reviewed, or verified. Use when the user says "ship-check", "ready for PR?", "get this ready to ship", or invokes /ship-check.
allowed-tools: Bash, Read, Grep, Glob, Agent, AskUserQuestion, Skill
---

# Ship check

The gate between "implementation done" and "open the PR".

**Core principle: subagents cannot ask the user anything.** Each stage runs in
its own subagent to keep the main thread's context small; every decision needing
human judgement travels back as an escalation. A subagent that decides for itself
has broken the gate.

## When to use

- Implementation is complete on a feature branch, PR not yet opened
- After `branch-worker`, `issue-worker`, or `issue-swarm` finishes

**Not for:** work in progress, the default branch, or a PR that already exists.

## Step 0: Goal anchor (required)

Resolve what the work was *supposed* to do. Drift cannot be detected without it.
Try each source in order; **a source that errors is a miss, so fall through to
the next one.** A failed `gh` call is a missing source, not a stop.

1. Branch matches `issue-<N>-*` → `gh issue view <N>`
2. An open PR exists for the branch → `gh pr view --json title,body`
3. A ticket file in the repo — `ISSUE.md`, `TICKET.md`, a `docs/` spec named
   after the branch
4. Otherwise → commit subjects since the merge-base

Capture the acceptance criteria and anything listed **out of scope** — these are
the yardstick for every later stage.

Sources 1-3 are authoritative — say which one you used, in one line, and carry
on. **Only source 4 needs confirming**, because a goal reverse-engineered from
commit subjects is a guess: state the goal and out-of-scope list you inferred and
ask whether that is the right yardstick before spawning anything. An inferred
anchor the user never saw hides exactly the drift this skill exists to catch.

Preflight — resolve the base without assuming a remote exists, then both
conditions must hold or bail with the reason:
```bash
BASE=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) \
  || BASE=$(git rev-parse --verify -q main >/dev/null && echo main || echo master)
git rev-parse --abbrev-ref HEAD              # must not be the default branch
git diff --stat "$(git merge-base HEAD "$BASE")"   # must be non-empty
```
A repo with no `origin` is not an error — it only means stage 4 has nothing to
push to, which this skill never does anyway.

## Step 0.5: Drift scan

Before spawning any stage, diff the branch against the anchor and check for the
`breaking` and `drift` predicates below. If either fires, **escalate now** — do
not spawn stage 1.

Cleaning up code whose right to exist in this PR is unsettled wastes the pass and
presumes the answer. Settle scope first, polish second.

## Stages

Sequential — never parallel, they share one working tree. Each is a subagent.
Pass every subagent the goal anchor and the report contract.

| # | Subagent invokes | Purpose |
|---|---|---|
| 1 | Skill `simplify` | Quality-only cleanup; applies its own fixes |
| 2 | Skill `superpowers:requesting-code-review` | Review the post-simplify tree |
| 3 | Skill `superpowers:receiving-code-review` | Triage findings; fix blockers only |
| 4 | Skill `verify` | Prove the final tree works |

Stage 2 runs *after* stage 1 so the reviewer sees cleaned code, not the
pre-cleanup version. Stage 4 runs last so it covers every fix.

## Report contract

Every stage subagent returns exactly these sections and nothing else:

```
## DID
one line per action taken

## FINDINGS
blocker   | file:line | one line
judgement | file:line | one line

## ESCALATIONS
none
(or one line per escalation, each tagged breaking / drift / question / blocked)

## STATUS
pass | fail | blocked
```

A stage that cannot invoke its skill returns `STATUS blocked` and names the
skill that failed to resolve. Approximating the stage by hand instead is a
silent failure — the whole point of naming these stages is that they ran.

## Escalation triggers

Escalate on an observable predicate, not a feeling:

- **breaking** — the diff changes a public signature, exported symbol, schema,
  migration, or config consumed outside the diff
- **drift** — the diff does something the anchor lists as out of scope, or
  implements something the anchor never asked for
- **question** — a decision needs information absent from both anchor and code
- **blocked** — verify fails, or its command cannot be run at all

## The gate

On any escalation the main thread **halts the chain** and puts it to the user
with `AskUserQuestion`: stop / proceed / adjust. Nothing downstream runs until
the user answers.

**Never revert, delete, or narrow out-of-scope work on your own authority.**
Work outside the anchor may be deliberate and the anchor may be stale. Removing
it is a decision with an owner, and the owner is not you. Escalate it as `drift`
and let the user rule.

No exceptions:
- Not when the ticket "explicitly" forbids it — tickets go out of date
- Not when reverting looks obviously correct
- Not when it is a small diff
- Not by reverting first and mentioning it in the summary afterwards

## Blocker vs judgement

| Blocker (fix in stage 3) | Judgement (ask, never auto-apply) |
|---|---|
| Wrong output, crash, data loss | Naming, structure, file layout |
| Security flaw | Style, idiom, comment density |
| Regression against the anchor | Missing coverage, "consider…" |
| Contract or invariant violation | Anything prefixed "nit" |

Judgement findings are collected and put to the user in one `AskUserQuestion`
with `multiSelect: true`. A finding that is simply wrong gets pushed back on
with reasoning, not implemented.

## Finish

Commit the fixes — message under 50 chars, no co-author trailer. Print one
summary line per stage plus the verify evidence.

Then **stop.** No push, no PR, no `finishing-a-development-branch`. Opening the
PR is the user's next move, not this skill's.

## Red flags

| Thought | Reality |
|---------|---------|
| "The out-of-scope work is clearly wrong, I'll just revert it" | That is the user's call. Escalate as drift. |
| "I'll review it myself, it's faster than delegating" | Inline review burns the main context this skill exists to protect. |
| "`verify` didn't resolve, I'll check it by hand" | Return `blocked`. A hand-check is not the stage. |
| "It passed, so I may as well open the PR" | The skill ends before the PR. Always. |
| "No issue number, I'll infer the goal and continue" | Infer, then *confirm with the user*. Unconfirmed anchors hide drift. |
| "`gh issue view` errored, so Step 0 is blocked" | An erroring source is a miss. Fall through to the next one. |
| "I'll run simplify first, then sort the scope question out" | Scope is settled before the tree is touched. Escalate at Step 0.5. |
| "One escalation isn't worth interrupting for" | Every escalation halts. The user decides what is worth their time. |
