---
paths:
  - "src/**"
  - "tests/**"
---

# Task Completion Verification Protocol

**At the end of EVERY task that creates or modifies code, Claude MUST verify the output works correctly.** This is non-negotiable. A Stop hook enforces this automatically.

---

## Verification Checklist

### 1. Build Verification
- [ ] Run `make build` — must complete with zero errors
- [ ] All compilation warnings addressed or documented
- [ ] No new deprecation warnings introduced

### 2. Test Verification
- [ ] Run `make test` — all tests must pass
- [ ] New code has corresponding tests (written FIRST per TDD)
- [ ] No previously passing tests now fail (regression check)
- [ ] Tests actually test behavior, not implementation details

### 3. Lint Verification
- [ ] Run `make lint` — zero errors, zero new warnings
- [ ] Code follows project formatting conventions
- [ ] No disabled lint rules without justification

### 4. Type Check Verification (if applicable)
- [ ] Run `make typecheck` — zero errors
- [ ] No use of escape hatches (`any`, `as unknown`, `// @ts-ignore`) without justification
- [ ] New types are properly defined and exported

### 5. Security Verification (for sensitive changes)
- [ ] No hardcoded credentials, API keys, or secrets
- [ ] No new dependencies with known vulnerabilities
- [ ] Input validation at system boundaries
- [ ] No SQL injection, XSS, or command injection vectors

### 6. Integration Verification (if applicable)
- [ ] Run `make test-int` if integration tests exist
- [ ] External service interactions use proper error handling
- [ ] Database migrations run cleanly (up and down)

---

## The Quick Path

For most tasks, run:

```bash
make check
```

This runs build + test + lint + typecheck in sequence. If `make check` passes, verification is complete for commit-level quality.

---

## Common Pitfalls

| Pitfall | What Goes Wrong | Prevention |
|---------|----------------|------------|
| "Tests pass locally" | Environment-specific assumptions | Use CI-equivalent commands |
| New dependency not declared | Build works because of cached install | Run `make clean && make deps && make build` |
| Tests pass but don't test anything | Empty test bodies, no assertions | Review agent checks for this |
| Lint passes but format is wrong | Linter and formatter disagree | Run both: `make lint && make format` |
| Build succeeds but runtime fails | Missing runtime config/env vars | Test with production-like config |

---

## Verification by Task Type

| Task Type | Minimum Verification |
|-----------|---------------------|
| New feature | `make check` + new tests green |
| Bug fix | `make check` + regression test added |
| Refactoring | `make check` + no behavior changes in tests |
| Dependency update | `make clean && make deps && make check` |
| Config change | `make build` + affected integration tests |
| Documentation only | Markdown renders correctly, links valid |
| CI/CD change | Pipeline runs successfully |

---

## When Verification Fails

1. **Do NOT present the task as complete.** The Stop hook will catch this.
2. **Fix the failing check** — read the error output carefully.
3. **Re-run verification** — confirm the fix doesn't break anything else.
4. **If stuck after 2 attempts** — report the failure to the user with full error output.

Never suppress errors, skip tests, or disable lint rules to make verification pass.
