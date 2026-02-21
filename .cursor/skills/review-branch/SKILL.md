---
name: review-branch
description: Reviews the current branch's changes against main, providing actionable suggestions. Use when the user asks to review the branch, review changes, code review against main, or critique the current branch.
---

# Review Branch Against Main

Perform a thorough code review of every change on the current branch relative to `main`, then present findings as actionable suggestions.

## Steps

### 1. Gather context

Run these commands to understand the scope:

```bash
git rev-parse --abbrev-ref HEAD
```
```bash
git log main..HEAD --oneline
```
```bash
git diff main... --stat
```

### 2. Read the full diff

```bash
git diff main...
```

If the diff is very large (many files), work in batches — use `--name-only` to list files, then diff individual files or directories.

For each changed file, also read enough surrounding context (using the Read tool) to understand how the change fits into the existing code. This is critical for catching issues that only appear when you see the broader context.

### 3. Read AGENTS.md

Read the project's `AGENTS.md` for architecture, patterns, and conventions. Evaluate changes against these established standards.

### 4. Review

Analyze every change for the categories below. Only raise points that are genuinely useful — avoid nitpicks and do not restate what the code already does.

**Categories to check:**

- **Correctness** — bugs, logic errors, off-by-one, nil/null safety, missing edge cases
- **Security** — injection, auth bypass, mass assignment, secrets in code, unsafe deserialization
- **Performance** — N+1 queries, unnecessary allocations, missing indexes, expensive operations in loops
- **Design & architecture** — adherence to project patterns (services, Result objects, policies, etc.), single-responsibility, coupling
- **Naming & clarity** — misleading names, unclear intent, code that needs a comment but lacks one
- **Tests** — missing coverage for new behavior, fragile assertions, missing edge-case tests
- **Consistency** — deviations from existing conventions without clear justification

### 5. Write the review

Present findings using this format:

```
## Branch review: `<branch-name>`

<One-paragraph summary: what the branch does, overall impression, and whether it looks ready to merge.>

### Suggestions

#### 1. <Short title>
**File:** `path/to/file.rb` (lines X–Y)
**Severity:** Critical | Suggestion | Nit

<Explanation of the issue and why it matters.>

<Suggested fix as a code block, when applicable.>

---

#### 2. <Short title>
...

### What looks good

<Brief callout of things done well — good patterns, thorough tests, clean abstractions, etc.>
```

**Severity levels:**

| Level | Meaning |
|-------|---------|
| **Critical** | Likely bug, security issue, or data-loss risk — should fix before merge |
| **Suggestion** | Improvement worth making — better design, readability, or robustness |
| **Nit** | Minor style or preference — fine to skip |

**Guidelines:**

- Order suggestions by severity (critical first).
- Include concrete code suggestions for Critical and Suggestion items when possible.
- Keep explanations concise — one or two sentences per point.
- Reference specific lines/methods, not vague areas.
- Always end with "What looks good" — balanced feedback matters.
