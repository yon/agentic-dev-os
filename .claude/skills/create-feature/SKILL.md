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

### Phase 2: TDD Red (Write Failing Tests)
5. Write tests that describe the desired behavior
6. Run tests — confirm they **FAIL**
7. **If tests pass, STOP** — the feature already exists or the test is wrong

### Phase 3: TDD Green (Implement)
8. Write minimum code to make tests pass
9. Run tests — confirm they **PASS**

### Phase 4: Refactor
10. Clean up while keeping tests green
11. Run tests after each change

### Phase 5: Verify
12. Run full verification: `make check`

### Phase 6: Review (via subagents)
13. Spawn review subagents using Task tool:
```
Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/code-reviewer.md>\n\nReview: {changed_files}")
```
For API/security-sensitive changes, also spawn:
```
Task(subagent_type="security-code-auditor",
     prompt="<content of .claude/agents/security-reviewer.md>\n\nAudit: {changed_files}")
```

### Phase 7: Fix & Score
14. Address Critical/Major review findings (max 3 rounds)
15. Run `make check` after fixes
16. Present summary with quality score

## Options
- `/create-feature [name]` — start with a named feature
- `/create-feature` — interactive, asks for feature description
