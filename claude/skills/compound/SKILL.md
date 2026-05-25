---
name: compound
description: Post-merge retrospective — scan the session for non-obvious learnings and persist them to auto-memory without asking. Use when the user says "PR merged", "compound", "what did we learn", "what have we learned this session", or invokes /compound.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Compound — capture session learnings into auto-memory

Trigger: user reports a PR merged (or invokes `/compound`). Goal: harvest non-obvious insights from the conversation and persist them so future sessions benefit. Small gains compound.

**User has pre-authorized saving.** Do NOT ask "should I save this?" — decide via the filter below, save what passes, report.

## Steps

1. **Locate memory dir.** Use the auto-memory directory named in the system prompt for the current project (e.g. `/Users/joao/.claude/projects/<encoded-cwd>/memory/`). The directory already exists — write to it directly.

2. **Read existing index.** Open `MEMORY.md` first. Avoid duplicates; update an existing memory if it's the same topic with new info.

3. **Scan the whole session.** Look beyond the merged PR — earlier turns often reveal more about the user than the merged code does. Watch for each memory type:
   - **user** — role, tools, keyboard layout, vim-vs-arrow, language preferences, prior expertise
   - **feedback (correction)** — "no, don't", "stop doing X", explicit redirects
   - **feedback (validated success)** — user accepted a non-obvious choice without pushback, or said "exactly", "perfect", "keep doing that"
   - **project** — stakeholders, deadlines, motivations behind work that aren't visible in code/git
   - **reference** — external dashboards, ticket trackers, Slack channels mentioned

4. **Filter out junk.** Drop candidates that are:
   - Already in `MEMORY.md` unchanged
   - Derivable from current code, file paths, `git log`, or `git blame`
   - Already documented in `CLAUDE.md` / `AGENTS.md`
   - Ephemeral task state (current branch, in-progress work, today's PR number)
   - Generic engineering wisdom not specific to this user/project
   - Code patterns, conventions, architecture, file paths

5. **Write each kept memory.** Per the system-prompt format:
   - One file per memory, kebab-case slug, lives next to `MEMORY.md`
   - Frontmatter: `name`, `description`, `metadata.type` ∈ {user, feedback, project, reference}
   - feedback/project bodies follow: rule/fact → **Why:** line → **How to apply:** line
   - Convert relative dates ("Thursday") to absolute (`2026-05-28`) at save time
   - Cross-link related memories with `[[other-name]]`

6. **Update `MEMORY.md`.** Add one-line entry per new memory under the matching section. ≤150 chars. Never paste memory content into `MEMORY.md` itself — it's an index.

7. **Report.** Print:
   - **Saved:** list of new/updated memories, one-line summary each
   - **Skipped:** candidates considered but filtered, with the reason (one-liner)
   - **Nothing worth saving** if the session yielded no signal — say it plainly, don't manufacture.

## Rules

- Never ask permission. User pre-authorized through invoking this skill.
- Bias toward fewer, higher-signal memories. Quantity ≠ quality.
- If session covered multiple PRs, group the report by PR.
- Do not save anything about the current task in flight — only durable cross-session value.
- If a candidate contradicts an existing memory, update or remove the stale one rather than stacking conflicting entries.
