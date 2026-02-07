---
paths:
  - "src/**"
  - "tests/**"
---

# Code Conventions

**Consistency reduces cognitive load. These conventions apply project-wide.**

<!-- ============================================================
     HOW TO USE: Customize the [PLACEHOLDER] sections below
     for your specific language and framework.
     ============================================================ -->

---

## Naming

### General Rules
- Names should reveal intent — `calculate_order_total` not `calc` or `process`
- Avoid abbreviations unless universally understood (`id`, `url`, `http`)
- Boolean names should read as questions: `is_valid`, `has_permission`, `can_delete`
- Collection names should be plural: `users`, `order_items`, `pending_tasks`
- Functions that return values are named for what they return: `get_user`, `find_orders`
- Functions that perform actions are named for what they do: `send_email`, `delete_account`

### Conventions by Element
<!-- Customize for your language. Examples below. -->

| Element | Convention | Example |
|---------|-----------|---------|
| Variables/functions | [snake_case / camelCase] | `user_count` / `userCount` |
| Classes/types | [PascalCase] | `OrderService` |
| Constants | [UPPER_SNAKE_CASE] | `MAX_RETRY_COUNT` |
| File names | [snake_case / kebab-case] | `order_service.py` / `order-service.ts` |
| Test files | [test_ prefix / .test suffix] | `test_order.py` / `order.test.ts` |

---

## File Organization

### Structure Within a File
```
1. Module docstring / file header (brief — what this module does)
2. Imports (stdlib → third-party → local, separated by blank lines)
3. Constants
4. Type definitions / interfaces
5. Main class or function definitions
6. Helper / private functions
7. Module-level code (if any — prefer entrypoints)
```

### Module Organization
- One primary concern per file
- Group related files in directories with clear names
- Keep nesting shallow (max 3-4 directory levels)
- Index/barrel files for clean public APIs (if language supports it)

---

## Functions

### Guidelines
- **Short** — aim for < 30 lines, hard limit at 50
- **Single purpose** — does one thing, named for that thing
- **Few parameters** — 0-3 is ideal, > 5 is a smell (use a config object/struct)
- **Pure when possible** — same input → same output, no side effects
- **No side effects in names that don't suggest them** — `get_user()` must not send email

### Error Handling
- Return errors explicitly (`Result`, `Either`, error returns) — don't rely on exceptions for control flow
- Handle errors at the appropriate level — don't catch and re-throw without adding context
- Use custom error types for domain errors — not generic strings
- Log errors with context (what was being attempted, with which inputs)

---

## Comments

### When to Comment
- **Why**, not what — the code says what, comments say why
- Complex algorithms — explain the approach before the code
- Business rules — link to the requirement or ticket
- Workarounds — explain what's being worked around and when it can be removed
- Public APIs — document the contract (params, returns, errors, examples)

### When NOT to Comment
- Obvious code — `i++ // increment i` adds noise
- Instead of refactoring — if code needs a comment to explain WHAT it does, rewrite the code
- Commented-out code — delete it. Git remembers.
- TODO without a ticket — `// TODO fix this` is a lie. Use `// TODO(#123): fix race condition in session cleanup`

---

## Error Handling Patterns

### Preferred Pattern (by language type)

**For languages with Result types (Rust, Go, functional):**
```
// Return errors explicitly, handle at the caller
fn get_user(id: UserId) -> Result<User, UserError>
```

**For languages with exceptions (Python, Java, TypeScript):**
```
// Use exceptions for unexpected failures
// Use Result/Optional for expected failures (not found, validation)
// Never catch generic Exception/Error except at the top-level handler
```

### Anti-Patterns
- **Empty catch blocks** — always handle or re-raise
- **Pokemon exception handling** (`catch Exception`) — catch specific errors
- **Using exceptions for control flow** — use `Optional`/`Result` for expected cases
- **Swallowing errors silently** — log + re-raise, or return an error value

---

## Logging

### Log Levels
| Level | When | Example |
|-------|------|---------|
| ERROR | Something failed that shouldn't | Database connection lost |
| WARN | Something unexpected but handled | Retry succeeded after timeout |
| INFO | Significant business events | User registered, order placed |
| DEBUG | Development diagnostics | Function entry/exit, intermediate values |

### Rules
- **Structured logging** — use key-value pairs, not string interpolation
- **Include context** — request ID, user ID, operation name
- **Never log secrets** — passwords, tokens, PII
- **Log at boundaries** — incoming requests, outgoing responses, external calls

---

## Dependency Management

- **Pin versions** — exact versions in lock files
- **Minimal dependencies** — every dep is a liability. Can you write it in 20 lines instead?
- **Audit before adding** — check maintenance status, security advisories, license
- **Group and document** — separate dev/test/prod dependencies, document why each exists
- **Update regularly** — scheduled dependency updates (weekly or monthly)
