# /fix-bug — Structured Bug Fix Workflow

Systematic approach to diagnosing and fixing bugs with TDD regression testing.

---

## Steps

### Phase 1: Diagnosis

1. **Gather information** — ask the user:
   - What is the expected behavior?
   - What is the actual behavior?
   - Steps to reproduce?
   - When did it start? (recent change? always broken?)
   - Any error messages or logs?

2. **Reproduce the bug** — write a test that demonstrates the failure:
   - The test MUST fail before the fix
   - The test describes the correct behavior
   - Name it clearly: `test_[scenario]_should_[expected_behavior]`

3. **Run the test** — confirm it FAILS for the RIGHT reason

4. **Root cause analysis** — investigate:
   - Read the relevant code
   - Trace the execution path
   - Identify where behavior diverges from expectation
   - Document the root cause (not just the symptom)

### Phase 2: Fix

5. **Plan the fix** — for non-trivial bugs:
   - Save plan to `quality_reports/plans/YYYY-MM-DD_fix-description.md`
   - Describe the root cause and the fix approach
   - Consider: could this bug exist elsewhere? (systematic issue)

6. **Implement the fix** — minimal change that addresses the root cause
   - Fix the root cause, not the symptom
   - Don't refactor unrelated code in the same change

7. **Run the regression test** — confirm it now PASSES

8. **Run full suite** — `make check` — ensure no regressions

### Phase 3: Verification

9. **Review** — run code-reviewer and test-reviewer agents
10. **Verify** — run verifier agent

### Phase 4: Delivery

11. **Present summary:**
    - Root cause explanation
    - What was changed (minimal diff)
    - Regression test added
    - Full suite results

12. **Commit** — with conventional commit message:
    ```
    fix(scope): short description

    Root cause: [explanation]
    Regression test: [test name]

    Closes #[issue]
    ```

## Options
- `/fix-bug [issue number or description]` — start with context
- `/fix-bug` — interactive, asks for bug description
