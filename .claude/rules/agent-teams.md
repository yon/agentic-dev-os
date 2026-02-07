# Agent Teams — Multi-Session Coordination

**Agent teams let you spawn multiple Claude Code sessions that work in parallel with peer-to-peer communication.** This is fundamentally different from subagents — each teammate is a full, independent session with its own context window.

---

## When to Use Agent Teams

### Strong Use Cases

| Scenario | Why Teams Help | Example |
|----------|----------------|---------|
| **Parallel code review** | Each reviewer focuses on one dimension without context dilution | Security reviews auth while performance reviews queries |
| **Multi-module implementation** | Each teammate owns separate files, no merge conflicts | Backend API + frontend components + database migrations |
| **Competing hypothesis debugging** | Teammates test different theories simultaneously | One checks race condition, another checks data corruption |
| **Cross-layer changes** | Changes that span multiple system layers | API + client SDK + docs + tests updated in parallel |
| **Large-scale refactoring** | Each teammate refactors a different module | Split by module boundary, each teammate owns their files |
| **Research and investigation** | Multiple angles explored simultaneously | One reads code, another checks git history, another searches docs |

### When NOT to Use Agent Teams

- **Single-file changes** — subagents or direct work is faster
- **Tightly coupled changes** — if teammates would need to edit the same files, use sequential work
- **Simple tasks** — the coordination overhead isn't worth it for tasks < 15 minutes
- **Exploratory work** — when you don't know what files will be touched yet (explore first, then team)

---

## Enabling Agent Teams

Add to `.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "true"
  }
}
```

Or set the environment variable before starting Claude Code:
```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

---

## Core Concepts

### Roles
- **Lead** — The session that spawns the team. Coordinates, assigns, synthesizes. Can optionally enter **delegate mode** (coordination only, no direct implementation).
- **Teammates** — Independent sessions spawned by the lead. Each has full codebase access, its own context window, and can communicate with other teammates.

### Communication
- **SendMessage** — Direct message to a specific teammate or broadcast to all
- **TaskList** — Shared task list with dependency tracking. Teammates self-claim tasks as they finish.
- **File-locked claiming** — Prevents two teammates from working on the same task

### The Three Tools
| Tool | Operations | Purpose |
|------|-----------|---------|
| `TeammateTool` | `spawnTeam`, `cleanup` | Create and tear down teams |
| `SendMessage` | `message`, `broadcast`, `shutdown_request/response`, `plan_approval_response` | Inter-agent communication |
| `TaskList` | Create tasks, set dependencies, mark complete | Shared work management |

---

## Team Patterns

### Pattern 1: Parallel Review Team

**Best for:** Comprehensive code review from multiple angles simultaneously.

```
Lead spawns team:
  ├── Teammate A: Security review (reads auth, input handling, secrets)
  ├── Teammate B: Architecture review (reads module boundaries, SOLID)
  ├── Teammate C: Performance review (reads queries, algorithms, caching)
  └── Teammate D: Test review (reads test suite, coverage, quality)

Lead waits → collects reports → merges into single review → presents to user
```

**File ownership:** All read-only. No conflict risk. Ideal first team pattern.

### Pattern 2: Module-Parallel Implementation

**Best for:** Building features that span multiple independent modules.

```
Lead creates task list with dependencies:
  Task 1: "Implement UserService" (no deps)          → Teammate A owns src/services/user.*
  Task 2: "Implement UserRepository" (no deps)       → Teammate B owns src/repositories/user.*
  Task 3: "Implement UserController" (deps: 1, 2)    → Teammate C owns src/controllers/user.*
  Task 4: "Write integration tests" (deps: 1, 2, 3)  → Teammate D owns tests/integration/user.*

Teammates self-claim tasks when dependencies are met.
```

**Critical rule:** Each teammate owns specific files. No shared file edits.

### Pattern 3: Adversarial Pair

**Best for:** High-stakes code where quality is paramount.

```
Lead spawns team:
  ├── Teammate A (Implementer): Writes the code
  └── Teammate B (Critic): Reviews, finds issues, sends back

Loop:
  1. Implementer writes code → messages Critic "ready for review"
  2. Critic reviews → messages Implementer with issues found
  3. Implementer fixes → messages Critic "fixed, re-review"
  4. Repeat until Critic approves (max 5 rounds)
  5. Lead collects final code + review trail
```

**Key:** Critic cannot edit files. Implementer cannot approve their own work. Separation of concerns.

### Pattern 4: Research Swarm

**Best for:** Investigating complex bugs or exploring unfamiliar codebases.

```
Lead spawns team with specific questions:
  ├── Teammate A: "Trace the data flow from API endpoint to database for /users"
  ├── Teammate B: "Find all places where UserSession is created or modified"
  ├── Teammate C: "Check git blame and recent commits for auth module changes"
  └── Teammate D: "Search for related issues and error patterns in logs"

Lead waits → synthesizes findings → forms hypothesis → plans fix
```

**File ownership:** All read-only. Maximum parallelism, zero conflict risk.

### Pattern 5: Test-Implementation Split

**Best for:** Strict TDD with separation between test author and implementer.

```
Lead spawns team:
  ├── Teammate A (Test Author): Writes failing tests from spec
  └── Teammate B (Implementer): Makes tests pass with minimum code

Flow:
  1. Test Author writes failing tests → messages "tests ready"
  2. Implementer reads tests, implements → messages "tests passing"
  3. Test Author adds edge cases → messages "new tests added"
  4. Implementer handles edge cases
  5. Repeat until acceptance criteria met
```

---

## Critical Rules for Agent Teams

### 1. File Ownership — No Shared Edits

**The #1 source of agent team failures is two teammates editing the same file.**

Prevention:
- In the `spawnTeam` prompt, explicitly assign file ownership to each teammate
- Use directory-level ownership when possible (`Teammate A owns src/auth/`, `Teammate B owns src/payments/`)
- If a shared file MUST be edited, sequence the tasks with dependencies — one teammate edits first, then the other
- For config files (package.json, go.mod), only ONE teammate should modify them

### 2. Context — Teammates Start Fresh

Teammates do NOT inherit the lead's conversation history. They only have:
- Their spawn prompt
- CLAUDE.md (loaded automatically)
- Full codebase read access

**Always include in spawn prompts:**
- Specific file paths the teammate will work on
- Requirements and constraints
- What "done" looks like
- Key decisions already made

### 3. Start with Read-Only Teams

Your first agent team should be a **review team** (Pattern 1), not an implementation team. This lets you learn coordination patterns safely — read-only agents can't create file conflicts.

### 4. Task Dependencies Are Critical

When using TaskList, model dependencies accurately:
- If Task B needs the output of Task A, declare the dependency
- Teammates will automatically wait for dependencies before claiming work
- Missing dependencies = race conditions = broken code

### 5. Team Size

- **2-4 teammates** for most tasks (sweet spot)
- **5-8 teammates** for large parallel work with clear module boundaries
- **More than 8** is rarely useful — coordination overhead exceeds parallelism gains

### 6. Lead Role Discipline

The lead should:
- **Coordinate**, not implement — let teammates do the work
- **Synthesize**, not duplicate — merge teammate outputs, don't redo their work
- **Monitor**, not micromanage — check in via messages, don't override teammate decisions
- Use **delegate mode** for complex multi-teammate scenarios to enforce this

---

## Team Lifecycle

```
1. PLAN — Identify tasks, file ownership, dependencies
2. SPAWN — Create team with clear prompts per teammate
3. MONITOR — Watch progress via task list, intervene only if blocked
4. COLLECT — Gather results from all teammates
5. SYNTHESIZE — Merge, resolve conflicts, produce unified output
6. VERIFY — Run make check on the combined result
7. CLEANUP — Tear down the team
```

---

## Integration with Orchestrator Protocol

When the orchestrator determines that a task benefits from parallel execution:

1. **Planning phase** identifies parallelizable subtasks
2. **Orchestrator spawns a team** instead of working sequentially
3. **Each teammate runs their own mini-orchestrator loop** (implement → verify their portion)
4. **Lead runs verification on the combined result** (`make check`)
5. **Lead runs review agents** on the combined changes
6. **Normal scoring and presentation** continues

The team approach replaces Steps 1-3 (Write Tests → Implement → Refactor) of the orchestrator loop. Steps 4-8 (Verify → Review → Fix → Score) still run on the combined output.

---

## Cost Awareness

Agent teams use significantly more API tokens than sequential work:
- Each teammate has its own context window (loaded with CLAUDE.md, their files, etc.)
- Communication messages add to token usage
- N teammates ≈ N× the token usage of a single session

**Use teams when parallelism provides genuine value** (time savings on independent tasks), not as a default mode.
