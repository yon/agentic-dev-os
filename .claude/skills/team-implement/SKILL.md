# /team-implement — Parallel Agent Team Implementation

Spawn a team of implementers to build a feature in parallel, followed by adversarial review. Each implementer owns specific files and runs their own TDD cycle.

**Requires an approved plan.** If no plan exists, enter plan mode first.

---

## When to Use

- Feature spans **3+ independent modules** (API + service + repository, frontend + backend + tests)
- Task can be **partitioned by file ownership** with no shared-file conflicts
- Combined sequential implementation would take **> 20 minutes**
- The plan clearly identifies **which files belong to which subtask**

## When NOT to Use

- Tasks with tight coupling between subtasks
- When file ownership can't be cleanly separated
- Small features (1-2 files) — sequential is faster
- When you're unsure what files will be touched (explore first)

---

## Steps

### Phase 1: Partition (Lead)

1. **Read the approved plan** — identify subtasks and file ownership
2. **Validate partitioning:**
   - No file appears in two teammate assignments
   - Config files (package.json, go.mod, etc.) are owned by exactly ONE teammate
   - Test files are co-owned with their corresponding source files
3. **Identify dependencies** between subtasks:
   - Task B depends on Task A's interface? → Model as TaskList dependency
   - Shared types needed? → One teammate defines types first, others depend on that task

### Phase 2: Spawn Implementation Team

```
Teammate A (Implementer — Module X):
  Role: Implement [module X] following TDD
  Files: src/module_x/*, tests/unit/test_module_x.*
  Criteria: [acceptance criteria for module X]
  Constraint: Do NOT edit files outside your assignment

Teammate B (Implementer — Module Y):
  Role: Implement [module Y] following TDD
  Files: src/module_y/*, tests/unit/test_module_y.*
  Criteria: [acceptance criteria for module Y]
  Constraint: Do NOT edit files outside your assignment

Teammate C (Integration — Wiring):
  Role: Wire modules together, write integration tests
  Files: src/main.*, tests/integration/*
  Dependencies: Depends on Task A and Task B completing
  Criteria: All modules work together, integration tests pass
```

Each implementer runs their own TDD loop:
1. Write failing tests for their module
2. Implement minimum code to pass
3. Refactor
4. Run their portion of the test suite
5. Message lead when done

### Phase 3: Integration (Lead)

After all implementers complete:

1. **Run `make check`** on the combined result
2. If integration fails:
   - Identify which teammate's code caused the failure
   - Message that teammate with the error and ask for a fix
   - Re-run `make check` after fix
3. If integration passes: proceed to review

### Phase 4: Adversarial Review

**The review team MUST be different agents than the implementation team.**

Spawn a review team (via `/team-review` pattern):
```
Review Teammate A: Code quality + principles review (read-only)
Review Teammate B: Security review (read-only)
Review Teammate C: Test quality review (read-only)
```

Review teammates:
- CANNOT edit files
- Send findings to lead with severity ratings
- Lead routes fixes to the appropriate implementer teammate

### Phase 5: Fix Loop

```
For each finding (Critical → Major → Minor):
  1. Lead sends finding to the implementer that owns the relevant file
  2. Implementer fixes → messages lead "fixed"
  3. Lead runs make check
  4. If more findings remain → repeat (max 5 rounds)
```

### Phase 6: Delivery

1. **Final `make check`** — must pass
2. **Score** — apply quality-gates rubric
3. **Cleanup** — tear down all teams
4. **Present summary** with team details:

```markdown
## Team Implementation Summary

**Mode:** Team Implementation (N implementers + M reviewers)
**Task:** [from plan]
**Quality Score:** [N]/100

### Team Assignments
| Teammate | Role | Files Owned | Status |
|----------|------|-------------|--------|
| A | Implementer (Module X) | src/module_x/* | Complete |
| B | Implementer (Module Y) | src/module_y/* | Complete |
| C | Integration | src/main.*, tests/int/* | Complete |
| D | Code Reviewer (read-only) | — | Reviewed |
| E | Security Reviewer (read-only) | — | Reviewed |

### Adversarial Review
- Review rounds: [N]
- Issues found: [N critical, N major, N minor]
- Issues fixed: [N]
- Remaining: [N or "none"]

### Integration
- File conflicts: none
- Combined verification: PASS
```

---

## The Iron Rules

1. **Implementers NEVER review their own code** — different teammates review
2. **Reviewers NEVER edit code** — they report, implementers fix
3. **No shared file edits** — one owner per file, always
4. **Every implementer runs TDD** — tests first, then implementation
5. **Lead verifies the combined result** — individual "it works" isn't enough
