# Software Workflow Template for Claude Code

A ready-to-fork project template that enforces best engineering practices through Claude Code's multi-agent review system, quality gates, and TDD-first workflows.

**Inspired by** [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) — adapted from academic slide development to general-purpose software engineering.

---

## What This Template Provides

### Multi-Agent Code Review
7 specialized agents that review your code from different angles — simultaneously:

| Agent | Focus |
|-------|-------|
| **code-reviewer** | Readability, correctness, engineering principles |
| **security-reviewer** | OWASP top 10, secrets, input validation |
| **architecture-reviewer** | SOLID, coupling, module boundaries |
| **test-reviewer** | TDD compliance, coverage gaps, test quality |
| **performance-reviewer** | Algorithmic complexity, N+1 queries, memory |
| **doc-reviewer** | API docs, README accuracy, stale docs |
| **verifier** | Runs build/test/lint and reports pass/fail |

### Quality Gates (0-100 Scoring)
Automated quality scoring with enforced thresholds:
- **80** = Commit (tests pass, no lint errors, no security issues)
- **90** = PR/Merge (high coverage, clean architecture, documented)
- **95** = Release (production-ready, performance validated)

### Engineering Principles (Enforced, Not Aspirational)
- **DRY** — Don't Repeat Yourself
- **KISS** — Keep It Simple, Stupid
- **SOLID** — Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Immutability** — Const by default, mutate only when justified
- **Strong Typing** — Make illegal states unrepresentable
- **Dependency Injection** — Pass dependencies, don't reach for globals
- **Composition over Inheritance** — Build behavior by combining pieces
- **Fail Fast** — Validate at boundaries, crash on invalid state
- **Separation of Concerns** — Pure core, impure shell
- **TDD** — Tests first, always

### 9 Slash Commands

| Command | What It Does |
|---------|-------------|
| `/build` | Build the project |
| `/test` | Run test suite (unit, integration, or all) |
| `/lint` | Linters, formatters, and static analysis |
| `/review` | Combined multi-agent code review (6 dimensions) |
| `/security-audit` | OWASP, dependency audit, secrets scan |
| `/deploy` | Deploy to staging/production with safety checks |
| `/create-feature` | Full TDD feature workflow with planning |
| `/fix-bug` | Root cause analysis + regression test workflow |
| `/refactor` | Safe refactoring with test-first verification |

### Workflow Patterns
- **Plan-First** — Non-trivial tasks start with a plan, saved to disk
- **Contractor Mode** — After plan approval, autonomous implement → verify → review → fix → score
- **Context Preservation** — Session logs, saved plans, `[LEARN]` tags
- **Self-Documenting Makefile** — `make help` shows all available commands

---

## Quick Start

### 1. Clone
```bash
git clone <this-repo> my-project
cd my-project
```

### 2. Customize
1. Edit `CLAUDE.md` — replace all `[PLACEHOLDER]` values with your project info
2. Edit `Makefile` — replace `[PLACEHOLDER]` commands with your actual build/test/lint tools
3. Edit `.claude/rules/code-conventions.md` — set naming conventions for your language
4. Optionally edit `.claude/settings.json` — adjust allowed commands for your stack

### 3. Start Claude Code
```bash
claude
```

### 4. Verify Setup
```
make help
```

---

## Directory Structure

```
your-project/
├── CLAUDE.md                          # Claude's project guide (edit this first!)
├── Makefile                           # Self-documenting build commands
├── .gitignore                         # Common ignores for all stacks
├── .claude/
│   ├── settings.json                  # Permissions + verification hook
│   ├── rules/                         # 9 auto-loaded engineering rules
│   │   ├── plan-first-workflow.md     # Plan → save → approve → implement
│   │   ├── orchestrator-protocol.md   # Autonomous implement/verify/review loop
│   │   ├── quality-gates.md           # 80/90/95 scoring rubrics
│   │   ├── verification-protocol.md   # Build/test/lint verification checklist
│   │   ├── engineering-principles.md  # DRY, KISS, SOLID, immutability, etc.
│   │   ├── testing-protocol.md        # TDD cycle, test quality, coverage
│   │   ├── security-practices.md      # OWASP, secrets, input validation
│   │   ├── git-workflow.md            # Branches, commits, PRs
│   │   └── code-conventions.md        # Naming, structure, patterns
│   ├── agents/                        # 7 specialized review agents
│   │   ├── code-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── architecture-reviewer.md
│   │   ├── test-reviewer.md
│   │   ├── performance-reviewer.md
│   │   ├── doc-reviewer.md
│   │   └── verifier.md
│   └── skills/                        # 9 slash commands
│       ├── build/SKILL.md
│       ├── test/SKILL.md
│       ├── lint/SKILL.md
│       ├── review/SKILL.md
│       ├── security-audit/SKILL.md
│       ├── deploy/SKILL.md
│       ├── create-feature/SKILL.md
│       ├── fix-bug/SKILL.md
│       └── refactor/SKILL.md
├── scripts/
│   └── quality_score.py               # Automated quality scoring (0-100)
├── src/                               # Your application code
├── tests/                             # Your test suite
├── docs/                              # Project documentation
└── quality_reports/                   # Plans and session logs
    ├── plans/
    └── session_logs/
```

---

## Customization Guide

### For Python Projects
```makefile
BUILD_CMD      = python -m build
TEST_CMD       = pytest
TEST_UNIT_CMD  = pytest tests/unit -x -q
TEST_INT_CMD   = pytest tests/integration -x -q
LINT_CMD       = ruff check src tests
FORMAT_CMD     = ruff format src tests
TYPECHECK_CMD  = mypy src
SECURITY_CMD   = pip-audit
COVERAGE_CMD   = pytest --cov=src --cov-report=html
DEPS_CMD       = pip install -e ".[dev]"
```

### For Node.js/TypeScript Projects
```makefile
BUILD_CMD      = npm run build
TEST_CMD       = npm test
TEST_UNIT_CMD  = npx vitest run tests/unit
TEST_INT_CMD   = npx vitest run tests/integration
LINT_CMD       = npx eslint src tests
FORMAT_CMD     = npx prettier --write src tests
TYPECHECK_CMD  = npx tsc --noEmit
SECURITY_CMD   = npm audit
COVERAGE_CMD   = npx vitest run --coverage
DEPS_CMD       = npm install
```

### For Go Projects
```makefile
BUILD_CMD      = go build ./...
TEST_CMD       = go test ./...
TEST_UNIT_CMD  = go test ./internal/... ./pkg/...
TEST_INT_CMD   = go test ./tests/integration/...
LINT_CMD       = golangci-lint run
FORMAT_CMD     = gofmt -w .
TYPECHECK_CMD  = go vet ./...
SECURITY_CMD   = govulncheck ./...
COVERAGE_CMD   = go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out
DEPS_CMD       = go mod download
```

### For Rust Projects
```makefile
BUILD_CMD      = cargo build
TEST_CMD       = cargo test
TEST_UNIT_CMD  = cargo test --lib
TEST_INT_CMD   = cargo test --test '*'
LINT_CMD       = cargo clippy -- -D warnings
FORMAT_CMD     = cargo fmt
TYPECHECK_CMD  = cargo check
SECURITY_CMD   = cargo audit
COVERAGE_CMD   = cargo tarpaulin --out Html
DEPS_CMD       = cargo fetch
```

---

## License

MIT
