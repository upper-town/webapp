---
name: branch-commit-message
description: Generates a succinct commit message summarizing the current branch's changes against main. Use when the user asks to summarize branch changes as a commit message, write a commit message for the branch, or describe what the branch does.
---

# Branch Commit Message

Generate a commit message that summarizes everything the current branch changed relative to `main`.

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

4. Compose the commit message following the format below.

## Commit Message Format

The message has two parts — a title line followed by a blank line and a bullet list:

    <Title: one-line imperative summary, max ~72 chars>

    - <change 1>
    - <change 2>
    - ...

### Rules

- **Title**: imperative mood ("Add X", "Fix Y", "Refactor Z"), concise, no trailing period.
- **Body**: a flat bullet list of the notable additions, changes, removals, or fixes. Each bullet is one short sentence. Omit trivial or mechanical changes (whitespace, import reordering) unless they are the only change.
- **Every line** (title and each bullet) must be at most 72 characters. Reword to stay within the limit rather than wrapping mid-sentence.
- Keep the total message short — aim for 3–8 bullets. Group related changes into a single bullet when possible.
- Do **not** list every file; describe *what* changed at a meaningful level of abstraction.
- **Output in a markdown code block** — wrap the commit message in triple backticks (```) so the user can click the copy button in the IDE to copy it in one action.

## Examples

Example 1 — feature branch:

    Add hCaptcha verification to user sign-up

    - Integrate hCaptcha client and server-side validation
    - Add ManageCaptcha controller concern
    - Show captcha widget on registration and password reset forms
    - Add tests for captcha verification flow

Example 2 — fix branch:

    Fix server vote count not resetting at period boundary

    - Correct period boundary calculation in Periods module
    - Update vote consolidation query to respect time zones
    - Add regression test for midnight UTC edge case

Example 3 — chore/refactor branch:

    Refactor admin permission checks into policy objects

    - Extract AdminAccessPolicy from controller before_actions
    - Add AdminPermission lookup caching
    - Update admin controller tests to use policy helpers
