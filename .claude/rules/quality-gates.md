---
paths:
  - "src/**"
  - "tests/**"
  - "*.py"
  - "*.ts"
  - "*.js"
  - "*.go"
  - "*.rs"
---

# Quality Gates & Scoring Rubrics

**Purpose:** Define objective quality thresholds for committing, merging, and releasing software.

---

## Scoring System

- **80/100 = Commit threshold** — Good enough to save progress
- **90/100 = PR/Merge threshold** — High quality, ready for code review and merge
- **95/100 = Release threshold** — Production-ready, fully validated

---

## Source Code

### Critical (Must Pass for Commit)
| Issue | Deduction |
|-------|-----------|
| Build failure | -100 (auto-fail) |
| Test failure | -100 (auto-fail) |
| Type check error | -20 per error |
| Security vulnerability (high/critical) | -25 per finding |
| Lint error (not warning) | -5 per error |

### Major (Should Pass for PR)
| Issue | Deduction |
|-------|-----------|
| Missing tests for new code | -10 per uncovered function |
| Test coverage below threshold | -5 per 5% below target |
| Missing error handling at boundaries | -5 per instance |
| Hardcoded secrets/credentials | -25 (auto-fail if committed) |
| Mutable shared state without synchronization | -10 per instance |
| God function (> 50 lines) | -3 per function |
| Deep nesting (> 3 levels) | -2 per instance |

### Minor (Nice-to-Have for Excellence)
| Issue | Deduction |
|-------|-----------|
| Missing docstring on public API | -1 per function |
| Inconsistent naming convention | -1 per instance |
| TODO/FIXME/HACK without ticket reference | -1 per instance |
| Magic numbers without named constants | -1 per instance |

---

## Test Code

### Critical
| Issue | Deduction |
|-------|-----------|
| Test that never fails (always passes) | -15 per test |
| Test with no assertions | -10 per test |
| Test that depends on external state | -10 per test |

### Major
| Issue | Deduction |
|-------|-----------|
| Missing edge case coverage | -5 per gap |
| Test names don't describe behavior | -2 per test |
| Test setup/teardown leaks state | -5 per instance |
| Missing negative/error path tests | -5 per function |

---

## Engineering Principles Compliance

### Violations (deducted from score)
| Principle Violated | Deduction |
|-------------------|-----------|
| DRY — duplicated logic (> 10 lines identical) | -5 per instance |
| KISS — unnecessary abstraction layer | -3 per instance |
| SOLID — class/module with multiple responsibilities | -3 per instance |
| Immutability — unnecessary mutation of shared state | -5 per instance |
| DI — hardcoded dependency instead of injection | -3 per instance |
| Strong typing — use of `any` / `interface{}` / raw strings for types | -2 per instance |

---

## Quality Gate Enforcement

### Commit Gate (score < 80)
Block commit. List blocking issues with required actions.

### PR Gate (score < 90)
Allow commit but warn. List issues with recommendations to reach PR quality.

### Release Gate (score < 95)
Allow PR but flag. List remaining polish items for release readiness.

### User can override with justification when needed.

---

## TDD Compliance Bonus

| Practice | Bonus |
|----------|-------|
| Tests written before implementation (visible in git history) | +5 |
| All public functions have corresponding tests | +3 |
| Edge cases and error paths tested | +2 |
| Test names follow Given/When/Then or equivalent pattern | +1 |

Maximum bonus: +10 (score capped at 100).
