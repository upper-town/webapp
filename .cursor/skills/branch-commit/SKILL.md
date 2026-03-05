---
name: branch-commit
description: Generates a succinct commit message summarizing the current branch's changes against main, then performs the commit. If the current commit is a WIP commit, amends it with the new message; otherwise stages changes and creates a new commit. Use when the user asks to summarize branch changes as a commit message, write a commit message for the branch, commit the branch changes, or describe what the branch does.
---

# Branch Commit Message

Generate a commit message that summarizes everything the current branch changed relative to `main`, then perform the commit.

## Steps

1. Get the branch name and diff stat:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   ```bash
   git diff main... --stat
   ```

2. Get the full diff for analysis:
   ```bash
   git diff main...
   ```
   If the diff is very large, use `--stat` and `--name-only` first, then read individual files selectively.

3. Optionally review the branch's commit log for additional context:
   ```bash
   git log main..HEAD --oneline
   ```

4. Check if the current HEAD commit is a WIP commit:
   ```bash
   git log -1 --pretty=%B
   ```
   A WIP commit is one whose message (first line) starts with "WIP" or "wip" (case-insensitive), optionally followed by a colon, space, or hyphen. Examples: "WIP", "wip", "WIP: foo", "WIP - something".

5. Compose the commit message following the format below.

6. Verify every line (title and bullets) is at most 72 characters. Reword if needed.

7. Perform the commit:
   - **If current commit is WIP**: Amend the commit with the new message (no need to stage; amend replaces the message):
     ```bash
     git commit --amend -m "<full message: title, blank line, bullets>"
     ```
   - **If current commit is NOT WIP**: Stage all changes and create a new commit:
     ```bash
     git add -A
     git status
     git commit -m "<full message: title, blank line, bullets>"
     ```
   - Pass the complete message (title + blank line + bullets) as a single `-m` argument. Use actual newlines in the string. Escape any double quotes inside the message.
   - If there are no changes to commit (working tree clean and not amending), inform the user and output the message only.

8. After performing the commit, briefly confirm what was done (e.g., "Amended WIP commit with message: ..." or "Created new commit: ...").

## Commit Message Format

The message has two parts: a title line followed by a blank line and a bullet list:

    <Title: one-line imperative summary, 72 chars max>

    - <change 1, 72 chars max>
    - <change 2, 72 chars max>
    - ...

### Rules

- **Title**: imperative mood ("Add X", "Fix Y", "Refactor Z"), concise, no trailing period.
- **Body**: a flat bullet list of the notable additions, changes, removals, or fixes. Each bullet is one short sentence. Omit trivial or mechanical changes (whitespace, import reordering) unless they are the only change.
- **72 chars max per line**: Every line (title and each bullet) must be at most 72 characters. Before outputting, verify each line. Reword long lines to stay within the limit; do not wrap mid-sentence.
- **ASCII only**: use plain ASCII characters (hyphens, commas, parentheses). No em dashes, arrows, or other Unicode symbols.
- **No trailers**: Do not add footer lines like "Made-with: Cursor", "Co-authored-by:", or similar.
- Keep the total message short - aim for 3-8 bullets. Group related changes into a single bullet when possible.
- Do **not** list every file; describe *what* changed at a meaningful level of abstraction.
- When confirming the commit, show the message in a markdown code block for clarity.

## Examples

Example 1 - feature branch:

    Add hCaptcha verification to user sign-up

    - Integrate hCaptcha client and server-side validation
    - Add ManageCaptcha controller concern
    - Show captcha widget on registration and password reset forms
    - Add tests for captcha verification flow

Example 2 - fix branch:

    Fix server vote count not resetting at period boundary

    - Correct period boundary calculation in Periods module
    - Update vote consolidation query to respect time zones
    - Add regression test for midnight UTC edge case

Example 3 - chore/refactor branch:

    Refactor admin permission checks into policy objects

    - Extract AdminAccessPolicy from controller before_actions
    - Add AdminPermission lookup caching
    - Update admin controller tests to use policy helpers
