# /refactor — Safe Refactoring Workflow

Restructure code without changing behavior, verified by existing tests.

---

## The Golden Rule of Refactoring

**Behavior must not change.** The test suite is the contract. If tests pass before and after, the refactoring is correct. If tests fail, the refactoring introduced a bug.

---

## Steps

### Phase 1: Assessment

1. **Understand the scope** — what code needs restructuring and why?
   - `/refactor [file or module]` — targeted refactoring
   - `/refactor` — interactive, asks what to improve

2. **Verify test coverage** — run tests and check coverage for the target code:
   - If coverage is adequate: proceed
   - If coverage is low: write characterization tests first
   - **NEVER refactor untested code without adding tests first**

3. **Run baseline** — `make check` must be GREEN before starting

4. **Plan the refactoring** — for non-trivial changes:
   - Save plan to `quality_reports/plans/YYYY-MM-DD_refactor-description.md`
   - List each refactoring step
   - Each step should be independently committable

### Phase 2: Refactoring (Small Steps)

5. **Make one change at a time:**
   - Rename → run tests
   - Extract function → run tests
   - Move to module → run tests
   - Each step: change + verify. Never batch multiple refactorings.

### Phase 3: Review

6. **Full verification** — `make check` must still be GREEN
7. **Spawn review subagents** using the Task tool:
```
Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/architecture-reviewer.md>\n\n
     Review this refactoring for structural improvements:\n{changed_files}\n
     Verify no behavior changes leaked in.")

Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/code-reviewer.md>\n\n
     Review this refactoring for quality improvements:\n{changed_files}\n
     Verify the refactoring follows DRY/KISS/SOLID principles.")
```

8. **Diff review** — ensure NO behavior changes leaked in

### Phase 4: Delivery

9. **Present summary:**
    - What was refactored and why
    - Before/after comparison (structure, not behavior)
    - All tests still passing
    - Quality improvements achieved

10. **Commit** — with conventional commit message:
    ```
    refactor(scope): short description

    No behavior changes. All existing tests pass.
    [Brief explanation of structural improvement]
    ```

## Rules
- **Tests must pass at every step** — not just at the end
- **No feature additions** — refactoring and features are separate commits
- **No bug fixes** — if you find a bug, note it, finish refactoring, then fix separately
- **Commit after each logical step** — so you can revert one step without losing all work
