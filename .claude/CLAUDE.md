# CLAUDE.MD — Software Project Development with Claude Code

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
**Language/Stack:** [e.g., Python 3.12 / TypeScript 5.x / Go 1.22 / Rust 1.77]
**Working Branch:** main

> Behavioral rules and subagent patterns: MEMORY.md (auto-loaded in system prompt)
> Engineering principles: `.claude/rules/engineering-principles.md` (auto-loaded)
> Quality gates: `.claude/rules/quality-gates.md` (auto-loaded)
> Verification protocol: `.claude/rules/verification-protocol.md` (auto-loaded)

---

## Quick Reference: Available Skills & Agents

| Command | What It Does |
|---------|-------------|
| `/build` | Build the project (compile, bundle, or package) |
| `/test [scope]` | Run test suite — unit, integration, or all |
| `/lint [files]` | Run linters, formatters, and static analysis |
| `/review [files]` | Multi-agent code review (spawns subagents via Task tool) |
| `/security-audit [scope]` | Security review: OWASP, deps, secrets, permissions |
| `/deploy [env]` | Deploy to target environment (staging/production) |
| `/create-feature [name]` | Full TDD feature workflow with planning |
| `/fix-bug [issue]` | Bug fix: reproduce, root cause, test, fix, verify |
| `/refactor [scope]` | Safe refactoring with test-first verification |
| `/team-review [scope]` | Parallel subagent review (4 reviewers simultaneously) |
| `/team-implement [plan]` | Parallel subagent implementation with adversarial review |
| `/swarm [task]` | General-purpose parallel subagent orchestration |

**Agents** (`.claude/agents/`): code-reviewer, security-reviewer, architecture-reviewer, test-reviewer, performance-reviewer, doc-reviewer, verifier, team-lead

**Rules** (auto-loaded from `.claude/rules/`): plan-first-workflow, orchestrator-protocol, quality-gates, verification-protocol, engineering-principles, testing-protocol, security-practices, git-workflow, code-conventions, agent-teams

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
├── MEMORY.md                          # Template for auto-memory (copy to ~/.claude/...)
├── Makefile                           # Self-documenting build commands
├── .claude/                           # Claude Code configuration
│   ├── CLAUDE.md                      # This file — Claude's project guide
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

## Current Project State

<!-- Update this table as you develop your project -->

| Component | Status | Key Notes |
|-----------|--------|-----------|
| [Component 1] | [Not started / In progress / Done] | [Brief description] |
| [Component 2] | [Not started / In progress / Done] | [Brief description] |

---

**Ready to begin? Start by customizing this `.claude/CLAUDE.md` for your project, then copy MEMORY.md to your auto-memory directory and run `make help`!**
