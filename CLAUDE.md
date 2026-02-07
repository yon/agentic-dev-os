# CLAUDE.MD — Software Project Development with Claude Code

<!-- ============================================================
     HOW TO USE THIS TEMPLATE:
     1. Replace all [BRACKETED PLACEHOLDERS] with your project info
     2. Delete sections that don't apply to your project
     3. Add domain-specific sections as needed
     4. This file is read by Claude at the start of every session
     ============================================================ -->

**Last Updated:** [DATE]
**Project:** [YOUR PROJECT NAME]
**Language/Stack:** [e.g., Python 3.12 / TypeScript 5.x / Go 1.22 / Rust 1.77]
**Working Branch:** main

---

## Quick Reference: Available Skills & Agents

| Command | What It Does |
|---------|-------------|
| `/build` | Build the project (compile, bundle, or package) |
| `/test [scope]` | Run test suite — unit, integration, or all |
| `/lint [files]` | Run linters, formatters, and static analysis |
| `/review [files]` | Combined multi-agent code review (6 dimensions) |
| `/security-audit [scope]` | Security review: OWASP, deps, secrets, permissions |
| `/deploy [env]` | Deploy to target environment (staging/production) |
| `/create-feature [name]` | Full feature creation workflow with planning |
| `/fix-bug [issue]` | Structured bug fix workflow with root cause analysis |
| `/refactor [scope]` | Safe refactoring with test-first verification |
| `/team-review [scope]` | Parallel agent team code review (each reviewer in own session) |
| `/team-implement [plan]` | Parallel agent team implementation with adversarial review |
| `/swarm [task]` | General-purpose agent team orchestration |

**Agents** (available for delegation): `code-reviewer`, `security-reviewer`, `architecture-reviewer`, `test-reviewer`, `performance-reviewer`, `doc-reviewer`, `verifier`, `team-lead`

**Rules** (auto-loaded): See `.claude/rules/` for rules on planning, quality gates, testing, security, code conventions, engineering principles, git workflow, verification, and agent teams.

---

## Project Overview

<!-- Describe your project in 2-3 paragraphs. What is it? Who is it for? What problem does it solve? -->

[DESCRIBE YOUR PROJECT HERE]

### Tech Stack

<!-- List your specific technologies. Examples below — replace with yours. -->

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | [e.g., Python / TypeScript / Go / Rust] | [version] |
| Framework | [e.g., FastAPI / Next.js / Gin / Axum] | [version] |
| Database | [e.g., PostgreSQL / Redis / SQLite] | [version] |
| Testing | [e.g., pytest / vitest / go test] | [version] |
| Linting | [e.g., ruff / eslint / golangci-lint / clippy] | [version] |
| CI/CD | [e.g., GitHub Actions / GitLab CI] | — |
| Packaging | [e.g., pip / npm / docker] | — |

---

## Folder Structure

```
[YOUR-PROJECT]/
├── CLAUDE.md                          # This file — Claude's project guide
├── Makefile                           # Self-documenting build commands
├── .claude/                           # Claude Code configuration
│   ├── settings.json                  # Project permissions + hooks
│   ├── rules/                         # Engineering rules (auto-loaded)
│   ├── skills/                        # Slash commands (/build, /test, /swarm, etc.)
│   └── agents/                        # Specialized agents (review + team-lead)
├── src/                               # Application source code
│   └── [YOUR STRUCTURE]
├── tests/                             # Test suite
│   ├── unit/                          # Unit tests
│   ├── integration/                   # Integration tests
│   └── e2e/                           # End-to-end tests (if applicable)
├── scripts/                           # Utility and CI scripts
│   └── quality_score.py               # Automated quality scoring (0-100)
├── docs/                              # Project documentation
├── quality_reports/                    # Review & planning artifacts
│   ├── plans/                         # Saved implementation plans
│   └── session_logs/                  # Session history and decision logs
└── [CONFIG FILES]                     # .env.example, pyproject.toml, etc.
```

---

## Working Philosophy

### Collaborative Partnership Approach

Claude serves as your **engineering partner**, not a code generator:

- **You define requirements** — provide specs, context, and constraints
- **Claude proposes designs** — architecture, implementation approach, trade-offs
- **You iterate together** — refine until the solution is right
- **You maintain control** — final decisions always rest with you

### Communication Style

- **Challenge assumptions** — question design choices and explore alternatives
- **Explain trade-offs** — never present a single option without discussing alternatives
- **Correctness over speed** — getting it right matters more than getting it fast
- **Teach while building** — explain the "why" behind engineering decisions

### TDD — Test-Driven Development (MANDATORY)

All implementation follows the **Red-Green-Refactor** cycle:

1. **RED** — Write a failing test that describes the desired behavior
2. **GREEN** — Write the minimum code to make the test pass
3. **REFACTOR** — Clean up while keeping tests green
4. **Repeat** — Next behavior, next test

Tests are not an afterthought. Tests are the FIRST code written for every feature and bug fix. See `.claude/rules/testing-protocol.md` for the full protocol.

### Plan-First Approach

For any non-trivial task, Claude enters **plan mode first** before writing code:

1. **Plan** — draft an approach, list files to modify, identify risks, define tests
2. **Save** — write the plan to `quality_reports/plans/` so it survives context compression
3. **Review** — present the plan and wait for your approval
4. **Test** — write failing tests FIRST (TDD red phase)
5. **Implement** — write minimum code to pass tests (TDD green phase)
6. **Refactor** — clean up while tests stay green

See `.claude/rules/plan-first-workflow.md` for the full protocol.

> **Never use `/clear`.** Rely on auto-compression to manage long conversations. `/clear` destroys all context; auto-compression preserves what matters.

### Contractor Mode (Orchestrator)

After a plan is approved, Claude operates in **contractor mode**: implement, verify (build + test + lint), review with agents, fix issues, and re-verify — all autonomously. The user sees a summary when the work meets quality standards or review rounds are exhausted. See `.claude/rules/orchestrator-protocol.md`.

When you say "just do it", the orchestrator skips the final approval pause and auto-commits if the score is 80+.

### Agent Teams (Parallel Multi-Session)

For tasks that span multiple independent modules, Claude can spawn **agent teams** — multiple independent sessions working in parallel with peer-to-peer communication:

- `/team-review` — spawn parallel reviewers (security + architecture + tests + code) each in their own context window
- `/team-implement` — spawn parallel implementers with adversarial review (implementers ≠ reviewers, always)
- `/swarm` — general-purpose team for research, debugging, or migration

**The Iron Rule of Agent Teams:** The agent that writes the code NEVER approves it. The agent that reviews NEVER edits. This adversarial separation is non-negotiable — it ensures honest, independent quality assessment.

See `.claude/rules/agent-teams.md` for patterns, file ownership rules, and team coordination protocols.

> **Enable agent teams:** Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` in `.claude/settings.json` or as an environment variable.

### Continuous Learning with [LEARN] Tags

When Claude makes a mistake or you correct a misconception, tag the correction:

```
[LEARN:pattern] Don't use singleton here — use dependency injection instead
[LEARN:api] This endpoint expects snake_case, NOT camelCase
[LEARN:test] Always mock the database layer in unit tests, never hit real DB
[LEARN:convention] We use Result<T, E> pattern for errors, not exceptions
```

These corrections persist in `MEMORY.md` across sessions and prevent the same mistake from recurring.

---

## Engineering Principles (MANDATORY)

These principles are non-negotiable. They apply to every line of code written in this project.

### DRY — Don't Repeat Yourself
- Extract shared logic into functions, modules, or shared libraries
- If you find yourself copying code, stop and refactor
- Single source of truth for configuration, constants, and business rules
- **Exception:** Prefer duplication over the wrong abstraction (see KISS)

### KISS — Keep It Simple, Stupid
- The simplest solution that works correctly is the best solution
- Avoid premature abstraction — wait until you see the pattern three times
- Every layer of indirection must justify its existence
- If a junior engineer can't understand it in 5 minutes, simplify it

### SOLID Principles
- **S**ingle Responsibility — each module/class does one thing well
- **O**pen/Closed — extend behavior without modifying existing code
- **L**iskov Substitution — subtypes must be substitutable for their base types
- **I**nterface Segregation — prefer small, focused interfaces over large ones
- **D**ependency Inversion — depend on abstractions, not concretions

### Immutability by Default
- Prefer `const`, `final`, `readonly`, frozen dataclasses, or equivalent
- Mutate only when performance requires it, and document why
- Return new objects instead of modifying inputs
- Use immutable data structures for shared state

### Strong Typing
- Use the type system to make illegal states unrepresentable
- Prefer enums/unions over stringly-typed code
- Define explicit types for domain concepts (not raw `string` or `int`)
- Enable strict mode in your type checker (`strict: true`, `--strict`, etc.)

### Dependency Injection
- Pass dependencies explicitly — never reach into global state
- Use constructor injection (or function parameters) over service locators
- Makes testing trivial: swap real deps for mocks
- Configuration comes from the outside, not from inside the module

### Additional Principles
- **Fail fast** — validate inputs at boundaries, crash early on invalid state
- **Composition over inheritance** — build behavior by combining small pieces
- **Least privilege** — grant minimum necessary permissions and access
- **Explicit over implicit** — no magic, no hidden side effects, no surprises
- **Idempotency** — operations should be safe to retry
- **Separation of concerns** — IO at the edges, pure logic in the core

See `.claude/rules/engineering-principles.md` for detailed enforcement rules.

---

## Quality Gates

| Threshold | When | What It Means |
|-----------|------|--------------|
| **80/100** | Commit | Tests pass, no lint errors, no security issues |
| **90/100** | PR/Merge | High coverage, clean architecture, documented |
| **95/100** | Release | Production-ready, performance validated, fully reviewed |

See `.claude/rules/quality-gates.md` for full scoring rubric.

---

## Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** A Stop hook enforces this automatically.

See `.claude/rules/verification-protocol.md` for the full checklist.

**Quick summary:**
- **Build:** Run `make build`, verify zero errors
- **Tests:** Run `make test`, verify all pass
- **Lint:** Run `make lint`, verify zero warnings
- **Type check:** Run `make typecheck`, verify zero errors (if applicable)
- **Always** run `make check` (runs all of the above) before presenting results

---

## Design Patterns (Preferred)

<!-- Customize this section for your project's patterns -->

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Repository | Data access abstraction | `UserRepository.find_by_id(id)` |
| Strategy | Swappable algorithms | Payment processing backends |
| Observer/Events | Decoupled notifications | Domain events after state changes |
| Builder | Complex object construction | Query builders, config objects |
| Factory | Object creation logic | Creating the right handler by type |
| Circuit Breaker | External service calls | HTTP clients, DB connections |
| Result/Either | Error handling without exceptions | `Result<User, ValidationError>` |

**Anti-patterns to avoid:**
- God objects / god functions (> 200 lines is a smell)
- Service locator (use DI instead)
- Anemic domain model (logic should live with data)
- Stringly-typed interfaces (use enums/types)
- Deep inheritance hierarchies (prefer composition)
- Mutable shared state (prefer message passing or immutable structures)

---

## Makefile Quick Reference

```bash
make help          # Show all available commands with descriptions
make build         # Build the project
make test          # Run full test suite
make test-unit     # Run only unit tests
make test-int      # Run only integration tests
make lint          # Run linters and formatters
make typecheck     # Run type checker
make check         # Run all checks (build + test + lint + typecheck)
make clean         # Remove build artifacts
make deps          # Install/update dependencies
make security      # Run security audit
make coverage      # Generate test coverage report
make deploy-staging    # Deploy to staging
make deploy-production # Deploy to production (requires confirmation)
```

---

## Git Workflow

- **Main branch:** `main` — always deployable
- **Feature branches:** `feature/[ticket]-short-description`
- **Bug fix branches:** `fix/[ticket]-short-description`
- **Commit style:** Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`)
- **Before every PR:** Run `make check` and `/review`
- **Merge strategy:** Squash and merge for features, regular merge for releases

See `.claude/rules/git-workflow.md` for the full protocol.

---

## Session Startup Ritual

Start each session with:

```
Claude, please:
1. Read CLAUDE.md to understand our workflow
2. Check recent git commits to see what changed
3. Check quality_reports/plans/ for any in-progress plans
4. Check quality_reports/session_logs/ for the most recent session log
5. Look at the code area we're working on
6. State what you understand our goals to be
```

### Session End Protocol

Before ending a session:
1. Save a session log to `quality_reports/session_logs/YYYY-MM-DD_description.md`
2. Commit significant changes with descriptive messages
3. Update CLAUDE.md if workflow changed
4. Note any unresolved questions in the session log

---

## Current Project State

<!-- Update this table as you develop your project -->

| Component | Status | Key Notes |
|-----------|--------|-----------|
| [Component 1] | [Not started / In progress / Done] | [Brief description] |
| [Component 2] | [Not started / In progress / Done] | [Brief description] |

---

**Ready to begin? Start by customizing this CLAUDE.md for your project, then run `make help` to see available commands!**
