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
   - If coverage is low: write characterization tests first (tests that describe current behavior, even if imperfect)
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
   - Change data structure → run tests
   - Each step: change + verify. Never batch multiple refactorings.

6. **Common refactoring patterns:**

| Pattern | When | Steps |
|---------|------|-------|
| Extract Function | Long function, duplicated code | Identify, extract, name, verify |
| Extract Module | File with multiple responsibilities | Identify boundary, move, update imports, verify |
| Rename | Misleading or unclear name | Rename all references, verify |
| Replace Conditional with Polymorphism | Complex if/switch chains | Extract interface, implement variants, verify |
| Introduce Parameter Object | Function with > 4 params | Create type, replace params, verify |
| Replace Inheritance with Composition | Deep hierarchy | Extract interface, compose, verify |
| Simplify | Overly complex code | Identify unnecessary complexity, simplify, verify |

### Phase 3: Verification

7. **Full verification** — `make check` must still be GREEN
8. **Run architecture-reviewer** — verify structural improvements
9. **Run code-reviewer** — verify quality improvements
10. **Diff review** — ensure NO behavior changes leaked in

### Phase 4: Delivery

11. **Present summary:**
    - What was refactored and why
    - Before/after comparison (structure, not behavior)
    - All tests still passing
    - Quality improvements achieved

12. **Commit** — with conventional commit message:
    ```
    refactor(scope): short description

    No behavior changes. All existing tests pass.
    [Brief explanation of structural improvement]
    ```

## Rules
- **Tests must pass at every step** — not just at the end
- **No feature additions** — refactoring and features are separate commits
- **No bug fixes** — if you find a bug while refactoring, note it, finish the refactoring, then fix the bug separately
- **Commit after each logical step** — so you can revert one step without losing all work
