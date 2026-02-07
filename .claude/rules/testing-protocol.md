---
paths:
  - "src/**"
  - "tests/**"
---

# Testing Protocol — TDD-First Development

**Tests are not an afterthought. Tests are the FIRST code written for every feature and bug fix.**

---

## The TDD Cycle (Red-Green-Refactor)

Every implementation follows this cycle:

### 1. RED — Write a Failing Test
- Write a test that describes the desired behavior
- Run it — confirm it FAILS (if it passes, the test is wrong or the feature already exists)
- The test name should read like a specification: `test_user_cannot_login_with_expired_token`

### 2. GREEN — Write Minimum Code to Pass
- Write the simplest code that makes the test pass
- Do NOT add extra functionality, error handling, or edge cases yet
- "Make it work" before "make it right"

### 3. REFACTOR — Clean Up While Green
- Improve the code structure while keeping all tests green
- Extract functions, rename variables, remove duplication
- Run tests after every refactoring step

### Repeat
- Add the next test (next behavior, next edge case)
- Continue the cycle until all acceptance criteria are met

---

## Test Structure

### Naming Convention

Tests should describe behavior, not implementation:

```
# GOOD — describes behavior
test_empty_cart_returns_zero_total
test_discount_applies_when_coupon_is_valid
test_api_returns_404_when_user_not_found

# BAD — describes implementation
test_calculate_method
test_discount_function
test_get_user
```

### Arrange-Act-Assert (AAA) / Given-When-Then

Every test follows this structure:

```
# Arrange (Given) — set up preconditions
# Act (When) — execute the behavior under test
# Assert (Then) — verify the expected outcome
```

Each section should be visually separated. One act and one logical assertion per test.

---

## Test Categories

### Unit Tests (`tests/unit/`)
- Test individual functions, classes, or modules in isolation
- Dependencies are mocked/stubbed
- Must be **fast** (< 100ms per test, entire suite < 10s)
- Must be **deterministic** (no randomness without seeding, no external deps)
- Must be **independent** (no shared mutable state between tests)
- Run on every commit: `make test-unit`

### Integration Tests (`tests/integration/`)
- Test interactions between components (DB, APIs, message queues)
- Use real dependencies or close approximations (testcontainers, in-memory DBs)
- Slower is acceptable, but still aim for < 1s per test
- Test realistic scenarios, not individual methods
- Run before PR: `make test-int`

### End-to-End Tests (`tests/e2e/`)
- Test the system from the user's perspective
- Use the actual deployment target (or staging environment)
- Focus on critical user journeys, not comprehensive coverage
- Fewest in number (test pyramid: many unit, some integration, few E2E)
- Run before release: `make test-e2e`

---

## What MUST Be Tested

### Always Test
- **Happy path** — the normal successful case
- **Edge cases** — empty inputs, zero values, boundary conditions, max lengths
- **Error paths** — what happens when things go wrong (invalid input, timeouts, failures)
- **Business rules** — any conditional logic that affects outcomes
- **State transitions** — when an entity changes state, verify pre/post conditions

### Test for Every Bug Fix
- **Regression test FIRST** — before fixing the bug, write a test that reproduces it
- The test must FAIL before the fix and PASS after
- This prevents the bug from ever returning

### What NOT to Test
- Framework/library internals (trust your dependencies)
- Private methods directly (test them through public interfaces)
- Trivial getters/setters with no logic
- Generated code (test the generator or the output behavior, not the generated code itself)

---

## Test Quality Standards

### A Test Is Good If
- It fails when the behavior it tests is broken
- It passes when the behavior is correct
- It tests ONE behavior (single reason to fail)
- It's readable as documentation of that behavior
- It runs fast and deterministically
- It doesn't depend on other tests or execution order

### A Test Is Bad If
- It never fails (useless — delete it)
- It tests implementation details (brittle — refactor it)
- It has multiple assertions testing different behaviors (split it)
- It requires complex setup that obscures intent (simplify it)
- It uses sleep/wait for timing (use proper async patterns)
- It depends on global state or test execution order (isolate it)

---

## Mocking Guidelines

### When to Mock
- External services (HTTP APIs, databases in unit tests, message queues)
- Time-dependent behavior (`now()`, timers, schedulers)
- Non-deterministic behavior (random numbers, UUIDs)
- Expensive operations (file I/O in unit tests, network calls)

### When NOT to Mock
- The code under test (obvious, but happens)
- Simple value objects or data structures
- In integration tests (use real or close-to-real deps)
- Everything — if you mock everything, you're testing mocks, not code

### Mock Hygiene
- Verify mock interactions only when the INTERACTION is the behavior you're testing
- Prefer stubs (return canned data) over mocks (verify calls) when possible
- Reset/clean up mocks between tests

---

## Coverage Guidelines

- **Target:** 80%+ line coverage for application code (not tests, configs, or generated code)
- **Focus on behavior coverage** over line coverage — 100% line coverage with weak assertions is worthless
- **Critical paths:** 100% coverage for authentication, authorization, payment, and data mutation logic
- **View coverage as a floor, not a ceiling** — high coverage doesn't mean good tests, but low coverage means missing tests

---

## Test Performance

- **Unit test suite:** Must complete in < 30 seconds
- **Integration test suite:** Must complete in < 5 minutes
- **Parallelize:** Tests should be independent and safe to run in parallel
- **No external dependencies in unit tests:** If a unit test touches the network or filesystem, it's an integration test in disguise

---

## TDD for Bug Fixes — Special Protocol

1. **Reproduce:** Write a test that demonstrates the bug (must FAIL)
2. **Verify the test:** Run the test — confirm it fails for the RIGHT reason
3. **Fix:** Write the minimal code change to fix the bug
4. **Verify the fix:** Run the test — confirm it now PASSES
5. **Run full suite:** Confirm no regressions: `make test`
6. **Commit the test WITH the fix** — they travel together, always
