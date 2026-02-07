# /create-feature — Full Feature Creation Workflow

Guided workflow for creating a new feature following TDD and plan-first principles.

---

## Steps

### Phase 1: Planning
1. **Gather requirements** — ask the user to describe the feature:
   - What should it do? (behavior)
   - What should it NOT do? (constraints)
   - Who uses it? (API consumers, end users)
   - What existing code does it interact with?

2. **Enter plan mode** — draft an implementation plan:
   - Acceptance criteria (user-verifiable outcomes)
   - Tests to write first (TDD)
   - Files to create/modify
   - Step-by-step approach
   - Risks and edge cases
   - Verification steps

3. **Save plan** to `quality_reports/plans/YYYY-MM-DD_feature-name.md`

4. **Present plan** and wait for approval

### Phase 2: Implementation (TDD)

After approval, the orchestrator takes over:

1. **Create feature branch** — `feature/[ticket]-short-description`
2. **Write failing tests** — (RED)
   - Happy path tests
   - Error/edge case tests
   - Integration tests (if applicable)
3. **Run tests** — confirm they FAIL (validates the tests are meaningful)
4. **Write implementation** — minimum code to pass tests (GREEN)
5. **Run tests** — confirm they PASS
6. **Refactor** — clean up while keeping tests green (REFACTOR)
7. **Run full verification** — `make check`

### Phase 3: Review

8. **Run `/review`** — multi-agent code review
9. **Fix issues** — address critical and major findings
10. **Re-verify** — `make check` again

### Phase 4: Delivery

11. **Present summary** — what was built, test results, quality score
12. **Commit** — with conventional commit message (`feat(scope): description`)
13. **Suggest PR creation** — if ready for merge

## Options
- `/create-feature [name]` — start with a named feature
- `/create-feature` — interactive, asks for feature description
