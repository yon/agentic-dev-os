# Parallel Subagent Coordination

**Use the Task tool to spawn parallel subagents for work that benefits from concurrent execution.** Each subagent runs independently with its own context, and the lead (main session) coordinates.

---

## When to Use Parallel Subagents

### Strong Use Cases

| Scenario | Why Subagents Help | Example |
|----------|-------------------|---------|
| **Parallel code review** | Each reviewer focuses on one dimension without context dilution | Security reviews auth while performance reviews queries |
| **Multi-module implementation** | Each subagent owns separate files, no merge conflicts | Backend API + frontend components + database migrations |
| **Competing hypothesis debugging** | Subagents test different theories simultaneously | One checks race condition, another checks data corruption |
| **Research and investigation** | Multiple angles explored simultaneously | One reads code, another checks git history, another searches docs |
| **Large-scale refactoring** | Each subagent refactors a different module | Split by module boundary, each subagent owns their files |

### When NOT to Use Parallel Subagents

- **Single-file changes** — direct work is faster
- **Tightly coupled changes** — if subagents would need to edit the same files, use sequential work
- **Simple tasks** — coordination overhead isn't worth it for quick tasks
- **Exploratory work** — when you don't know what files will be touched (explore first, then parallelize)

---

## How It Works: The Task Tool

Subagents are spawned via the **Task tool** with a `subagent_type` parameter:

```
Task(subagent_type="senior-code-reviewer",
     prompt="<agent definition from .claude/agents/*.md>\n\nReview these files: ...")
```

### Available Subagent Types

| subagent_type | Best For |
|---------------|----------|
| `senior-code-reviewer` | Code review, architecture review, test review, doc review |
| `security-code-auditor` | Security audits, vulnerability analysis |
| `production-code-engineer` | Writing production code, implementing features |
| `code-shell-expert` | Shell scripts, system administration, infrastructure |
| `Explore` | Codebase research, finding files, understanding patterns |
| `Plan` | Designing implementation approaches |

### Agent Definitions

Agent definitions live in `.claude/agents/*.md`. When spawning a subagent, **read the agent definition file and include its content in the task prompt**. This gives the subagent its specialized instructions.

```
# Read the agent definition
agent_def = Read(".claude/agents/code-reviewer.md")

# Spawn with the definition included
Task(subagent_type="senior-code-reviewer",
     prompt=f"{agent_def}\n\nReview these files: {file_list}")
```

### Parallel Execution

To run subagents in parallel, spawn them **in the same response** (multiple Task calls in one message):

```
# These run concurrently:
Task(subagent_type="security-code-auditor", prompt="...")
Task(subagent_type="senior-code-reviewer", prompt="...")
Task(subagent_type="senior-code-reviewer", prompt="...")
```

---

## Coordination Patterns

### Pattern 1: Parallel Review (Read-Only)

All subagents read, none write. Zero conflict risk.

```
Lead reads changed files → spawns 4 review subagents in parallel → collects reports → synthesizes
```

### Pattern 2: Module-Parallel Implementation

Each writer subagent owns specific files. No overlap.

```
Lead partitions files → spawns writer subagents in parallel → runs make check → spawns reviewer subagents
```

### Pattern 3: Dependent Phases

Some work depends on other work completing first.

```
Phase 1: Spawn independent writers in parallel → wait for all to complete
Phase 2: Spawn integration subagent (depends on Phase 1 output)
Phase 3: Spawn review subagents (depends on Phase 2)
```

### Pattern 4: Research Swarm

Multiple Explore subagents investigate different angles simultaneously.

```
Lead defines questions → spawns Explore subagents in parallel → synthesizes findings
```

---

## Critical Rules

### 1. File Ownership — No Shared Edits

**The #1 source of parallel work failures is two subagents editing the same file.**

Prevention:
- In the Task prompt, explicitly state which files the subagent may edit
- Use directory-level ownership when possible ("You own src/auth/*, do not edit anything else")
- If a shared file MUST be edited, sequence the tasks — one subagent edits first, then the other
- Config files (package.json, go.mod) should be owned by exactly ONE subagent

### 2. Context — Subagents Start Fresh

Subagents do NOT inherit the lead's conversation history. They only have:
- Their task prompt
- CLAUDE.md (loaded automatically)
- Full codebase read access

**Always include in task prompts:**
- Specific file paths the subagent will work on
- Requirements and constraints
- What "done" looks like
- Key decisions already made

### 3. Adversarial Separation

**The subagent that writes code NEVER reviews it. The subagent that reviews NEVER edits.**

- Use `production-code-engineer` or `code-shell-expert` for writing
- Use `senior-code-reviewer` or `security-code-auditor` for reviewing
- The lead coordinates but does not override reviewer findings without justification

### 4. Verify the Combined Result

Individual subagent success does not guarantee integration success. The lead MUST run `make check` on the combined result after all subagents complete.

### 5. Team Size

- **2-4 subagents** for most tasks (sweet spot)
- **5-8 subagents** for large parallel work with clear module boundaries
- **More than 8** is rarely useful — coordination overhead exceeds parallelism gains

---

## Integration with Orchestrator Protocol

When the orchestrator determines that a task benefits from parallel execution:

1. **Planning phase** identifies parallelizable subtasks
2. **Orchestrator spawns subagents** instead of working sequentially
3. **Each subagent runs its own TDD loop** (test → implement → verify)
4. **Lead runs verification on the combined result** (`make check`)
5. **Lead spawns review subagents** on the combined changes
6. **Normal scoring and presentation** continues

---

## Cost Awareness

Parallel subagents use more API tokens than sequential work:
- Each subagent has its own context (loaded with CLAUDE.md, agent definitions, file contents)
- N subagents ≈ N× the token usage of sequential work

**Use parallel subagents when concurrency provides genuine value** (time savings on independent tasks), not as a default mode.
