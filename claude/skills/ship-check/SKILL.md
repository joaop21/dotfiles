---
name: ship-check
description: Use when a change is finished on a feature branch and is about to become a PR — the code is written but has not been cleaned up, reviewed, or verified. Use when the user says "ship-check", "ready for PR?", "get this ready to ship", or invokes /ship-check.
allowed-tools: Bash, Read, Grep, Glob, Agent, AskUserQuestion, Skill
---

# Ship check

The gate between "implementation done" and "open the PR".

**Core principle: subagents cannot ask the user anything.** Each stage runs in
its own subagent to keep the main thread's context small; every decision needing
human judgement travels back as an escalation.

**A source that is absent or errors is a miss, not a stop — fall through to the
next one.** That governs every lookup below: a failed `gh` call, a missing ticket
file, an unset `origin/HEAD`. Only an exhausted list of sources is a stop.

## When to use

- Implementation is complete on a feature branch, PR not yet opened
- After `branch-worker`, `issue-worker`, or `issue-swarm` finishes

**Not for:** work in progress, the default branch, or a PR that already exists.

## Step 0: Preflight

Bail before spending a `gh` call. Resolve the default branch the way
`cleanup-git` does, then both conditions must hold or stop with the reason:

```bash
DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) \
  || { git remote set-head origin -a 2>/dev/null; DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); }
[ -n "$DEFAULT" ] || DEFAULT=$(git config --get init.defaultBranch)   # no origin: still a source

if [ -z "$DEFAULT" ]; then
  echo "ESCALATE question: no default branch resolves"          # never guess 'master'
elif ! BASE=$(git merge-base HEAD "$DEFAULT" 2>/dev/null); then
  echo "ESCALATE question: no merge-base between HEAD and $DEFAULT"
fi

BRANCH=$(git branch --show-current)                 # empty means detached HEAD
if [ -z "$BRANCH" ]; then
  echo "BAIL: detached HEAD, no branch to commit to"
elif [ "$BRANCH" = "${DEFAULT#origin/}" ]; then
  echo "BAIL: on the default branch"
elif [ -n "$BASE" ] && git diff --quiet "$BASE"; then
  echo "BAIL: no changes since the merge-base"
else
  echo "PREFLIGHT OK: $BRANCH vs $BASE"
fi
```

Read the printed line, not the exit status. `git diff --quiet` exits 1 exactly
when changes *do* exist, so a passing preflight otherwise looks like a failed
command. A detached HEAD is a bail, not a pass: `--show-current` returns empty,
which would slip the default-branch check and leave Finish with nothing to
commit to.

Never let `merge-base` run against an empty `$DEFAULT` — it exits 128 and kills the
step. Guard it as above: no `$DEFAULT`, or no merge-base, is a `question`, not a
guessed `master`, and nothing downstream runs without a `$BASE`.
Keep `$BASE`: Step 2 and every stage diff against it rather than recomputing it.

## Step 1: Goal anchor (required)

Resolve what the work was *supposed* to do. Drift cannot be detected without it.
Try each source in order:

1. Branch matches `issue-<N>-*`, the shape `grab-issue` creates → `gh issue view <N>`
2. An open PR exists for the branch → `gh pr view --json title,body`
3. A ticket file in the repo — `ISSUE.md`, `TICKET.md`, a `docs/` spec named
   after the branch
4. Otherwise → commit subjects since `$BASE`

Capture the acceptance criteria and anything listed **out of scope** — these are
the yardstick for every later stage.

Sources 1-3 are authoritative — say which one you used, in one line, and carry
on. **Only source 4 needs confirming**: state the goal and out-of-scope list you
inferred and ask whether that is the right yardstick before spawning anything.

## Escalation triggers

Escalate on an observable predicate, not a feeling:

- **breaking** — the diff changes a public signature, exported symbol, schema,
  migration, or config consumed outside the diff
- **drift** — the diff does something the anchor lists as out of scope, or
  implements something the anchor never asked for
- **question** — a decision needs information absent from both anchor and code
- **blocked** — a stage's skill will not resolve, or verification fails or
  cannot be run

## The gate

On any escalation the main thread **halts the chain** and puts it to the user
with `AskUserQuestion`: stop / proceed / adjust. Nothing downstream runs until
the user answers. Every escalation halts — the user decides what is worth their
time.

**Any stage returning a `STATUS` other than `pass` halts the chain the same
way**, whether or not it also filled `ESCALATIONS`. A `fail` with `ESCALATIONS
none` — a red `verify`, say — is still a stop: read the stage's `FINDINGS` back
to the user with `AskUserQuestion` and let them rule. Never treat an empty
`ESCALATIONS` block as permission to continue past a non-`pass` status.

**Never revert, delete, or narrow out-of-scope work on your own authority.**
Work outside the anchor may be deliberate and the anchor may be stale. Removing
it is a decision with an owner, and the owner is not you. Escalate it as `drift`
and let the user rule. No property of the work creates an exception — not the
ticket's wording, not obviousness, not diff size — and reverting first while
mentioning it afterwards is still deciding.

## Step 2: Drift scan

Before spawning any stage, diff the branch against the anchor and check the
`breaking` and `drift` predicates. If either fires, **escalate now** — do not
spawn stage 1. Settle scope first, polish second.

## Stages

Sequential — never parallel, they share one working tree. Each is a subagent.

| # | Subagent invokes | Purpose |
|---|---|---|
| 1 | Skill `simplify` | Quality-only cleanup; applies its own fixes |
| 2 | Skill `superpowers:requesting-code-review` | Review the post-simplify tree |
| 3 | Skill `superpowers:receiving-code-review` | Triage findings; fix blockers only |
| 4 | Skill `superpowers:verification-before-completion` | Prove the final tree works |

`/verify` is **not** stage 4 and cannot be. It is flagged
`disable-model-invocation`: the Skill tool refuses it with "Ask the user to run
/verify themselves", and it forbids replicating its workflow by other means. It
is a user-only gate by design. Stage 4 gathers automated evidence; the user runs
`/verify` after this skill hands back.

Stage 1's cleanup lands in the **working tree**, and nothing is committed until
Finish — so `$BASE..HEAD`, the range `requesting-code-review` reaches for by
default, does not contain it. Stage 2 must override the range it hands its
reviewer: base `$BASE`, head *the working tree*, reviewed with `git diff $BASE`
(plus `git status --porcelain` for new files), never `git diff $BASE..HEAD`.
The reviewer stays read-only on the checkout — stage 2 does not commit to
manufacture a head SHA. Pass this in the `Review range` slot.

Dispatch with slots only — a template with no free-text field has nowhere for
your own conclusion to leak in and be graded back at you:

```
Stage: <n — and the skill it must invoke, by name>
Repo: <absolute path to the repo under check>
Base: <$BASE>
Goal anchor: <the source used, plus the acceptance criteria>
Out of scope: <verbatim from the anchor, or "none stated">
Anti-revert rule: <the "Never revert, delete, or narrow" paragraph above, verbatim>
Review range: <stage 2 only — "$BASE vs the working tree, via git diff $BASE">
Findings to triage: <stage 3 only — stage 2's FINDINGS lines, verbatim>
Report contract: <the four sections below, verbatim>
```

Fill every slot that applies to the stage and drop the ones that do not. Two are
load-bearing:

- **Anti-revert rule** goes to *every* stage. The main thread edits nothing;
  stage 1 and stage 3 do, and they are the only agents that can revert
  out-of-scope work. A prohibition they never receive constrains nobody.
- **Findings to triage** is stage 3's whole input. Stage 3 triages stage 2's
  findings, and a subagent sees nothing you do not put in its prompt — dispatch
  it without this slot and it has nothing to triage.

`Repo:` is not optional — a stage inherits your working directory, not your
subject. Never `subagent_type: "fork"`: a fork inherits the caller's context,
which is the opposite of the point.

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
skill that failed to resolve. Never approximate the stage by hand.

## Blocker vs judgement

| Blocker (fix in stage 3) | Judgement (ask, never auto-apply) |
|---|---|
| Wrong output, crash, data loss | Naming, structure, file layout |
| Security flaw | Style, idiom, comment density |
| Regression against the anchor | Missing coverage, "consider…" |
| Contract or invariant violation | Anything prefixed "nit" |

**Regression means the diff broke something the anchor asked for.** Work that is
merely *extra* relative to the anchor is drift, never a regression — so it is
escalated, never fixed in stage 3. Stage 3 makes existing behaviour correct; it
never decides that behaviour should not exist. If removing it is the only way to
"fix" a finding, that is the tell you are holding drift.

`superpowers:requesting-code-review` grades findings Critical / Important /
Minor: blocker is Critical and Important, judgement is Minor. (The grading lives
in the *requesting* skill, stage 2 — `receiving-code-review` has none.)

## Finish

Reached only when **every stage returned `STATUS pass`** — any other status
halted the chain at the gate, and nothing here runs.

Judgement findings from every stage are collected and put to the user in one
`AskUserQuestion` with `multiSelect: true`. Unlike escalations they do not halt
the chain — they wait until it is done. A finding that is simply wrong gets
pushed back on with reasoning, not implemented.

Commit the fixes — message under 50 chars, no co-author trailer, unless the
repo's own conventions say otherwise, in which case the repo wins.

**Stage only the paths the stages actually touched.** Preflight tolerates
pre-existing uncommitted work, so `git commit -a` would sweep unrelated changes
into your commit. Name the paths explicitly, and run `git status` before
committing to confirm nothing else rode along. Print one
summary line per stage plus the verify evidence.

Then hand back with the one thing this skill cannot do for the user:

> Stages 1-4 are done. Run `/verify` yourself — it is user-only and I cannot
> invoke it. Open the PR once it comes back clean.

Then **stop.** No push, no PR, no `finishing-a-development-branch`. Opening the
PR is the user's next move, not this skill's.

## Red flags

Each row is a thought that showed up in baseline testing, verbatim. If you catch
yourself thinking one, you are already off the path.

| Thought | Reality |
|---------|---------|
| "The out-of-scope work is clearly wrong, I'll just revert it" | That is the user's call. Escalate as drift. |
| "I'll review it myself, it's faster than delegating" | Inline review burns the main context this skill exists to protect. |
| "A stage's skill didn't resolve, I'll check it by hand" | Return `blocked`. A hand-check is not the stage. |
| "I'll invoke `/verify` for them, it's one call" | It refuses model invocation, and replicating it is forbidden. Hand back. |
| "It passed, so I may as well open the PR" | The skill ends before the PR. Always. |
| "No issue number, I'll infer the goal and continue" | Infer, then *confirm with the user*. Unconfirmed anchors hide drift. |
| "`gh issue view` errored, so Step 1 is blocked" | An erroring source is a miss. Fall through to the next one. |
| "I'll run simplify first, then sort the scope question out" | Scope is settled before the tree is touched. Escalate at Step 2. |
| "One escalation isn't worth interrupting for" | Every escalation halts. The user decides what is worth their time. |
