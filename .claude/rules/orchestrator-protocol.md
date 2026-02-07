# Orchestrator Protocol: Contractor Mode

**After a plan is approved, the orchestrator takes over.** It implements, verifies, reviews, fixes, and scores autonomously — presenting results only when the work meets quality standards or fix rounds are exhausted.

The plan-first workflow handles *what and why*. The orchestrator handles *how*, autonomously.

---

## When the Orchestrator Activates

The orchestrator kicks in under these conditions:

1. **After plan approval** — the standard trigger. Plan-first workflow step 7 hands off to the orchestrator.
2. **"Just do it" mode** — when the user says "just do it", "you decide", or "handle it", skip the final presentation gate.
3. **Skill delegation** — when a skill like `/create-feature` or `/refactor` reaches its implementation phase, the orchestrator loop governs execution.

The orchestrator does NOT activate for:

- Single-file trivial edits (typo fix, rename a variable)
- Purely informational questions
- Running a standalone skill like `/build` or `/test`

---

## The Orchestrator Loop

```
Plan approved → orchestrator activates
  │
  Step 1: WRITE TESTS — Write failing tests first (TDD red phase)
  │
  Step 2: IMPLEMENT — Write minimum code to pass tests (TDD green phase)
  │
  Step 3: REFACTOR — Clean up while keeping tests green (TDD refactor phase)
  │
  Step 4: VERIFY — Run verifier (make check: build + test + lint + typecheck)
  │         If verification fails → fix errors → re-verify
  │
  Step 5: REVIEW — Select and run review agents (see Agent Selection)
  │
  Step 6: FIX — Apply fixes from reviews (Critical → Major → Minor)
  │
  Step 7: RE-VERIFY — Run make check again to confirm fixes are clean
  │
  Step 8: SCORE — Apply quality-gates rubric
  │
  └── Score >= threshold?
        YES → Present summary to user
        NO  → Loop back to Step 5 (max 5 review-fix rounds)
              After max rounds → present summary with remaining issues
```

### Agent Selection

Select review agents based on **the nature of changes made during implementation**:

| Change Type | Agents to Run | Parallel? |
|-------------|---------------|-----------|
| Application logic | code-reviewer, test-reviewer | Yes |
| API endpoints/interfaces | code-reviewer, security-reviewer, doc-reviewer | Yes |
| Database/data layer | code-reviewer, security-reviewer, performance-reviewer | Yes |
| Infrastructure/config | security-reviewer, architecture-reviewer | Yes |
| New module/service | architecture-reviewer, code-reviewer, test-reviewer | Yes |
| Performance-critical | performance-reviewer, code-reviewer | Yes |
| Public API/docs | doc-reviewer, code-reviewer | Yes |

**Always run independent agents in parallel.** If an agent finds critical issues, fix them before running the next round.

---

## Fix Priority and Loop Limits

Within each fix round, apply fixes in strict order:

1. **Critical** — build failures, test failures, security vulnerabilities, type errors
2. **Major** — missing tests, architectural violations, performance regressions, lint errors
3. **Minor** — style, naming, documentation gaps

### Limits

- **Main loop:** max 5 review-fix rounds
- **Verification retries:** max 2 attempts per verification step
- After max rounds, present what remains. Never loop indefinitely.

---

## The Summary

When the loop completes (score >= threshold or max rounds), present a structured summary:

```
## Orchestrator Summary

**Task:** [from the plan]
**Quality Score:** [N]/100 (threshold: [80/90])
**Review Rounds:** [N]

### Files Created/Modified
- `path/to/file` — [what changed]

### Tests
- [N] tests written, [N] passing, [N] failing

### Issues Found and Fixed
- [N] critical, [N] major, [N] minor resolved

### Remaining Issues (if any)
- [List with severity]

### Recommended Next Steps
- [e.g., "Run /security-audit for deeper analysis"]
```

Append the summary to the session log (Rule 5b of plan-first-workflow).

---

## "Just Do It" Mode

When the user signals blanket approval ("just do it", "you decide", "handle it"):

1. Skip the final presentation gate — do not pause for approval after the summary
2. Auto-commit if score >= 80 with a descriptive commit message
3. Still run the full verify-review-fix loop (quality is non-negotiable)
4. Still log everything to the session log
5. Still present the summary (the user should see what was done), but do not wait for approval to continue

"Just do it" does NOT skip the orchestrator loop itself — verification and review still happen. It only skips the approval pause at the end.
