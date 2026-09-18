---
name: close-issue
description: Use when a PR is merged and the user asks what is left, says "close the issue", "move the card to Done", "comment and close", or invokes /close-issue.
allowed-tools: Bash, Read, Agent, ToolSearch, mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources, mcp__plugin_atlassian_atlassian__getJiraIssue, mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql, mcp__plugin_atlassian_atlassian__addCommentToJiraIssue, mcp__plugin_atlassian_atlassian__getTransitionsForJiraIssue, mcp__plugin_atlassian_atlassian__transitionJiraIssue, mcp__plugin_atlassian_atlassian__createJiraIssue
---

# Close issue

Snapshot first. Act only on what the snapshot shows open. Corrections are comments.

## 1. Snapshot — read, print, stop

Inputs: the GitHub issue, Jira key and PR named in this session. None named: ask.

One `general-purpose` subagent fetches current state — nothing recalled from earlier in the session. Its dispatch names the repo, PR, issue numbers and Jira key literally, and says: read-only — post, close and transition nothing.

- `gh pr view <PR> --json state,mergedAt,closingIssuesReferences`
- `gh issue view <N> --json state,body,comments` — the issue and each issue its body or comments link
- Jira: status, comments, linked issues, via the atlassian MCP (`ToolSearch` loads the tools)

It returns exactly this, nothing else:

```
## Snapshot
item | state | already done | outstanding

## Stale
item | verbatim line that no longer holds | what is true now | command output proving it
```

"already done" holds work a comment, link, or status already covers. "outstanding" holds work nothing tracks yet. Print the report as returned and stop: the user picks the rows to act on.

## 2. Act on "outstanding" only

- A correction to an issue, PR or card is a new comment. The existing body stays as it is.
- Draft each comment from the `## Stale` row, then one `general-purpose` subagent: "Invoke the `humanizer:humanizer` skill on this text and return only the rewritten comment." Show what comes back, post on "go".
- Outstanding work with no card: propose one under the same epic, create on "go".
- Close the issue and transition the card only when their row shows nothing outstanding.

## 3. Hand back

Posted, closed, transitioned — one line each. Then what still needs a human.
