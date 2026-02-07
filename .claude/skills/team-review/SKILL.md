# /team-review — Parallel Agent Team Code Review

Spawn a team of independent reviewers that examine the codebase simultaneously from different angles. Each reviewer operates in its own context window with full codebase access.

**This is a read-only operation.** No reviewer edits files. The lead synthesizes all findings.

---

## When to Use (vs. /review)

| Use `/review` when... | Use `/team-review` when... |
|----------------------|--------------------------|
| Reviewing a small change (< 5 files) | Reviewing a large change (10+ files) |
| Quick feedback is needed | Thorough, multi-dimensional analysis is needed |
| Token budget is a concern | Quality and depth matter more than cost |
| Changes are in a single module | Changes span multiple modules/layers |

---

## Steps

### 1. Determine Scope
- `/team-review` → all uncommitted changes
- `/team-review [file, dir, or commit range]` → specific scope
- `/team-review --staged` → staged changes only

### 2. Analyze the Change Set
Read all changed files. Categorize the nature of changes to determine which reviewers to spawn.

### 3. Spawn Review Team

Use `spawnTeam` to create reviewers. **All reviewers are read-only — they produce reports, never edit files.**

#### Standard Team (most changes):
```
Teammate A: Code Reviewer
  - Focus: correctness, readability, DRY/KISS/SOLID, anti-patterns
  - Files: all changed source files

Teammate B: Security Reviewer
  - Focus: OWASP top 10, input validation, secrets, auth
  - Files: all changed files + config files

Teammate C: Test Reviewer
  - Focus: TDD compliance, coverage gaps, test quality, test smells
  - Files: all changed test files + corresponding source files

Teammate D: Architecture Reviewer
  - Focus: module boundaries, coupling, SOLID at system level
  - Files: all changed files + module index/entry points
```

#### Extended Team (for large/critical changes, add):
```
Teammate E: Performance Reviewer
  - Focus: algorithmic complexity, N+1 queries, memory, concurrency
  - Files: data access code, hot paths, new algorithms

Teammate F: Documentation Reviewer
  - Focus: API docs, README accuracy, stale comments
  - Files: changed public APIs + docs/ + README
```

### 4. Collect Results

Wait for all teammates to complete. Each sends a structured report.

### 5. Synthesize

The lead merges all reports into a single review:

```markdown
## Team Code Review

**Scope:** [what was reviewed]
**Reviewers:** [N] teammates
**Overall Assessment:** [Excellent / Good / Needs Work / Significant Issues]
**Quality Score:** [N]/100

### Critical Issues (must fix before commit)
[Merged from all reviewers, deduplicated, attributed to source reviewer]
- **[reviewer]** [file:line] — [issue]

### Major Issues (should fix before PR)
[Same format]

### Minor Issues (polish)
[Same format]

### Reviewer Summaries
| Reviewer | Assessment | Critical | Major | Minor |
|----------|-----------|----------|-------|-------|
| Code | [status] | [N] | [N] | [N] |
| Security | [status] | [N] | [N] | [N] |
| Test | [status] | [N] | [N] | [N] |
| Architecture | [status] | [N] | [N] | [N] |

### Engineering Principles Compliance
[Aggregated from code + architecture reviewers]

### Recommended Actions (priority order)
1. [Most critical fix]
2. [Next priority]
```

### 6. Cleanup
Tear down the review team after synthesis.

---

## Adversarial Guarantee

This skill enforces **complete separation of review and implementation**:
- Review teammates are spawned as **read-only** — they cannot edit files
- If the reviewed code was written by an agent team, the review team MUST be different agents than the implementers
- The lead does NOT review — it only synthesizes
- Findings are reported with severity; the lead does not downgrade severity without justification
