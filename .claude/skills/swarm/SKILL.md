# /swarm — General-Purpose Agent Team Orchestration

Flexibly spawn and manage an agent team for any task that benefits from parallel execution. This is the low-level team skill — use `/team-review` or `/team-implement` for those specific workflows.

---

## When to Use

- Custom team compositions not covered by `/team-review` or `/team-implement`
- Research/investigation tasks (multiple angles explored simultaneously)
- Competing hypothesis debugging
- Large-scale migrations or refactoring across many modules
- Any task where you want full control over team structure

---

## Steps

### 1. Define the Team

Specify the team structure:
- `/swarm [description]` — describe what you need, lead designs the team
- `/swarm research [question]` — spawn a research team to investigate
- `/swarm debug [issue]` — spawn competing hypothesis debuggers
- `/swarm migrate [scope]` — spawn parallel migration workers

### 2. Plan the Team (Lead)

Before spawning, the lead MUST:

1. **Define each teammate's role** — what they do, what they don't do
2. **Assign file ownership** — explicit, no overlaps for writers; unlimited for readers
3. **Model dependencies** — which tasks depend on which
4. **Enforce adversarial separation** — if any teammate writes code, a DIFFERENT teammate must review it
5. **Set completion criteria** — what "done" looks like for each teammate

Present the team plan to the user:

```markdown
## Swarm Plan

**Objective:** [what the team will accomplish]
**Team Size:** [N teammates]
**Estimated scope:** [files/modules affected]

### Teammates
| # | Role | Type | Files Owned | Depends On |
|---|------|------|-------------|------------|
| A | [role] | Writer/Reader | [files] | — |
| B | [role] | Writer/Reader | [files] | A |
| C | [role] | Reader (critic) | — | A, B |

### Adversarial Checks
- Implementers: [list]
- Reviewers: [list]  (MUST be disjoint from implementers)

### Completion Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] make check passes on combined result
```

### 3. Get Approval

Wait for user approval before spawning. (Skip if "just do it" mode is active.)

### 4. Spawn Team

Use `spawnTeam` with the approved plan. Each teammate gets a detailed prompt following the team-lead agent's prompt template.

### 5. Monitor and Coordinate

- Track progress via TaskList
- Resolve blocked teammates via SendMessage
- Handle unexpected issues (file conflicts, requirement changes)
- Enforce the adversarial separation throughout

### 6. Collect and Verify

After all teammates complete:
1. **Collect results** — gather reports/summaries from all teammates
2. **Integration verify** — `make check` on combined result
3. **Adversarial review** — if any code was written, ensure it was reviewed by a different teammate
4. **Score** — apply quality-gates rubric

### 7. Present Results

```markdown
## Swarm Summary

**Objective:** [what was accomplished]
**Team:** [N] teammates, [N] rounds of adversarial review
**Quality Score:** [N]/100
**Duration:** [time from spawn to cleanup]

### Teammate Results
| # | Role | Status | Key Output |
|---|------|--------|------------|
| A | [role] | Complete | [1-line summary] |
| B | [role] | Complete | [1-line summary] |
| C | [role] | Complete | [1-line summary] |

### Adversarial Review Trail
- [N] review rounds between critic(s) and implementer(s)
- [N] issues found, [N] fixed, [N] remaining

### Files Modified
- [list with ownership attribution]

### Verification
- make check: PASS/FAIL
- Quality score: [N]/100

### Findings / Answers / Deliverables
[Main output of the swarm — research findings, implemented features, migration report, etc.]
```

### 8. Cleanup

Tear down the team. Log the summary to the session log.

---

## Preset Team Templates

### Research Swarm
```
/swarm research "How does the auth system work?"

Team:
  A: Trace code flow from API endpoints (read-only)
  B: Check git history and recent changes (read-only)
  C: Read tests to understand expected behavior (read-only)
  D: Search for related configuration and docs (read-only)

All read-only. Zero conflict risk. Maximum parallel exploration.
```

### Debug Swarm
```
/swarm debug "Login fails intermittently"

Team:
  A: Check for race conditions in session handling (read-only)
  B: Analyze database query patterns for timeouts (read-only)
  C: Review recent changes to auth module via git blame (read-only)
  D: Search logs and error patterns (read-only)

Each forms a hypothesis → reports to lead → lead synthesizes.
```

### Migration Swarm
```
/swarm migrate "Update all API handlers to new error format"

Team:
  A: Migrate src/handlers/auth/* (writer)
  B: Migrate src/handlers/users/* (writer)
  C: Migrate src/handlers/payments/* (writer)
  D: Update integration tests (writer, depends on A+B+C)
  E: Review all changes (reader/critic, depends on A+B+C+D)

Clear file ownership. Critic reviews AFTER all writers finish.
```

---

## Rules

1. **Always plan before spawning** — team structure must be explicit
2. **Always enforce adversarial separation** — writers ≠ reviewers
3. **Always verify the combined result** — individual success ≠ integrated success
4. **Always clean up** — don't leave orphaned teammate sessions
5. **Prefer smaller teams** — 2-4 is the sweet spot; only go larger with clear justification
