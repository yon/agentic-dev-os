# Git Workflow & Delivery

**Git is the project's memory. Every commit should tell a clear story about what changed and why.**

---

## Branch Strategy

### Branch Naming
```
main                          # Always deployable
feature/[ticket]-description  # New features
fix/[ticket]-description      # Bug fixes
refactor/description          # Refactoring (no behavior change)
chore/description             # Tooling, deps, config
docs/description              # Documentation only
```

### Branch Rules
- `main` is protected — no direct pushes
- All changes go through feature branches → PR → merge
- Branches are short-lived (days, not weeks)
- Delete branches after merge

---

## Commit Messages — Conventional Commits

### Format
```
<type>(<scope>): <short description>

[Optional body — explain WHY, not WHAT]

[Optional footer — BREAKING CHANGE:, Closes #issue]
```

### Types
| Type | When |
|------|------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring with no behavior change |
| `test` | Adding or modifying tests |
| `docs` | Documentation only |
| `chore` | Build, CI, deps, tooling |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace (no logic change) |
| `ci` | CI/CD pipeline changes |

### Examples
```
feat(auth): add JWT token refresh endpoint

Tokens were expiring mid-session, forcing users to re-login.
Adds a /auth/refresh endpoint that issues a new token
using the existing refresh token.

Closes #142

---

fix(cart): prevent negative quantities in line items

Users could enter negative numbers in the quantity field,
resulting in negative order totals. Now validates quantity >= 1
at the domain level.

---

refactor(payments): extract payment gateway interface

Preparing for Stripe-to-Braintree migration. No behavior change.
Payment processing now depends on PaymentGateway protocol
instead of concrete StripeClient.
```

### Rules
- Subject line: imperative mood, < 72 characters, no period
- Body: explain the motivation (why), not the mechanics (what — that's in the diff)
- One logical change per commit — don't mix features with refactoring
- Commits should be atomic — every commit should build and pass tests

---

## Work Decomposition

### Epic → Stories → Tasks

Break large features into a hierarchy:

| Level | Scope | Deliverable | Duration |
|-------|-------|-------------|----------|
| **Epic** | Full feature or capability | Multiple PRs over days/weeks | 1-4 weeks |
| **Story** | One tracer bullet through all layers | One PR, independently deployable | 1-3 days |
| **Task** | One implementation step within a story | One commit or small group of commits | Hours |

### Tracer Bullets Over Horizontal Layers

Each story should cut through all layers rather than completing one layer at a time:

```
GOOD (tracer bullet):                BAD (horizontal layer):
  Story 1: User can register            Story 1: Build all DB schemas
    - DB migration                       Story 2: Build all API endpoints
    - API endpoint                       Story 3: Build all UI pages
    - UI form
    - Tests at each layer

  Story 2: User can login
    - Auth logic
    - API endpoint
    - UI form
    - Tests at each layer
```

Tracer bullets ensure:
- Every story delivers working, testable functionality
- Integration issues surface early
- Each PR is independently reviewable and deployable

### Tracer Bullet First

The first story is always the **tracer bullet** — the simplest possible end-to-end path through the feature. It proves the architecture works before adding complexity.

```
Example: Building a payment system
  Tracer bullet: Charge a fixed $1.00 to a test card
    → DB: orders table with minimal columns
    → API: POST /charges with hardcoded amount
    → UI: Single "Pay" button
    → Tests: One happy-path integration test

  Subsequent bullets add:
    → Variable amounts, currency support
    → Error handling, retries, refunds
    → Webhook processing
    → Dashboard and reporting
```

---

## PR Size Discipline

### Targets

| Metric | Target | Hard Limit |
|--------|--------|------------|
| Files changed | < 10 | 15 |
| Lines changed | < 300 | 500 |
| Review time | < 30 min | 60 min |

### If a PR Is Too Large

1. Decompose into smaller tracer bullets
2. Extract refactoring into a separate PR (no behavior change)
3. Split tests into their own PR if they don't require code changes
4. Use feature flags to merge incomplete features safely

### Each PR Should Be

- **Independently reviewable** — reviewer doesn't need context from other PRs
- **Independently deployable** — deploying this PR alone doesn't break anything
- **Independently revertable** — can be reverted without affecting other work

---

## Stacking PRs

For features that require multiple stories:

```
main ← PR 1 (tracer bullet) ← PR 2 (error handling) ← PR 3 (edge cases)
```

- Each PR builds on the previous one
- Each is independently deployable
- Each represents one tracer bullet
- Review and merge sequentially — don't let the stack grow beyond 3-4 deep
- Rebase subsequent PRs after merge

---

## Pre-Commit Checklist

Before every commit:
1. `make check` passes (build + test + lint + typecheck)
2. No unintended files staged (`git status`)
3. No secrets or credentials (`git diff --staged` reviewed)
4. Commit message follows conventional format
5. Tests for new/changed behavior are included

---

## Pull Request Protocol

### Before Creating a PR
1. Rebase on latest `main` — resolve conflicts locally
2. Run `make check` — all green
3. Run `/review` — multi-agent code review
4. Squash fixup commits — clean, atomic history
5. Write a clear PR description

### PR Description Template
```markdown
## Summary
[1-3 bullet points — what and why]

## Changes
- [File/module changed] — [what changed]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing performed (describe)

## Security
- [ ] No new secrets or credentials
- [ ] Input validation at boundaries
- [ ] No new security warnings

## Breaking Changes
[List any breaking changes, or "None"]
```

### Merge Strategy
- **Squash and merge** for feature branches (clean main history)
- **Regular merge** for release branches (preserve branch history)
- **Never force push** to `main`

---

## Hotfix Protocol

For urgent production fixes:
1. Branch from `main`: `fix/urgent-description`
2. Write a regression test that reproduces the issue
3. Fix with minimal changes
4. `make check` — all green
5. PR with expedited review
6. Merge and deploy immediately
7. Follow up with a postmortem if appropriate
