---
name: git-diff-main
description: Runs git diff of the current branch against main to show branch changes. Use when the user wants to see what changed compared to main, diff against main, or compare current branch to main.
---

# Git diff against main

## Instructions

1. Run a diff of the current branch against `main`:
   ```bash
   git diff main...
   ```
   The three-dot form (`main...`) shows changes introduced by the current branch (commits reachable from HEAD but not from main).

2. Present the diff output to the user. If the diff is large, summarize file-level changes or ask whether they want a summary vs full diff.

## Optional variants

- **Stat only** (files changed): `git diff main... --stat`
- **Name-only**: `git diff main... --name-only`
- **Include uncommitted changes** (working tree vs main): `git diff main`
