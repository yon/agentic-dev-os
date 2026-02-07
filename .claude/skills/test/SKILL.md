# /test — Run Test Suite

Run the project's test suite and report results.

---

## Steps

1. Determine scope:
   - `/test` → `make test` (full suite)
   - `/test unit` → `make test-unit` (unit tests only)
   - `/test int` or `/test integration` → `make test-int` (integration tests only)
   - `/test e2e` → `make test-e2e` (end-to-end tests only)
   - `/test [specific file or pattern]` → run tests matching the pattern
2. Run the appropriate command
3. Report results

## Output

```
Test Results:
- Total: [N]
- Passed: [N] ✓
- Failed: [N] ✗
- Skipped: [N] -
- Duration: [N]s
```

## On Failure
1. Show failing test names and error messages
2. For each failing test:
   - Show the assertion that failed
   - Show expected vs actual values
   - Analyze the likely cause
3. Suggest fixes (but do NOT apply them without permission)

## TDD Mode
- `/test watch` — suggest running the watch mode command for TDD workflow
- Show the appropriate command for the project's test runner
