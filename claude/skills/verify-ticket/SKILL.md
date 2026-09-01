---
name: verify-ticket
description: Use when picking up a bug ticket, issue, or defect report by key (a Jira key, a Jira URL, a GitHub issue number) whose description makes claims about the code, before implementing anything or agreeing the defect is real
argument-hint: "[TICKET-1234 | jira-url | gh-issue-number]"
allowed-tools: Bash, Read, Grep, Glob, Write, Agent, ToolSearch, Skill
---

# Verify Ticket

A ticket description is a claim about the code, written at some past commit, by someone who may have been wrong. Parts of it are load-bearing for the fix you are about to write.

**The failure this prevents: confirmation-by-anchor.** You open each `file.ts:260` the ticket cites, the line says what the ticket says it says, and you call the ticket verified. Every anchor can be exact while the ticket is still wrong, because the claims that break a fix are rarely at the anchors.

**Default: dispatch the `ticket-verifier` agent with the key.** It owns the whole procedure including intake, and returns a capped verdict plus a path to the full report — a card body runs ~16k characters and a JQL over the linked keys can exceed 65k, none of which the caller needs. Run inline only if you *are* that agent, or the card has fewer than three claims and none of them is Universal or Behavioral.

Never `subagent_type: "fork"` for any of this. A fork inherits the caller's context, which is the opposite of the point.

Works on any tracker; Jira and GitHub intake are peers below.

## Intake: the record, not the card

**Fetch the card yourself from the key.** Do not ask for the text to be pasted, and do not work from a description quoted into your prompt — that is a snapshot someone else took, at a time you cannot see. No key given, ask for one; a file of ticket text is a fallback, and the report must say you could not reach the live record.

The card cannot tell you what the card owns. Whatever the tracker, pull all four before checking anything:

1. **The card with its comments.** Read them in order: a card whose description still asserts something a comment already retracted is the normal case, not the exception.
2. **Every linked and blocking card**, by key or number. Read their **status**, not the card's account of them. A blocker that is `Done` or `Cancelled` changes what this card is waiting for, and a `Cancelled` blocker means its sequencing paragraph is now unsatisfiable.
3. **The design doc / EDD / RFC / epic** the card descends from — usually named in the description or in the PR that merged it. It, not the card, decides scope.
4. **Open PRs** on this branch or the sibling cards. Half the card may already be merged.

Skip this intake and you will confirm a claim the design doc already put out of scope, and hand back a card that reads done while the other half is still live.

Write what comes back to `${TMPDIR:-/tmp}/ticket-verification/<KEY>-intake.json` and pass that path to the lanes. Raw fetched data is not a verdict, so passing it does not breach the dispatch contract — and a lane that re-fetches the card pays the 16k twice.

### GitHub

```bash
gh issue view <n> --json title,body,state,labels,comments,closedByPullRequestsReferences,blockedBy,blocking,subIssues,parent
gh pr list --search "<n> in:body" --state all --limit 20 --json number,title,state,url
```

`--comments` is ignored when `--json` is present; ask for the `comments` field instead. If `gh` rejects `blockedBy`/`subIssues`, it predates issue dependencies — fall back to grepping the body for `#123` and `Closes #123`.

### Jira

The Atlassian tools are deferred — load them first:

```
ToolSearch("select:mcp__plugin_atlassian_atlassian__getJiraIssue,mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql,mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources")
```

If they do not resolve, the Atlassian plugin is not enabled here. Say so and work the record you can reach; do not verify a Jira card from a description you could not fetch.

```json
{ "cloudId": "<site cloud id>", "issueIdOrKey": "TICKET-1234",
  "responseContentFormat": "markdown",
  "fields": ["summary","description","status","updated","comment","issuelinks"] }
```

`comment` and `issuelinks` are the two that matter and neither is in the default field set. Get `cloudId` from `getAccessibleAtlassianResources`, or read it off *Known sites* below.

Then the linked and blocking keys in one call — ask for the three fields you read, or the response overflows the tool cap:

```json
{ "jql": "key in (TICKET-1235, TICKET-1236)", "fields": ["key","status","summary"], "maxResults": 50 }
```

## Pin the commit

State the sha you verified at. The ticket was written at a different one.

To run code somewhere other than the ticket's sha, first prove the file is the same — compare blob hashes rather than diffing, so a mismatch does not dump the file into context:

```bash
git rev-parse <ticket-sha>:path/to/file.ts <your-sha>:path/to/file.ts
```

Equal hashes license the move. Say in the report that you checked.

**Run the check yourself; never inherit one.** A comment saying "this file is unchanged since X" was true when it was written. A stale licence has you running a different function than the one you are reporting on.

## Classify each claim, then check it by its type

| Claim shape | How it is actually checked | Not enough |
|---|---|---|
| **Title** — "derived status reports `synced`" | Check it against the observed behaviour, clause by clause | Reading it as a label |
| **Anchor** — "`foo.ts:260` does X" | Open it, ask whether it is the *right* anchor or a wrapper over the real one, then look for the path that **bypasses** it | The line existing |
| **Universal** — "exactly one writer", "only", "sole", "always", "never" | Enumerate the population — every writer, caller, branch, including indirect ones — then narrow the claim to what survives | Confirming the one instance the ticket names |
| **Scope** — "this card fixes X" | The design doc and the sibling cards decide who owns X | The card asserting it |
| **Behavioral** — "this returns `pending`" | Run it, with a control | Reading the function and predicting |
| **Comment** — "verified at X", "this is unchanged", "blocked on Y" | Date it, then re-check it at today's state | That someone already checked |

An anchor that is real but bypassable is a refutation: a fix written to it ships on one path and not the other. "Only creator" is a different and often true claim than "only writer" — report the narrowed version rather than a bare REFUTED.

**Start with the title.** It is the most-read and least-checked sentence on the card: what the backlog shows, what gets quoted in standup, what a "is this done?" review is scored against. It is also written first, when the author understood the least. A title asserting the wrong observed value survives a full verification of the description, because nobody ever points a check at it. A title that contradicts its own description is the common shape, and either half can be the wrong one — report the contradiction, do not quietly pick the half you verified.

**A comment is a claim with a timestamp, not a correction you inherit.** Three shapes go stale: a **licence** ("this file is unchanged since X") — re-run the check; a **relay** (an answer sourced from another repo, a dashboard, or a query nobody re-ran) — attribute it and put it under *Not checked* unless you re-derive it; a **pointer** ("this unblocks when Y ships") — read Y's status. Later comments supersede earlier ones, but the newest is not automatically right; it is the most recent claim.

## Dispatch: three lanes, framed to refute

**Framing first, and it is free.** An agent asked to *verify* a claim drifts toward confirming it — that is how "exactly one writer" survives a full pass. Each lane is framed to **refute**: the claim is false until it survives an attempt to break it.

Split by **claim type**, never by file or by claim. Four agents each handed "confirm `foo.ts:260`" reproduces confirmation-by-anchor four times over. Dispatch a lane when it has two or more claims of its type; a single-claim lane runs inline.

| Lane | `subagent_type` | Claim types | Also receives |
|---|---|---|---|
| **Repo sweep** | `claim-refuter-repo` | Universal, Anchor | nothing else — not the card, not a conclusion |
| **Record** | `claim-refuter-record` | Scope, Comment, blocker status | the intake path |
| **Runtime** | `claim-refuter-runtime` | Behavioral | an isolated checkout if the repo supports one |

Each agent definition carries its own refute stance, breaking moves, tools and return shape. Dispatch with slots only — a template with no free-text field has nowhere for a verdict to leak into:

```
Claims: <verbatim list, one per line>
Sha: <sha>
Name your refutation condition for each before you look.
```

All lanes in one message so they run concurrently. The Repo lane is the one that catches universals: its whole job is enumerating populations, and it has no card text tempting it to stop at the named instance.

**Do not parallelize the repro.** It is one harness; splitting it buys four transcriptions of the same file and four chances to stub something. The Runtime lane owns it, and its definition carries the method — control arm, real module, blob-hash proof.

**The title check is not a lane.** It is a comparison against the Runtime lane's observed values, so it runs on the main thread once that lane returns.

Two rules about what comes back:

- **A `SURVIVED` with no attempt named is not a pass.** It is indistinguishable from a lane that did not look. Send it back.
- **Re-verify the findings that change the text.** A lane relaying an answer from another repo, a dashboard, or a query nobody re-ran has produced a *Not checked* item, whatever confidence it reports.

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

A cache for the `getAccessibleAtlassianResources` lookup, not a registry to maintain.

| Site | `cloudId` |
|---|---|
| `stxgroup.atlassian.net` | `ea285670-c5fb-45dd-9f85-6292c8dc4fed` |
