---
name: verify-ticket
description: Use when picking up a bug ticket, issue, or defect report by key (a Jira key, a Jira URL, a GitHub issue number) whose description makes claims about the code, before implementing anything or agreeing the defect is real
argument-hint: "[TICKET-1234 | jira-url | gh-issue-number]"
---

# Verify Ticket

## Overview

A ticket description is a claim about the code, written at some past commit, by someone who may have been wrong. Parts of it are load-bearing for the fix you are about to write.

**The failure this prevents: confirmation-by-anchor.** You open each `file.ts:260` the ticket cites, the line says what the ticket says it says, and you call the ticket verified. Every anchor can be exact while the ticket is still wrong, because the claims that break a fix are rarely at the anchors.

Works on any tracker. Jira and GitHub intake are both first-class below; the rule — **the record, not the card** — is the same either way.

## Running this without poisoning the session

This procedure generates large payloads — a card body with comments runs ~16k characters, a JQL over the linked keys can exceed 65k, and the repro and greps are unbounded. Run inline, all of it lands in the calling session.

**Default: commission it, do not run it.** Dispatch the `ticket-verifier` agent with the ticket key. It owns the whole procedure including intake, dispatches its own lanes, and returns a capped three-bucket verdict plus a path to the full report. The calling session pays for the verdict, not the working material.

Run it inline only when you *are* the verifier, or when the card is small enough that the boundary costs more than it saves.

Whoever runs it, two rules hold:

- **Never `subagent_type: "fork"`.** A fork inherits the caller's context — the opposite of the point.
- **Cap what comes back.** The full report goes to a file; the return is the verdict, one line per bucket item, and the path. When the buckets are long, cut the *evidence* from the return, never the *items* — a failed claim must surface even when its proof stays in the file.

## Intake: the record, not the card

**Fetch the card yourself from the key.** Do not ask for the text to be pasted, and do not work from a description quoted into your prompt — that is a snapshot someone else took, at a time you cannot see. No key given, ask for one; a file of ticket text is a fallback, and the report must say you could not reach the live record.

The card cannot tell you what the card owns. Whatever the tracker, pull all four before checking anything:

1. **The card with its comments.** Read them in order: a card whose description still asserts something a comment already retracted is the normal case, not the exception. They are not a trusted layer over an untrusted one, though — see the claim table.
2. **Every linked and blocking card, by key or number.** Read their **status**, not the card's account of them. A blocker that is `Done` or `Cancelled` changes what this card is waiting for, and a `Cancelled` blocker means its sequencing paragraph is now unsatisfiable.
3. **The design doc / EDD / RFC / issue epic** the card descends from — usually named in the description or in the PR that merged it. It, not the card, decides scope.
4. **Open PRs** on this branch or the sibling cards (`gh pr list`). Half the card may already be merged.

Skip this intake and you will confirm a claim the design doc already put out of scope, and hand back a card that reads done while the other half is still live.

### GitHub

```bash
gh issue view <n> --comments --json title,body,state,labels,comments,closedByPullRequestsReferences
gh issue view <n> --json body -q .body | grep -oE '#[0-9]+|[A-Z]+-[0-9]+'   # linked work
gh pr list --search "<n>" --state all
```

`--comments` is not implied by `--json comments` in older `gh`; pass both. Linked issues are not a structured field on most repos — they live in the body text and in timeline cross-references, so read the body for `#123` and `Closes #123` and fetch each.

### Jira

The Atlassian tools are deferred — load them first:

```
ToolSearch("select:mcp__plugin_atlassian_atlassian__getJiraIssue,mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql")
```

If they do not resolve, the Atlassian plugin is not enabled here. Say so and fall back to the record you can reach (`gh`, the design doc, the PRs); do not silently verify a Jira card from its description alone.

Fetch the card with its comments and links in one call:

```json
{
  "cloudId": "<site cloud id>",
  "issueIdOrKey": "TICKET-1234",
  "responseContentFormat": "markdown",
  "fields": ["summary", "description", "status", "issuetype", "parent",
             "assignee", "created", "updated", "comment", "issuelinks",
             "<sprint field>"]
}
```

`comment` and `issuelinks` are the two that matter and neither is in the default field set. Get `cloudId` from `getAccessibleAtlassianResources` and the sprint field id from `getJiraIssueTypeMetaWithFields` — or read them off *Known sites* at the bottom of this file, and add the site there once you have looked them up.

Then pull the linked and blocking keys in one JQL call: `key in (TICKET-1235, TICKET-1236)`.

`searchJiraIssuesUsingJql` payloads are huge and overflow the tool cap; when the result is written to a file, read it back with
`jq -r '.issues.nodes[] | "\(.key)\t\(.fields.status.name)\t\(.fields.summary)"' <file>`.

## Pin the commit

State the sha you verified at. The ticket was written at a different one.

To run code somewhere other than the ticket's sha (a checkout that has `node_modules`), first prove the file is the same:

```bash
git diff <ticket-sha> <your-sha> -- path/to/file.ts
```

Empty diff licenses the move. Say in the report that you checked.

**Run the diff yourself; never inherit one.** A comment on the ticket saying "this file is unchanged since X" was true when it was written. Files move. A stale licence has you running a different function than the one you are reporting on.

## Classify each claim, then check it by its type

| Claim shape | How it is actually checked | Not enough |
|---|---|---|
| **Title** — "derived status reports `synced`" | Check it against the observed behaviour, clause by clause | Reading it as a label |
| **Anchor** — "`foo.ts:260` does X" | Open it. Then ask whether it is the *right* anchor: the single place, or a wrapper over the real one? | The line existing |
| **Universal** — "exactly one writer", "only", "sole", "always", "never" | Enumerate the population. `grep` every writer, caller, branch. | Confirming the one instance the ticket names |
| **Scope** — "this card fixes X" | The design doc and the sibling cards decide who owns X | The card asserting it |
| **Behavioral** — "this returns `pending`" | Run it | Reading the function and predicting |
| **Comment** — "verified at X", "this is unchanged", "blocked on Y" | Date it, then re-check it at today's state | That someone already checked |

**Start with the title.** It is the most-read and least-checked sentence on the card: it is what the backlog shows, what gets quoted in standup, and what a "is this done?" review is scored against. It is also written first, when the author understood the least. Read it as a claim with a subject and a verb, and check each clause — a title asserting the wrong observed value survives a full verification of the description, because nobody ever points a check at it.

A title that contradicts its own description is the common shape, and either half can be the wrong one. Report the contradiction; do not quietly pick the half you verified.

**A comment is a claim with a timestamp, not a correction you inherit.** It was true when written. Three shapes go stale, and all three appear on ordinary cards:

- a **licence** — "this file is unchanged since X, so you can run it in the other checkout". Re-run the diff.
- a **relay** — an answer sourced from another repo, a dashboard, or a query nobody has re-run. Keep it, attribute it, and put it under *Not checked* unless you re-derive it.
- a **pointer** — "this unblocks when Y ships". Read Y's status; a `Cancelled` blocker makes the plan built on it unsatisfiable.

Later comments supersede earlier ones, but the newest is not automatically right either — it is just the most recent claim.

**The universals are where tickets are wrong.** "Exactly one writer" names the writer the author thought of. Grep for the others before building a rule on top of it.

## Dispatch: three lanes, framed to refute

**Framing first, and it is free.** An agent asked to *verify* a claim drifts toward confirming it — that is how "exactly one writer" survives a full pass. Ask each agent to **refute**: the claim is false until it survives an attempt to break it.

Worth it before a card you will spend days on. Skip the lanes for a card with two claims and an obvious fix — a fan-out is roughly 3x the cost of doing it inline.

Split by **claim type**, never by file or by claim. Four agents each handed "confirm `foo.ts:260`" reproduces confirmation-by-anchor four times over. The types need different context and different tools, and that is the axis that pays:

| Lane | `subagent_type` | Claim types | Must NOT receive |
|---|---|---|---|
| **Repo sweep** | `claim-refuter-repo` | Universal, Anchor | the card itself, or anyone's conclusion |
| **Record** | `claim-refuter-record` | Scope, Comment, blocker status | the code findings |
| **Runtime** | `claim-refuter-runtime` | Behavioral | your expected result |

Each has an agent definition carrying the refute stance, its breaking moves, its tool scope and its return cap. Send claims and a sha; do not restate the method, and do not send your reasoning.

All three in one message so they run concurrently. The Repo lane is the one that catches universals: its whole job is enumerating populations, and it has no card text tempting it to stop at the named instance.

**Do not parallelize the repro.** It is one harness; splitting it buys four transcriptions of the same file and four chances to stub something. The Runtime lane owns it, following *Reproduce with a control* below.

**The title check is not a lane.** It is a comparison against the Runtime lane's observed values, so it runs on the main thread once that lane returns.

### Contract for every lane

1. **Never hand it your verdict.** Give it the claim and the sha. Handed your conclusion, it grades your conclusion — an easier, different task.
2. **Make it name its refutation condition first.** "What would I have to find for this to be false?", stated before it goes looking. An agent that has named the disconfirming evidence cannot drift into confirming.
3. **A `SURVIVED` with no attempt named is not a pass.** It is indistinguishable from a lane that did not look. Send it back.
4. **Re-verify yourself, but only the findings that change the text.** A lane that relays an answer from another repo, a dashboard, or a query nobody re-ran has produced a *Not checked* item, whatever confidence it reports.

## Reproduce with a control

The defect case alone proves nothing — you cannot tell which input caused it.

- **A** — the defect case
- **B** — a control identical to A except the one input the ticket blames

Then one case per class the ticket's guard exists for, so you learn whether the guard protects something real or a hypothetical.

Run **the real module**. Copying the source into a scratch file with imports stubbed runs your transcription, not the code; "logic untouched" is a claim your reader cannot check. Blocked by deps, use the sha-diff above to move to a checkout that has them. Delete the scratch harness afterwards.

If you must extract a file to run it, make the reader able to check you: `shasum` what you ran against the git blob and report the match. "Its only import is `import type`, erased at runtime, so nothing was stubbed" is evidence. "Logic untouched" is not.

Where the ticket prescribes a fix, run the fix too — including the naive one it warns against. A card whose most useful sentence is "the obvious fix does not work" is worth confirming before you spend a day on the obvious fix.

**Isolation:** an extra checkout keeps the repro off the working tree, but `git worktree` is not free everywhere — a git-crypt repo hands the worktree locked files, since the unlock lives in the primary `.git`. If a worktree comes up empty or encrypted, fall back to a scratch clone or run in place read-only, and say which you did.

## Report in three buckets

Never one. A report that is all "held" is a report that checked anchors.

1. **Held** — the claim, the evidence, marked *read* or *ran*
2. **Did not hold** — the correction, and whether it changes the fix or only the wording
3. **Not checked** — and why

Corrections go to the ticket description; the verification goes to a comment. Do not silently rewrite the author's reasoning — the comment is the record of what changed and why.

## Red flags

- You never checked the title → the most-quoted claim on the card went unverified
- You took a comment's word for something → it was true when written, not now
- You handed a lane your verdict → it graded your verdict, it did not check the claim
- A lane came back confirming everything → it was framed to verify, not to refute
- Every claim came back "held" → you checked anchors, not claims
- You never opened the design doc → you cannot know what this card owns
- Your repro has one case → no control, nothing isolated
- You ran a copy of the file → you verified a transcription
- You cited something you remember from a prior session → re-query it, or move it to *Not checked*

## Known sites

Looked-up values, so the discovery calls above are only needed for a new site. Add a row after looking one up.

| Site | Project keys | `cloudId` | Sprint field |
|---|---|---|---|
| `stxgroup.atlassian.net` | `EVO` | `ea285670-c5fb-45dd-9f85-6292c8dc4fed` | `customfield_10018` |
