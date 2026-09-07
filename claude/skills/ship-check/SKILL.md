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

- Implementation is complete on a feature branch
- After `branch-worker`, `issue-worker`, or `issue-swarm` finishes
- Again on a branch whose PR is already open — after review feedback, or on a
  draft. An open PR is a valid subject and the anchor's second-best source.

**Not for:** work in progress, or the default branch.

## Step 0: Preflight

Bail before spending a `gh` call. The `set-head` fallback is the one step that
reaches the remote, so an auth-gated origin can stall or prompt there. One
chain, one verdict line — act on the line it prints:

```bash
BRANCH=$(git branch --show-current)                 # empty means detached HEAD
if [ -z "$BRANCH" ]; then
  echo "BAIL: detached HEAD, no branch to commit to"     # bails before any network call
else
  DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) \
    || { git remote set-head origin -a 2>/dev/null; DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); }
  [ -n "$DEFAULT" ] || DEFAULT=$(git config --get init.defaultBranch)   # no origin: still a source

  if [ -z "$DEFAULT" ]; then
    echo "ESCALATE question: no default branch resolves"          # never guess 'master'
  elif [ "$BRANCH" = "${DEFAULT#origin/}" ]; then
    echo "BAIL: on the default branch"
  elif ! BASE=$(git merge-base HEAD "$DEFAULT" 2>/dev/null); then
    echo "ESCALATE question: no merge-base between HEAD and $DEFAULT"   # unguarded, it exits 128
  elif git diff --quiet "$BASE" && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "BAIL: no changes since the merge-base"    # untracked files are changes too
  else
    echo "PREFLIGHT OK: $BRANCH vs $BASE"
  fi
fi
```

Read that line, not the exit status: `git diff --quiet` exits 1 exactly when
changes *do* exist, so a passing preflight otherwise looks like a failed
command.

**Copy the SHA out of the `PREFLIGHT OK` line and substitute it literally from
here on.** Shell variables do not survive between Bash calls in this harness: a
later `git diff $BASE` expands to a bare `git diff`, which exits 0 and reports
only unstaged changes — staged work and every commit on the branch vanish, with
no error to notice. Write the SHA into the command, and into every dispatch's
`Base:` slot. `$BASE` below is shorthand for that literal SHA, never a variable
to expand. Nothing downstream runs without it, and no stage recomputes it.

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
with `AskUserQuestion`. Nothing downstream runs until the user answers. Every
escalation halts — the user decides what is worth their time.

Normally offer three options, and do what the chosen one says:

- **stop** — end the run here. Report what happened, hand back, commit nothing.
  The working tree keeps whatever stage 1 or 3 already applied.
- **proceed** — the user has ruled the escalation acceptable. Resume at the
  stage after the one that escalated, carrying their ruling into that stage's
  `Goal anchor` slot so it is not raised again. Step 2 is not a stage: proceed
  on a drift-scan escalation resumes at stage 1.
- **adjust** — the user supplies the missing fact (a base SHA, a corrected
  anchor, a scope ruling). Apply it, then re-run the step that escalated.

A Step 0 escalation resolves no `$BASE`, and nothing downstream runs without
one — so **proceed is not on offer there.** Offer stop / adjust only, and treat
adjust as the user naming the base to diff against.

Halt the same way whenever a stage returns:

- `STATUS blocked` — a stage that could not run is not a stage that passed
- a non-empty `ESCALATIONS` block, whatever its `STATUS`
- `STATUS fail` from **stage 3 or stage 4**. Stage 3 is the fixer, so a failing
  stage 3 has nowhere left to route it; a red stage 4 is the thing this gate
  exists to catch. Read that stage's `FINDINGS` back to the user with
  `AskUserQuestion` and let them rule. **A failed stage 4 never reaches
  Finish** — `ESCALATIONS none` is not permission to continue.

`STATUS fail` from stage 1 or stage 2, with `ESCALATIONS none`, does **not**
halt. Fixing blockers is what stage 3 is for, and stopping to ask would
interrupt nearly every run. Carry every `blocker` line into stage 3's
`Findings to triage` slot, add every `judgement` line to the Finish collection,
and continue in stage order — stage 3 runs *after* stage 2, never instead of it.

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
Finish — so `<SHA>..HEAD`, the range `requesting-code-review` reaches for by
default, does not contain it. Stage 2 must override the range it hands its
reviewer: base `<SHA>`, head *the working tree*, reviewed with `git diff <SHA>`
(plus `git status --porcelain` for new files), never `git diff <SHA>..HEAD`.
The reviewer stays read-only on the checkout — stage 2 does not commit to
manufacture a head SHA. All of that travels in the `Review range` slot, in full:
a slot that says less than this paragraph hands stage 2 an incomplete change
set, and it will not know what it missed.

Dispatch with slots only — a template with no free-text field has nowhere for
your own conclusion to leak in and be graded back at you:

```
Stage: <n — and the skill it must invoke, by name>
Repo: <absolute path to the repo under check>
Base: <the literal SHA from preflight — never the characters "$BASE">
Goal anchor: <the source used, plus the acceptance criteria>
Out of scope: <verbatim from the anchor, or "none stated">
Anti-revert rule: <the "Never revert, delete, or narrow" paragraph above, verbatim>
Blocker vs judgement: <fix blockers only; judgement findings are the user's call and must not be applied. Plus the table below, verbatim, and: `superpowers:requesting-code-review` grades Critical and Important as blocker, Minor as judgement>
Commit policy: <"Do not commit, do not push, do not open a PR — nothing is committed until Finish">
Review range: <stage 2 only — "<SHA> vs the working tree: git diff <SHA> for tracked changes, plus git status --porcelain for files new to the tree; never git diff <SHA>..HEAD. Stay read-only on the checkout — do not commit to manufacture a head SHA">
Findings to triage: <stage 3 only — the FINDINGS lines to fix, verbatim, from whichever earlier stage produced them: stage 2's, plus any blocker lines stage 1 returned>
Report contract: <the four sections below, verbatim>
```

Fill every slot that applies to the stage and drop the ones that do not. Four
are load-bearing:

- **Anti-revert rule** goes to *every* stage. The main thread edits nothing;
  stage 1, stage 3, and the judgement fixer do, and they are the only agents
  that can revert out-of-scope work. A prohibition they never receive
  constrains nobody.
- **Blocker vs judgement** goes to *every* stage that edits. "Blockers auto-
  fixed, judgement calls asked" is a property of this skill, not of the stage
  skills — stage 3 has no other way to learn it, and a stage 3 that quietly
  applies the Minor findings has taken the user's decisions for them.
- **Commit policy** goes to *every* stage. Every stage runs against an
  uncommitted tree, and the review range depends on it staying that way: one
  stage committing behind your back moves the boundary the next stage reads.
- **Findings to triage** is stage 3's whole input. Stage 3 triages the findings
  the earlier stages produced — stage 2's, plus any blocker stage 1 returned —
  and a subagent sees nothing you do not put in its prompt: dispatch it without
  this slot and it has nothing to triage.

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

**Regression means the diff broke something the anchor asked for**, never work
that is merely *extra* relative to it. The test: if removing something is the
only way to "fix" a finding, it is drift, and drift escalates.

`superpowers:requesting-code-review` grades findings Critical / Important /
Minor: blocker is Critical and Important, judgement is Minor.

## Finish

Reached only when **stage 4 returned `STATUS pass`** and no stage tripped a
halt. A stage 1 or 2 `fail` that routed on to stage 3 is not a halt; every other
non-`pass` is, and a halted chain never arrives here.

Judgement findings from every stage are collected and put to the user in one
`AskUserQuestion` with `multiSelect: true`. Unlike escalations they do not halt
the chain — they wait until it is done. A finding that is simply wrong gets
pushed back on with reasoning, not implemented.

**Whatever the user accepts goes to one more subagent, not to you.** The main
thread has no `Edit` or `Write` and does not acquire them at the finish line —
dispatch a **judgement fixer** on the same template: `Stage: judgement fixer —
invokes no skill; applies only the findings listed below, and nothing else`, the
accepted findings verbatim in `Findings to triage`, and the `Repo`, `Base`,
`Goal anchor`, `Out of scope`, `Anti-revert rule`, `Blocker vs judgement`,
`Commit policy` and `Report contract` slots exactly as every stage gets them. It
returns the same report contract, and its own escalations halt like any other.
If the user accepts nothing, skip it and commit what the stages already did.

Commit the fixes — message under 50 chars, no co-author trailer, unless the
repo's own conventions say otherwise, in which case the repo wins.

**Stage only the paths the stages actually touched — never by wildcard.** The
tree may already have held unrelated changes when preflight passed, so
`git commit -a`, `git add -A` and `git add .` all sweep them into your commit.
Name the paths, and run `git status` before committing to confirm nothing else
rode along.

Print one summary line per stage plus the verify evidence.

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
