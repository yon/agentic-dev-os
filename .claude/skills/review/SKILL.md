# /review — Combined Multi-Agent Code Review

Run a comprehensive, multi-dimensional code review using specialized agents.

---

## Steps

### 1. Determine Scope
- `/review` → review all uncommitted changes (`git diff`)
- `/review [file or directory]` → review specific files
- `/review --staged` → review staged changes only

### 2. Identify Changed Files
Read the files to review. Understand what changed and the context around the changes.

### 3. Select and Launch Agents

Based on the nature of the changes, launch the appropriate agents **in parallel**:

| Always Run | Conditional |
|-----------|-------------|
| **code-reviewer** | **security-reviewer** — if auth, input handling, config, or deps changed |
| **test-reviewer** | **architecture-reviewer** — if new modules/services created or module boundaries changed |
| | **performance-reviewer** — if data access, algorithms, or hot-path code changed |
| | **doc-reviewer** — if public APIs or README changed |

### 4. Run Verifier
After agent reviews, run the **verifier** agent to confirm build/test/lint pass.

### 5. Compile Results

Merge all agent reports into a single summary:

```markdown
## Combined Code Review

**Files Reviewed:** [list]
**Review Agents Used:** [list]
**Overall Quality:** [Excellent / Good / Needs Work / Significant Issues]
**Quality Score:** [N]/100

### Critical Issues (block commit)
[Merged from all agents, deduplicated]

### Major Issues (block PR)
[Merged from all agents, deduplicated]

### Minor Issues (polish)
[Merged from all agents, deduplicated]

### Verification
| Check | Status |
|-------|--------|
| Build | PASS/FAIL |
| Tests | PASS/FAIL |
| Lint | PASS/FAIL |
| Type Check | PASS/FAIL |

### Agent Summaries
- **Code Review:** [one-line summary]
- **Security:** [one-line summary]
- **Tests:** [one-line summary]
- **Architecture:** [one-line summary]
- **Performance:** [one-line summary]
- **Documentation:** [one-line summary]

### Recommended Actions
1. [Highest priority action]
2. [Next priority]
```

### 6. Score
Apply the quality-gates rubric to compute a score. Report the score with gate status:
- Score >= 80: "Ready to commit"
- Score >= 90: "Ready for PR"
- Score >= 95: "Release quality"
