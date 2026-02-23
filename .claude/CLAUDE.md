# CLAUDE.MD — Agentic Development Framework

<!-- ============================================================
     HOW TO USE THIS TEMPLATE:
     1. Replace all [BRACKETED PLACEHOLDERS] with your project info
     2. Delete sections that don't apply to your project
     3. Add domain-specific sections as needed
     4. This file (.claude/CLAUDE.md) is read by Claude at the start of every session
     5. Copy MEMORY.md to your auto-memory directory (see MEMORY.md for path)
     ============================================================ -->

**Last Updated:** [DATE]
**Project:** [YOUR PROJECT NAME]
**Language/Stack:** [e.g., Python 3.12 / TypeScript 5.x / Rust 1.77]
**Working Branch:** main

> 9 rules auto-loaded from `.claude/rules/` — see rules table below
> Behavioral rules and subagent patterns: MEMORY.md (auto-loaded in system prompt)

---

## The Development Loop

Every task follows this loop. Skills, rules, and agents map to specific stages.

```
UNDERSTAND → PLAN → VALIDATE → BUILD → VERIFY → REVIEW → SHIP → OBSERVE
     ↑                                                              |
     └──────────────────────────────────────────────────────────────┘
```

| Stage | What Happens | Skills | Rule |
|-------|-------------|--------|------|
| **Understand** | Read `.context.md`, explore codebase | `/explore-module` | code-conventions |
| **Plan** | Decompose into tracer bullets | `/decompose` | workflow |
| **Validate** | Agents review the plan | `/review-plan` | workflow |
| **Build** | TDD, one tracer bullet at a time | `/create-feature`, `/fix-bug`, `/refactor` | testing-protocol |
| **Verify** | Linters as law, tests as contract | `/lint`, `/test` | quality-and-verification |
| **Review** | Multi-agent code review | `/review`, `/team-review` | agent-coordination |
| **Ship** | Small PR, one tracer bullet per PR | `/deploy` | git-and-delivery |
| **Observe** | Tracing, context-rich outputs | — | code-conventions |

**Always-on**: engineering-principles, security-practices

---

## Two Foundational Behaviors

### 1. Module State Files (`.context.md`)
Every module maintains a `.context.md` — Claude reads this FIRST instead of exploring. Updated after every implementation phase. See `code-conventions.md` for the template.

### 2. Worktree Enforcement
All non-trivial work happens in git worktrees. `/create-feature`, `/fix-bug`, `/refactor` start with `EnterWorktree()`. Each worktree = one branch = one PR.

---

## Quick Reference: Available Skills & Agents

### Skills (14 slash commands)

| Command | What It Does |
|---------|-------------|
| `/test [scope]` | Run test suite — unit, integration, e2e, mutation, property, flaky |
| `/lint [files]` | Run linters, formatters, static analysis; `/lint setup` scaffolds linter stack |
| `/review [files]` | Multi-agent code review; `/review --plan` reviews plans |
| `/review-plan [file]` | Review implementation plans before building |
| `/security-audit [scope]` | Security review: OWASP, deps, secrets, permissions |
| `/deploy [env]` | Deploy to target environment (staging/production) |
| `/create-feature [name]` | Full TDD feature workflow with tracer bullets |
| `/fix-bug [issue]` | Root cause analysis + regression test workflow |
| `/refactor [scope]` | Safe incremental refactoring with characterization tests |
| `/explore-module [path]` | Build/update `.context.md` for a module |
| `/decompose [feature]` | Break features into tracer bullet stories/tasks |
| `/swarm [task]` | General-purpose parallel subagent orchestration |
| `/team-review [scope]` | Parallel subagent review (4 reviewers simultaneously) |
| `/team-implement [plan]` | Parallel subagent implementation with adversarial review |

### Agents (8 specialists in `.claude/agents/`)

| Agent | Focus |
|-------|-------|
| code-reviewer | Correctness, readability, engineering principles |
| security-reviewer | OWASP top 10, secrets, input validation |
| architecture-reviewer | SOLID, coupling, module boundaries, scalability |
| test-reviewer | TDD compliance, coverage gaps, test quality |
| performance-reviewer | Algorithmic complexity, N+1 queries, memory |
| doc-reviewer | API docs, README accuracy, stale docs |
| verifier | Runs build/test/lint, binary pass/fail |
| team-lead | Coordinates subagent teams, adversarial separation |

### Rules (9 auto-loaded from `.claude/rules/`)

| Rule | Governs |
|------|---------|
| workflow | 8-stage dev loop, plan-first, session logging, context preservation |
| orchestrator | Autonomous implement → verify → review → fix → score loop |
| quality-and-verification | 80/90/95 scoring, verification checklist |
| git-and-delivery | Branches, commits, PRs, work decomposition, tracer bullets |
| agent-coordination | Parallel subagents, worktrees, tool preferences |
| engineering-principles | DRY, KISS, SOLID, immutability, fail fast, context-in-errors |
| code-conventions | Naming, linters-as-law, observability, `.context.md` |
| testing-protocol | TDD, advanced testing (property, mutation, contract, snapshot) |
| security-practices | OWASP, secrets, auth/authz, dependency security |

---

## Project Overview

<!-- Describe your project in 2-3 paragraphs. What is it? Who is it for? What problem does it solve? -->

[DESCRIBE YOUR PROJECT HERE]

### Tech Stack

<!-- List your specific technologies. Examples below — replace with yours. -->

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | [e.g., Python / TypeScript / Rust] | [version] |
| Framework | [e.g., FastAPI / Next.js / Gin / Axum] | [version] |
| Database | [e.g., PostgreSQL / Redis / SQLite] | [version] |
| Testing | [e.g., pytest / vitest / go test] | [version] |
| Linting | [e.g., ruff / eslint / clippy] | [version] |
| CI/CD | [e.g., GitHub Actions / GitLab CI] | — |
| Packaging | [e.g., pip / npm / docker] | — |

---

## Folder Structure

```
[YOUR-PROJECT]/
├── MEMORY.md                          # Template for auto-memory (copy to ~/.claude/...)
├── Makefile                           # Self-documenting build commands
├── .claude/                           # Claude Code configuration
│   ├── CLAUDE.md                      # This file — Claude's project guide
│   ├── settings.json                  # Project permissions + hooks
│   ├── hooks/                         # Git guardrails
│   │   └── block-dangerous-git.sh     # Blocks destructive git commands
│   ├── rules/                         # 9 engineering rules (auto-loaded)
│   ├── skills/                        # 14 slash commands + supporting files
│   └── agents/                        # 8 specialized agents
├── src/                               # Application source code
│   └── [YOUR STRUCTURE]
│   └── [module]/.context.md           # Module state files (auto-maintained)
├── tests/                             # Test suite
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── scripts/
│   └── score.py                       # Automated quality scoring (0-100)
├── docs/                              # Project documentation
├── working/                           # Review & planning artifacts
│   ├── plans/                         # Saved implementation plans
│   └── logs/                          # Session history and decision logs
└── [CONFIG FILES]                     # .env.example, pyproject.toml, etc.
```

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
- **PR size:** <10 files, <300 lines, <30 min review

See `.claude/rules/git-and-delivery.md` for the full protocol.

---

## Current Project State

<!-- Update this table as you develop your project -->

| Component | Status | Key Notes |
|-----------|--------|-----------|
| [Component 1] | [Not started / In progress / Done] | [Brief description] |
| [Component 2] | [Not started / In progress / Done] | [Brief description] |

---

**Ready to begin? Start by customizing this `.claude/CLAUDE.md` for your project, then copy MEMORY.md to your auto-memory directory and run `make help`!**
