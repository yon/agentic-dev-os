# /review — Combined Multi-Agent Code Review

Run a comprehensive, multi-dimensional code review using specialized subagents via the Task tool.

---

## Steps

### 1. Determine Scope
- `/review` → review all uncommitted changes (`git diff`)
- `/review [file or directory]` → review specific files
- `/review --staged` → review staged changes only

### 2. Identify Changed Files
Read the files to review. Understand what changed and the context around the changes.

### 3. Select and Launch Subagents

Based on the nature of the changes, read the appropriate agent definition files from `.claude/agents/` and spawn Task tool subagents **in parallel**:

| Agent Definition | subagent_type | When to Spawn |
|-----------------|---------------|---------------|
| `code-reviewer.md` | `senior-code-reviewer` | Always |
| `test-reviewer.md` | `senior-code-reviewer` | Always |
| `security-reviewer.md` | `security-code-auditor` | If auth, input handling, config, or deps changed |
| `architecture-reviewer.md` | `senior-code-reviewer` | If new modules/services created or boundaries changed |
| `performance-reviewer.md` | `senior-code-reviewer` | If data access, algorithms, or hot-path code changed |
| `doc-reviewer.md` | `senior-code-reviewer` | If public APIs or README changed |

**Example — spawn all selected reviewers in the same response:**
```
Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/code-reviewer.md>\n\nReview: {changed_files}")

Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/test-reviewer.md>\n\nReview: {test_files}")

Task(subagent_type="security-code-auditor",
     prompt="<content of .claude/agents/security-reviewer.md>\n\nAudit: {changed_files}")
```

### 4. Run Verification
After collecting agent reviews, run `make check` to confirm build/test/lint pass.

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

### Agent Summaries
- **Code Review:** [one-line summary]
- **Security:** [one-line summary]
- **Tests:** [one-line summary]
- **Architecture:** [one-line summary]

### Recommended Actions
1. [Highest priority action]
2. [Next priority]
```

### 6. Score
Apply the quality-gates rubric to compute a score. Report the score with gate status:
- Score >= 80: "Ready to commit"
- Score >= 90: "Ready for PR"
- Score >= 95: "Release quality"
