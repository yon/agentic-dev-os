# Software Workflow Template for Claude Code

A ready-to-fork project template that enforces best engineering practices through Claude Code's multi-agent review system, quality gates, and TDD-first workflows.

**Inspired by** [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) — adapted from academic slide development to general-purpose software engineering.

---

## What This Template Provides

### MEMORY.md — Behavioral Enforcement

The most important file in the template. `MEMORY.md` is auto-loaded into Claude's system prompt every session via the auto-memory directory. It contains:

- **7 Non-Negotiable Rules** — TDD first, plan first, verify before done, use subagents, session logging, learn from corrections, never /clear
- **Subagent Patterns** — Concrete `Task(subagent_type=..., prompt=...)` invocations for reviews, security audits, and parallel work
- **Verification Checklist** — What to run before presenting any code change
- **Learned Patterns** — `[LEARN:tag]` entries that accumulate over sessions to prevent recurring mistakes

Copy it to `~/.claude/projects/<project-path>/memory/MEMORY.md` for it to take effect.

### Multi-Agent Code Review (via Task Tool Subagents)

8 specialized agent definitions that review your code from different angles — simultaneously:

| Agent | Focus |
|-------|-------|
| **code-reviewer** | Readability, correctness, engineering principles |
| **security-reviewer** | OWASP top 10, secrets, input validation |
| **architecture-reviewer** | SOLID, coupling, module boundaries |
| **test-reviewer** | TDD compliance, coverage gaps, test quality |
| **performance-reviewer** | Algorithmic complexity, N+1 queries, memory |
| **doc-reviewer** | API docs, README accuracy, stale docs |
| **verifier** | Runs build/test/lint and reports pass/fail |
| **team-lead** | Coordinates subagent teams, enforces adversarial separation |

Reviews are spawned as parallel subagents via the **Task tool** with `subagent_type` parameters. Agent definitions in `.claude/agents/` are injected into each subagent's prompt.

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

### 12 Slash Commands

| Command | What It Does |
|---------|-------------|
| `/build` | Build the project |
| `/create-feature` | Full TDD feature workflow with planning |
| `/deploy` | Deploy to staging/production with safety checks |
| `/fix-bug` | Root cause analysis + regression test workflow |
| `/lint` | Linters, formatters, and static analysis |
| `/refactor` | Safe refactoring with test-first verification |
| `/review` | Multi-agent code review (spawns subagents) |
| `/security-audit` | OWASP, dependency audit, secrets scan |
| `/swarm` | General-purpose parallel subagent orchestration |
| `/team-implement` | Parallel implementation with adversarial review |
| `/team-review` | Parallel subagent review (each reviewer in own context) |
| `/test` | Run test suite (unit, integration, or all) |

### Parallel Subagent Orchestration

Spawn multiple Claude Code subagents that work in parallel via the **Task tool**:
- **Parallel review** — 4 reviewers examining code simultaneously, each in their own context
- **Module-parallel implementation** — each subagent owns separate files, builds independently
- **Adversarial pairs** — implementer writes, critic reviews, neither can do the other's job
- **Research swarms** — multiple agents investigate different angles simultaneously
- **TDD split** — test author writes failing tests, implementer makes them pass

**The Iron Rule:** The subagent that writes code NEVER approves it. The subagent that reviews NEVER edits. Always.

### Workflow Patterns
- **Plan-First** — Non-trivial tasks start with a plan, saved to disk
- **Development Mode** — After plan approval, autonomous implement → verify → review → fix → score
- **Parallel Subagents** — Multi-context execution with adversarial checks and balances
- **Context Preservation** — Session logs, saved plans, `[LEARN]` tags in MEMORY.md
- **Self-Documenting Makefile** — `make help` shows all available commands

---

## Quick Start

### 1. Clone
```bash
git clone <this-repo> my-project
cd my-project
```

### 2. Customize
1. Edit `.claude/CLAUDE.md` — replace all `[PLACEHOLDER]` values with your project info
2. Edit `Makefile` — replace `[PLACEHOLDER]` commands with your actual build/test/lint tools
3. Edit `.claude/rules/code-conventions.md` — set naming conventions for your language
4. Copy `MEMORY.md` to your auto-memory directory:
   ```bash
   # The path uses dashes for each / in your project's absolute path
   mkdir -p ~/.claude/projects/-Users-you-src-my-project/memory/
   cp MEMORY.md ~/.claude/projects/-Users-you-src-my-project/memory/MEMORY.md
   ```
5. Edit the copied `MEMORY.md` — replace placeholders with your project info
6. Optionally edit `.claude/settings.json` — adjust allowed commands for your stack

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
├── .claude/
│   ├── CLAUDE.md                      # Claude's project guide (edit this first!)
│   ├── settings.json                  # Permissions + verification hook
│   ├── agents/                        # 8 specialized agents
│   │   ├── architecture-reviewer.md
│   │   ├── code-reviewer.md
│   │   ├── doc-reviewer.md
│   │   ├── performance-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── test-reviewer.md
│   │   ├── verifier.md
│   ├── rules/                         # 10 auto-loaded engineering rules
│   │   ├── agent-teams.md             # Parallel subagent coordination via Task tool
│   │   ├── code-conventions.md        # Naming, structure, patterns
│   │   ├── engineering-principles.md  # DRY, KISS, SOLID, immutability, etc.
│   │   ├── git-workflow.md            # Branches, commits, PRs
│   │   ├── orchestrator-protocol.md   # Autonomous implement/verify/review loop
│   │   ├── plan-first-workflow.md     # Plan → save → approve → implement
│   │   ├── quality-gates.md           # 80/90/95 scoring rubrics
│   │   ├── security-practices.md      # OWASP, secrets, input validation
│   │   ├── team-lead.md              # Subagent team coordinator
│   │   ├── testing-protocol.md        # TDD cycle, test quality, coverage
│   │   └── verification-protocol.md   # Build/test/lint verification checklist
│   └── skills/                        # 12 slash commands
│       ├── build/SKILL.md
│       ├── create-feature/SKILL.md
│       ├── deploy/SKILL.md
│       ├── fix-bug/SKILL.md
│       ├── lint/SKILL.md
│       ├── refactor/SKILL.md
│       ├── review/SKILL.md
│       ├── security-audit/SKILL.md
│       ├── swarm/SKILL.md             # General-purpose parallel subagents
│       ├── team-implement/SKILL.md    # Parallel implementation + adversarial review
│       ├── team-review/SKILL.md       # Parallel subagent reviews
│       └── test/SKILL.md
├── .gitignore                         # Common ignores for all stacks
├── docs/                              # Project documentation
├── Makefile                           # Self-documenting build commands
├── MEMORY.md                          # Template for auto-memory (copy to ~/.claude/...)
├── scripts/
│   └── score.py               # Automated quality scoring (0-100)
├── src/                               # Your application code
├── tests/                             # Your test suite
└── working/                   # Plans and logs
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

## License

MIT
