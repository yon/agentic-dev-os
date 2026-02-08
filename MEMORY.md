# [PROJECT NAME] — Claude Memory

<!-- ============================================================
     HOW TO USE THIS FILE:
     1. Copy this file to your Claude auto-memory directory:
        ~/.claude/projects/<project-path-with-dashes>/memory/MEMORY.md
     2. Replace all [BRACKETED PLACEHOLDERS] with your project info
     3. This file is auto-loaded into Claude's system prompt every session
     4. Keep it under 200 lines (lines after 200 are truncated)
     5. For detailed notes, create topic files in the same directory
        and link to them from here
     ============================================================ -->

## Session Protocol

**Session start:**
1. `git log --oneline -10` — what changed recently?
2. Check `working/plans/` for active plans
3. Check `working/logs/` for recent session context
4. State what you understand the current task/goal to be

**Session end:**
1. Save session log to `working/logs/YYYY-MM-DD_description.md`
2. Update this file if you learned something new
3. Note any unresolved questions in the session log

---

## Non-Negotiable Rules

These 7 rules override all other guidance. Follow them every time.

### 1. TDD First
BEFORE writing implementation code, write a failing test. Run it. Confirm it FAILS.
Then implement the minimum code to make it pass. Then refactor.
**If you cannot write a test first, STOP and explain why to the user.**

### 2. Plan First
For non-trivial tasks (3+ files, architectural decisions, new features):
- Enter plan mode with `EnterPlanMode`
- Save plan to `working/plans/YYYY-MM-DD_description.md`
- Get user approval before implementing
Skip for: typo fixes, single-line changes, running commands.

### 3. Verify Before Done
Before presenting ANY code change to the user, run:
```bash
make check   # or: make build && make test && make lint
```
If any fail, fix them. Never present unverified code.

### 4. Use Subagents for Parallel Work
Delegate reviews and parallel research to Task tool subagents.
Do NOT try to do everything sequentially in the main context.
See "Subagent Patterns" below.

### 5. Session Logging
Create or update a session log in `working/logs/` for every
significant work session. This preserves context across auto-compression.

### 6. Learn from Corrections
After ANY user correction, add a `[LEARN:tag]` entry to the "Learned Patterns"
section below. This prevents the same mistake from recurring.

### 7. Never /clear
Rely on auto-compression to manage long conversations. /clear destroys all
context; auto-compression preserves what matters.

---

## Subagent Patterns

Use the Task tool to delegate specialized work. Agent definitions live in
`.claude/agents/*.md` — read the file and include its content in the task prompt.

### Code Review
```
Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/code-reviewer.md>\n\nReview these files: {list}")
```

### Security Review
```
Task(subagent_type="security-code-auditor",
     prompt="<content of .claude/agents/security-reviewer.md>\n\nAudit these files: {list}")
```

### Architecture Review
```
Task(subagent_type="senior-code-reviewer",
     prompt="<content of .claude/agents/architecture-reviewer.md>\n\nReview: {scope}")
```

### Parallel Reviews
Spawn multiple Task calls in the SAME response for parallel execution:
```
Task 1: security-code-auditor with security-reviewer.md
Task 2: senior-code-reviewer with code-reviewer.md
Task 3: senior-code-reviewer with test-reviewer.md
```

### Research / Exploration
```
Task(subagent_type="Explore", prompt="Find all files related to {topic}")
```

### Planning
```
Task(subagent_type="Plan", prompt="Design implementation for {feature}")
```

---

## Verification Checklist

Run in order. Stop on first failure.

1. `make build` — zero errors
2. `make test` — all tests pass
3. `make lint` — zero warnings

<!-- Add project-specific checks below -->
<!-- 4. `make typecheck` — zero type errors -->
<!-- 5. `./scripts/lint-alpha.py --all` — zero violations -->

---

## Learned Patterns

<!-- Add [LEARN:tag] entries as you discover project-specific patterns -->
<!-- Examples: -->
<!-- [LEARN:convention] Match arms must be alphabetized -->
<!-- [LEARN:api] This endpoint expects snake_case, NOT camelCase -->
<!-- [LEARN:test] Always mock the database layer in unit tests -->
<!-- [LEARN:workflow] Use Task tool subagents, not TeammateTool -->

[LEARN:workflow] TeammateTool/SendMessage/spawnTeam are NOT available — use Task tool with subagent_type
[LEARN:workflow] MEMORY.md is the #1 enforcement tool — it loads in system prompt every session
[LEARN:workflow] Skills are prompt expansions — they must be explicit about what tools to use
[LEARN:workflow] Rules in .claude/rules/ are auto-loaded context — don't duplicate in CLAUDE.md

---

## Current Project State

<!-- Update this as the project evolves -->

- **Phase**: [CURRENT PHASE]
- **Key Metrics**: [e.g., test count, coverage %, etc.]
- **Active Plan**: [path to current plan file, or "none"]
- **Key Gaps**: [known issues or incomplete areas]
