# /lint — Run Linters and Static Analysis

Run code quality checks and report results.

---

## Steps

1. Determine scope:
   - `/lint` → `make lint` (all files)
   - `/lint [file or directory]` → lint specific files
2. Run the linter
3. Report results grouped by severity

## Output Format

```
Lint Results:
- Errors: [N] (must fix)
- Warnings: [N] (should fix)
- Info: [N] (optional)
```

### For Each Issue
```
[severity] [file:line] [rule-id] — [message]
```

## Auto-Fix Mode
- If the user says `/lint fix` or `/lint --fix`, run `make format` first, then `make lint`
- Report what was auto-fixed and what remains

## Grouping
Group issues by file, then by severity within each file. Show the most critical issues first.
