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

---

## Team-Based Orchestration

When a plan contains **parallelizable subtasks with clear file ownership**, the orchestrator may use agent teams instead of sequential execution.

### When to Use Team Mode

Use team mode when the plan has:
- **3+ independent subtasks** that touch different files/modules
- **Clear file ownership** — each subtask's files don't overlap with others
- **Estimated combined time > 15 minutes** — the coordination overhead must be worth it

Do NOT use team mode when:
- Subtasks share files or have tight coupling
- The task is small enough for sequential execution
- You haven't verified the plan's file ownership is conflict-free

### Team Orchestrator Loop

```
Plan approved → orchestrator evaluates parallelizability
  │
  ├── NOT parallelizable → Standard sequential loop (above)
  │
  └── Parallelizable → Team mode
        │
        Step 1: PARTITION — Split plan into teammate assignments
        │       Each teammate gets: files they own, acceptance criteria, tests to write
        │
        Step 2: SPAWN TEAM — Create teammates with clear prompts
        │       Each teammate runs their own TDD mini-loop:
        │       write tests → implement → refactor → verify their portion
        │
        Step 3: MONITOR — Track progress via task list
        │       Intervene only if a teammate is blocked
        │
        Step 4: COLLECT — Gather results from all teammates
        │
        Step 5: INTEGRATE VERIFY — Run make check on the combined result
        │       If integration fails → identify which teammate's work broke it
        │       → message that teammate to fix → re-verify
        │
        Step 6: TEAM REVIEW — Spawn review team (see below)
        │
        Step 7: FIX — Apply fixes (lead coordinates, delegates to teammates if needed)
        │
        Step 8: FINAL VERIFY — Run make check one last time
        │
        Step 9: CLEANUP — Tear down the team
        │
        Step 10: SCORE — Apply quality-gates rubric
        │
        └── Score >= threshold?
              YES → Present summary
              NO  → Fix remaining issues (lead handles, no re-spawn)
```

### Team Review (Step 6)

Instead of running review agents as subagents, spawn a **review team**:

```
Lead spawns review team:
  ├── Teammate: Security reviewer (reads all changed files for security issues)
  ├── Teammate: Architecture reviewer (reads module structure and boundaries)
  ├── Teammate: Test reviewer (reads test suite quality and coverage)
  └── Teammate: Code reviewer (reads code quality and principles compliance)

Review teammates work in parallel → send findings to lead
Lead merges findings into single report → prioritizes fixes
```

This is faster than sequential subagent reviews because all reviewers work simultaneously with full context windows.

### Adversarial Implementation Mode

For high-stakes code (security, financial, data integrity), use the adversarial pair pattern:

```
Lead spawns:
  ├── Implementer — writes code following the plan
  └── Critic — reviews implementer's work, finds issues

Loop (max 5 rounds):
  1. Implementer writes/fixes → messages Critic "ready"
  2. Critic reviews → messages Implementer with issues
  3. Repeat until Critic approves

Rules:
  - Critic CANNOT edit files (read-only)
  - Implementer CANNOT approve their own work
  - Lead runs final make check after Critic approves
```

### Team Summary Extension

When team mode is used, extend the orchestrator summary:

```
## Orchestrator Summary

**Mode:** Team (N teammates)
**Task:** [from the plan]
**Quality Score:** [N]/100 (threshold: [80/90])
**Review Rounds:** [N]

### Team Assignments
- Teammate A: [scope] — [files owned] — [status]
- Teammate B: [scope] — [files owned] — [status]

### Integration
- File conflicts: [none / resolved]
- Combined verification: PASS/FAIL

[... rest of standard summary ...]
```
