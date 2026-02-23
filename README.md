# Agentic Development Framework for Claude Code

An installable framework that enforces best engineering practices through Claude Code's multi-agent review system, quality gates, and TDD-first workflows. Run `./install.sh` to add it to any existing project.

**Target audience:** Teams working on **existing codebases** with AI agents. Refactoring, not greenfield.

---

## Design Philosophy

### The Development Loop

Every task follows one loop. Every rule, skill, and agent maps to exactly one stage:

```
UNDERSTAND → PLAN → VALIDATE → BUILD → VERIFY → REVIEW → SHIP → OBSERVE
     ↑                                                              |
     └──────────────────────────────────────────────────────────────┘
```

| Stage | What Happens | Key Skills |
|-------|-------------|------------|
| **Understand** | Read `.context.md`, explore modules | `/explore-module` |
| **Plan** | Decompose into tracer bullets | `/decompose` |
| **Validate** | Agents review the plan before code | `/review-plan` |
| **Build** | TDD, one tracer bullet at a time | `/create-feature`, `/fix-bug`, `/refactor` |
| **Verify** | Linters as law, tests as contract | `/lint`, `/test` |
| **Review** | Multi-agent code review | `/review`, `/team-review` |
| **Ship** | Small PR, one tracer bullet per PR | `/deploy` |
| **Observe** | Tracing, context-rich outputs | — |

### Two Foundational Behaviors

1. **Module State Files (`.context.md`)** — Every module maintains a `.context.md` that Claude reads FIRST instead of exploring. Updated after every implementation phase. Context persists across sessions.

2. **Worktree Enforcement** — All non-trivial work happens in git worktrees. Each worktree = one branch = one PR. Multiple features can progress simultaneously.

---

## What This Template Provides

### MEMORY.md — Behavioral Enforcement

The most important file. Auto-loaded into Claude's system prompt every session via the auto-memory directory. Contains:

- **8 Non-Negotiable Rules** — TDD first, plan first, verify before done, use subagents, session logging, learn from corrections, never /clear, review plans
- **Context-First Workflow** — read `.context.md` before exploring
- **Subagent Patterns** — concrete `Task(subagent_type=..., prompt=...)` invocations
- **Learned Patterns** — `[LEARN:tag]` entries that accumulate over sessions

### Multi-Agent Code Review (8 Specialists)

| Agent | Focus |
|-------|-------|
| **code-reviewer** | Readability, correctness, engineering principles |
| **security-reviewer** | OWASP top 10, secrets, input validation |
| **architecture-reviewer** | SOLID, coupling, module boundaries |
| **test-reviewer** | TDD compliance, coverage gaps, test quality |
| **performance-reviewer** | Algorithmic complexity, N+1 queries, memory |
| **doc-reviewer** | API docs, README accuracy, stale docs |
| **verifier** | Runs build/test/lint and reports pass/fail |
| **team-lead** | Coordinates subagent teams, adversarial separation |

### Quality Gates (0-100 Scoring)

- **80** = Commit (tests pass, no lint errors, no security issues)
- **90** = PR/Merge (high coverage, clean architecture, documented)
- **95** = Release (production-ready, performance validated)

### Engineering Principles (Enforced, Not Aspirational)

DRY, KISS, SOLID, Immutability, Strong Typing, Dependency Injection, Composition over Inheritance, Fail Fast (with context-in-errors), Separation of Concerns, Explicit over Implicit.

### 14 Slash Commands

| Command | What It Does |
|---------|-------------|
| `/create-feature` | Full TDD feature workflow with tracer bullets |
| `/deploy` | Deploy to staging/production with safety checks |
| `/fix-bug` | Root cause analysis + regression test workflow |
| `/lint` | Linters, formatters, static analysis; `/lint setup` scaffolds linter stack |
| `/refactor` | Safe incremental refactoring with characterization tests |
| `/review` | Multi-agent code review; `/review --plan` reviews plans |
| `/review-plan` | Review plans before implementation |
| `/explore-module` | Build/update `.context.md` for a module |
| `/decompose` | Break features into tracer bullet stories/tasks |
| `/security-audit` | OWASP, dependency audit, secrets scan |
| `/swarm` | General-purpose parallel subagent orchestration |
| `/team-implement` | Parallel implementation with adversarial review |
| `/team-review` | Parallel subagent review (each in own context) |
| `/test` | Run tests — unit, integration, e2e, mutation, property, flaky |

### 9 Engineering Rules (Auto-Loaded)

| Rule | Governs |
|------|---------|
| `workflow.md` | 8-stage dev loop, plan-first, session logging |
| `orchestrator.md` | Autonomous implement → verify → review → fix → score |
| `quality-and-verification.md` | 80/90/95 scoring, verification checklist |
| `git-and-delivery.md` | Branches, commits, PRs, work decomposition |
| `agent-coordination.md` | Parallel subagents, worktrees, tool preferences |
| `engineering-principles.md` | DRY, KISS, SOLID, fail fast, context-in-errors |
| `code-conventions.md` | Naming, linters-as-law, observability, `.context.md` |
| `testing-protocol.md` | TDD, property-based, mutation, contract testing |
| `security-practices.md` | OWASP, secrets, auth/authz, dependency security |

### Git Guardrails

A PreToolUse hook blocks destructive git commands (force push, reset --hard, clean -f, branch -D, checkout ., restore .) and suggests safe alternatives.

---

## Quick Start

### Install into an existing project

```bash
# From a cloned copy of this repo:
./install.sh /path/to/your-project

# Or specify a local source explicitly:
./install.sh --source /path/to/agentic-dev-os /path/to/your-project
```

The installer will:
1. **Detect your stack** (Python, TypeScript, Rust, Go, Java) and pre-fill Makefile commands
2. **Copy framework files** (`.claude/`, `scripts/`, `working/`)
3. **Merge `.gitignore`** (appends new entries, never overwrites)
4. **Set up auto-memory** (computes the correct `~/.claude/projects/` path automatically)
5. **Validate** everything was installed correctly
6. **Ask if you want Claude to analyze your project** and fill in CLAUDE.md placeholders

```bash
# Options
./install.sh --force        # Overwrite existing .claude/
./install.sh --no-detect    # Skip stack auto-detection
./install.sh --dry-run      # Preview without making changes
./install.sh --help         # Full usage info
```

### After installing

```bash
cd your-project
claude                      # Start Claude Code
```

Then either paste the analysis prompt (printed by the installer) or manually edit:
1. `.claude/CLAUDE.md` — replace `[PLACEHOLDER]` values with your project info
2. `Makefile` — verify/fix any remaining `[PLACEHOLDER]` commands
3. `MEMORY.md` — replace `[PROJECT NAME]` and update project state
4. Run `make help` to verify

---

## Directory Structure

```
your-project/
├── .claude/
│   ├── CLAUDE.md                      # Claude's project guide (edit this first!)
│   ├── settings.json                  # Permissions + hooks (git guardrails, verification)
│   ├── hooks/
│   │   └── block-dangerous-git.sh     # Blocks destructive git commands
│   ├── agents/                        # 8 specialized agents
│   │   ├── architecture-reviewer.md
│   │   ├── code-reviewer.md
│   │   ├── doc-reviewer.md
│   │   ├── performance-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── team-lead.md
│   │   ├── test-reviewer.md
│   │   └── verifier.md
│   ├── rules/                         # 9 auto-loaded engineering rules
│   │   ├── workflow.md                # Dev loop, plan-first, session logging
│   │   ├── orchestrator.md            # Autonomous implement/verify/review loop
│   │   ├── quality-and-verification.md # Scoring rubrics + verification checklist
│   │   ├── git-and-delivery.md        # Branches, commits, PRs, work decomposition
│   │   ├── agent-coordination.md      # Subagents, worktrees, tool preferences
│   │   ├── engineering-principles.md  # DRY, KISS, SOLID, fail fast
│   │   ├── code-conventions.md        # Naming, linters, observability, .context.md
│   │   ├── testing-protocol.md        # TDD, advanced testing techniques
│   │   └── security-practices.md      # OWASP, secrets, auth
│   └── skills/                        # 14 slash commands + supporting files
│       ├── create-feature/
│       │   ├── SKILL.md               # TDD + tracer bullet workflow
│       │   ├── tests.md               # Good vs bad tests guide
│       │   └── tracer-bullets.md     # Decomposition guide
│       ├── decompose/SKILL.md         # Feature → tracer bullet stories
│       ├── deploy/SKILL.md
│       ├── explore-module/SKILL.md    # Build/update .context.md
│       ├── fix-bug/SKILL.md           # Root cause + regression test
│       ├── lint/
│       │   ├── SKILL.md               # Linters-as-law workflow
│       │   └── linter-stacks.md       # Config examples per language
│       ├── refactor/
│       │   ├── SKILL.md               # Safe incremental refactoring
│       │   ├── catalog.md             # Common refactoring moves
│       │   └── characterization-tests.md # Test code you don't understand
│       ├── review/SKILL.md            # Multi-agent review + plan review
│       ├── review-plan/SKILL.md       # Plan review before implementation
│       ├── security-audit/SKILL.md
│       ├── swarm/SKILL.md             # General parallel orchestration
│       ├── team-implement/SKILL.md    # Parallel implementation
│       ├── team-review/SKILL.md       # Parallel review
│       └── test/
│           ├── SKILL.md               # Test runner + TDD modes
│           └── advanced.md            # Property, mutation, contract testing
├── .gitignore
├── docs/
├── install.sh                         # Framework installer (run this first)
├── Makefile                           # Self-documenting build commands
├── MEMORY.md                          # Template for auto-memory
├── scripts/
│   └── score.py                       # Automated quality scoring (0-100)
├── src/                               # Your application code
│   └── [module]/.context.md           # Module state files
├── tests/
└── working/                           # Plans and logs
    ├── logs/
    └── plans/
```

---

## Customization Guide

### For Node.js/TypeScript Projects
```Makefile
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

### For Python Projects

Use a virtual environment to isolate dependencies:
```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e ".[dev]"
```

```Makefile
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

### For Rust Projects
```Makefile
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

## Attribution

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by [Anthropic](https://anthropic.com). Framework design, rules, agents, skills, and install tooling created collaboratively with Claude Opus 4.6.

**Inspired by:**
- [mattpocock/skills](https://github.com/mattpocock/skills)

---

## License

MIT
