---
description: Use when asked to review a PR, given a PR number/URL, or after completing a feature implementation
disable-model-invocation: true
context: fork
allowed-tools: Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh api:*), Read, Grep, Glob
---

Provide a code review for pull request $ARGUMENTS.

**Agent assumptions (applies to all agents and subagents):**

- All tools are functional and will work without error. Do not test tools or make exploratory calls.
- Only call a tool if it is required to complete the task. Every tool call should have a clear purpose.
- Subagents are read-only: they may use Read, Grep, Glob, and gh CLI read commands (gh pr view, gh pr diff, gh api GET). No file edits or writes.
- The entire review runs autonomously — do not ask the user for input at any point.

Follow these steps precisely:

1. Launch a haiku agent to check if any of the following are true:
   - The pull request is closed
   - The pull request is a draft
   - The pull request does not need code review (e.g. automated PR, trivial change that is obviously correct)
   - Claude has already commented on this PR (check `gh pr view <PR> --comments` for comments left by claude)

   If any condition is true, stop and do not proceed.

   Note: Still review Claude generated PRs.

2. Launch a haiku agent to return a list of file paths (not their contents) for all relevant standards files:
   - The root CLAUDE.md file, if it exists
   - Any CLAUDE.md files in directories containing files modified by the pull request
   - All `.claude/rules/*.md` files

3. Launch a sonnet agent to view the pull request and return a summary of the changes.

4. Launch 4 agents in parallel to independently review the changes. Each agent should return the list of issues, where each issue includes a description and the reason it was flagged. The agents should do the following:

   Agents 1 + 2: Standards compliance sonnet agents
   Audit changes for compliance with CLAUDE.md and `.claude/rules/` standards in parallel. Match the relevant rules to the files being reviewed based on any `paths` frontmatter in the rules files.

   Agent 3: Opus bug agent (parallel with agent 4)
   Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that you cannot validate without looking at context outside of the git diff.

   Agent 4: Opus bug agent (parallel with agent 3)
   Look for problems that exist in the introduced code. This could be security issues, incorrect logic, etc. Only look for issues that fall within the changed code.

   **CRITICAL: We only want HIGH SIGNAL issues.** Flag issues where:
   - The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
   - The code will definitely produce wrong results regardless of inputs (clear logic errors)
   - Clear, unambiguous CLAUDE.md or `.claude/rules/` violations where you can quote the exact rule being broken

   Do NOT flag:
   - Code style or quality concerns
   - Potential issues that depend on specific inputs or state
   - Subjective suggestions or improvements

   If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

   Each subagent should be told the PR title and description for context regarding the author's intent.

5. For each issue found by agents 3 and 4, launch parallel subagents to validate the issue. These subagents should get the PR title and description along with a description of the issue. The agent's job is to review the issue to validate that it is truly an issue with high confidence. Use Opus subagents for bugs and logic issues, and sonnet agents for CLAUDE.md violations.

6. Filter out any issues that were not validated in step 5. This gives us our list of high signal issues.

7. If issues were found, skip to step 8 to post inline comments directly.

   If NO issues were found, post a summary comment using `gh pr comment`:

   ---

   ## Code review

   No issues found. Checked for bugs, CLAUDE.md compliance, and coding standards.

   ---

8. Post inline comments for each issue using `gh api` to post a PR review with inline comments:

   ```bash
   gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
     --method POST \
     -f body="Code Review" \
     -f event="COMMENT" \
     -f 'comments[][path]=<file_path>' \
     -f 'comments[][line]=<line_number>' \
     -f 'comments[][body]=<comment_body>'
   ```

   For each comment:
   - Provide a brief description of the issue
   - For small, self-contained fixes, include a committable suggestion block:

     ````
     ```suggestion
     <corrected code>
     ```
     ````

   - For larger fixes (6+ lines, structural changes, or changes spanning multiple locations), describe the issue and suggested fix without a suggestion block
   - Never post a committable suggestion UNLESS committing the suggestion fixes the issue entirely

   **IMPORTANT: Only post ONE comment per unique issue. Do not post duplicate comments.**

Use this list when evaluating issues in Steps 4 and 5 (these are false positives, do NOT flag):

- Pre-existing issues
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch
- General code quality concerns unless explicitly required in CLAUDE.md
- Issues mentioned in CLAUDE.md but explicitly silenced in the code (e.g., via a lint ignore comment)

Notes:

- Use gh CLI to interact with GitHub. Do not use web fetch.
- Create a todo list before starting.
- You must cite and link each issue in inline comments. When linking to code, use this format: `https://github.com/{owner}/{repo}/blob/{full_sha}/{file_path}#L{start}-L{end}`
  - Requires full git sha (not a command substitution)
  - Provide at least 1 line of context before and after
