#!/usr/bin/env python3
"""
Quality Score Calculator for Software Projects

Computes a quality score (0-100) based on automated checks:
- Build success
- Test pass rate
- Lint cleanliness
- Type check cleanliness
- Code quality heuristics (complexity, duplication, naming)

Quality Gates:
  80+ = Commit threshold (good enough to save progress)
  90+ = PR threshold (ready for merge)
  95+ = Release threshold (production-ready)

Usage:
  python3 scripts/score.py                    # Score entire project
  python3 scripts/score.py src/module.py      # Score specific file(s)
  python3 scripts/score.py --summary           # One-line summary
  python3 scripts/score.py --verbose           # Detailed breakdown
  python3 scripts/score.py --json              # JSON output

Exit codes:
  0 = Score >= 80 (commit-ready)
  1 = Score < 80 (blocked)
  2 = Auto-fail (critical issue)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Domain Types
# ---------------------------------------------------------------------------

class Severity(Enum):
    CRITICAL = "critical"
    MAJOR = "major"
    MINOR = "minor"
    INFO = "info"


class Gate(Enum):
    COMMIT = 80
    PR = 90
    RELEASE = 95


@dataclass(frozen=True)
class Finding:
    """An immutable quality finding."""
    severity: Severity
    category: str
    message: str
    file: Optional[str] = None
    line: Optional[int] = None
    deduction: int = 0


@dataclass
class ScoreResult:
    """Aggregated quality score with findings."""
    base_score: int = 100
    findings: list[Finding] = field(default_factory=list)
    bonus: int = 0
    auto_fail: bool = False
    auto_fail_reason: str = ""

    @property
    def total_deductions(self) -> int:
        return sum(f.deduction for f in self.findings)

    @property
    def score(self) -> int:
        if self.auto_fail:
            return 0
        raw = self.base_score - self.total_deductions + self.bonus
        return max(0, min(100, raw))

    @property
    def gate(self) -> str:
        if self.auto_fail:
            return "AUTO-FAIL"
        if self.score >= Gate.RELEASE.value:
            return "RELEASE"
        if self.score >= Gate.PR.value:
            return "PR"
        if self.score >= Gate.COMMIT.value:
            return "COMMIT"
        return "BLOCKED"

    def add_finding(self, finding: Finding) -> None:
        self.findings.append(finding)

    def critical_count(self) -> int:
        return sum(1 for f in self.findings if f.severity == Severity.CRITICAL)

    def major_count(self) -> int:
        return sum(1 for f in self.findings if f.severity == Severity.MAJOR)

    def minor_count(self) -> int:
        return sum(1 for f in self.findings if f.severity == Severity.MINOR)


# ---------------------------------------------------------------------------
# Checker Functions
# ---------------------------------------------------------------------------

def run_command(cmd: str, timeout: int = 120) -> tuple[int, str, str]:
    """Run a shell command and return (exit_code, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=_project_root(),
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out after {timeout}s: {cmd}"
    except FileNotFoundError:
        return -1, "", f"Command not found: {cmd}"


def _project_root() -> Path:
    """Find the project root (directory containing CLAUDE.md or Makefile)."""
    current = Path.cwd()
    for parent in [current, *current.parents]:
        if (parent / "CLAUDE.md").exists() or (parent / "Makefile").exists():
            return parent
    return current


def check_build(result: ScoreResult) -> None:
    """Check if the project builds successfully."""
    exit_code, stdout, stderr = run_command("make build 2>&1")
    if exit_code != 0:
        result.auto_fail = True
        result.auto_fail_reason = "Build failed"
        result.add_finding(Finding(
            severity=Severity.CRITICAL,
            category="build",
            message=f"Build failed: {stderr or stdout}",
            deduction=100,
        ))


def check_tests(result: ScoreResult) -> None:
    """Check test results."""
    exit_code, stdout, stderr = run_command("make test 2>&1")
    output = stdout + stderr

    if exit_code != 0:
        result.auto_fail = True
        result.auto_fail_reason = "Tests failed"
        result.add_finding(Finding(
            severity=Severity.CRITICAL,
            category="tests",
            message=f"Test suite failed: {output[:500]}",
            deduction=100,
        ))
        return

    # Try to parse test counts from common frameworks
    # pytest: "X passed, Y failed"
    # jest: "Tests: X passed, Y failed"
    # go: "ok" or "FAIL"
    passed = _extract_count(output, r"(\d+)\s+pass")
    failed = _extract_count(output, r"(\d+)\s+fail")

    if failed and failed > 0:
        result.add_finding(Finding(
            severity=Severity.CRITICAL,
            category="tests",
            message=f"{failed} tests failing",
            deduction=100,
        ))
        result.auto_fail = True
        result.auto_fail_reason = f"{failed} tests failing"


def check_lint(result: ScoreResult) -> None:
    """Check linter results."""
    exit_code, stdout, stderr = run_command("make lint 2>&1")
    output = stdout + stderr

    if exit_code != 0:
        # Count error lines (heuristic — most linters output one issue per line)
        error_lines = [
            line for line in output.splitlines()
            if re.search(r"error|Error|ERROR", line) and not line.startswith("make")
        ]
        warning_lines = [
            line for line in output.splitlines()
            if re.search(r"warning|Warning|WARN", line)
        ]

        for i, error in enumerate(error_lines[:10]):  # Cap at 10
            result.add_finding(Finding(
                severity=Severity.MAJOR,
                category="lint",
                message=error.strip(),
                deduction=5,
            ))

        for i, warning in enumerate(warning_lines[:10]):
            result.add_finding(Finding(
                severity=Severity.MINOR,
                category="lint",
                message=warning.strip(),
                deduction=1,
            ))


def check_typecheck(result: ScoreResult) -> None:
    """Check type checker results."""
    exit_code, stdout, stderr = run_command("make typecheck 2>&1")
    output = stdout + stderr

    # If typecheck is not configured, skip
    if "PLACEHOLDER" in output or "No rule" in output:
        return

    if exit_code != 0:
        error_count = len([
            line for line in output.splitlines()
            if re.search(r"error", line, re.IGNORECASE) and not line.startswith("make")
        ])
        for _ in range(min(error_count, 5)):
            result.add_finding(Finding(
                severity=Severity.MAJOR,
                category="typecheck",
                message="Type check error",
                deduction=20,
            ))


def check_source_heuristics(result: ScoreResult, files: list[Path]) -> None:
    """Run heuristic checks on source files."""
    for file_path in files:
        if not file_path.exists():
            continue
        try:
            content = file_path.read_text(encoding="utf-8", errors="replace")
        except (OSError, UnicodeDecodeError):
            continue

        lines = content.splitlines()

        # Check for overly long functions (heuristic: count lines between def/func/fn)
        _check_function_length(result, file_path, lines)

        # Check for potential secrets
        _check_secrets(result, file_path, lines)

        # Check for TODO without ticket reference
        _check_todos(result, file_path, lines)

        # Check for magic numbers
        _check_any_types(result, file_path, lines)


def _check_function_length(
    result: ScoreResult, file_path: Path, lines: list[str]
) -> None:
    """Flag functions longer than 50 lines."""
    func_pattern = re.compile(
        r"^\s*(def |func |fn |function |public |private |protected )"
    )
    func_start: Optional[int] = None
    func_name = ""

    for i, line in enumerate(lines):
        if func_pattern.match(line):
            if func_start is not None:
                length = i - func_start
                if length > 50:
                    result.add_finding(Finding(
                        severity=Severity.MAJOR,
                        category="complexity",
                        message=f"Function '{func_name}' is {length} lines (max recommended: 50)",
                        file=str(file_path),
                        line=func_start + 1,
                        deduction=3,
                    ))
            func_start = i
            # Extract function name (best effort)
            name_match = re.search(r"(?:def|func|fn|function)\s+(\w+)", line)
            func_name = name_match.group(1) if name_match else "unknown"


def _check_secrets(result: ScoreResult, file_path: Path, lines: list[str]) -> None:
    """Flag potential hardcoded secrets."""
    secret_patterns = [
        (r'(?:password|passwd|pwd)\s*=\s*["\'][^"\']+["\']', "Potential hardcoded password"),
        (r'(?:api_key|apikey|api_secret)\s*=\s*["\'][^"\']+["\']', "Potential hardcoded API key"),
        (r'(?:secret|token)\s*=\s*["\'][A-Za-z0-9+/=]{20,}["\']', "Potential hardcoded secret/token"),
        (r'(?:AWS_SECRET|aws_secret)\s*=\s*["\'][^"\']+["\']', "Potential hardcoded AWS secret"),
    ]

    for i, line in enumerate(lines):
        # Skip comments and test files
        stripped = line.strip()
        if stripped.startswith(("#", "//", "*", "/*")):
            continue
        if "test" in str(file_path).lower() or "mock" in str(file_path).lower():
            continue

        for pattern, message in secret_patterns:
            if re.search(pattern, line, re.IGNORECASE):
                result.auto_fail = True
                result.auto_fail_reason = "Hardcoded secrets detected"
                result.add_finding(Finding(
                    severity=Severity.CRITICAL,
                    category="security",
                    message=message,
                    file=str(file_path),
                    line=i + 1,
                    deduction=25,
                ))


def _check_todos(result: ScoreResult, file_path: Path, lines: list[str]) -> None:
    """Flag TODOs without ticket references."""
    for i, line in enumerate(lines):
        if re.search(r"TODO|FIXME|HACK|XXX", line):
            # Check if it has a ticket reference like #123, JIRA-456, etc.
            if not re.search(r"#\d+|[A-Z]+-\d+", line):
                result.add_finding(Finding(
                    severity=Severity.MINOR,
                    category="maintenance",
                    message="TODO/FIXME without ticket reference",
                    file=str(file_path),
                    line=i + 1,
                    deduction=1,
                ))


def _check_any_types(result: ScoreResult, file_path: Path, lines: list[str]) -> None:
    """Flag use of untyped escape hatches."""
    any_patterns = [
        (r"\bany\b", ".ts", "Use of 'any' type"),
        (r"\binterface\s*\{\s*\}", ".go", "Use of empty interface{}"),
        (r"# type:\s*ignore", ".py", "Type ignore comment"),
        (r"@ts-ignore|@ts-expect-error", ".ts", "TypeScript type suppression"),
    ]

    suffix = file_path.suffix
    for pattern, ext, message in any_patterns:
        if suffix == ext or ext == "":
            for i, line in enumerate(lines):
                if re.search(pattern, line):
                    result.add_finding(Finding(
                        severity=Severity.MINOR,
                        category="typing",
                        message=message,
                        file=str(file_path),
                        line=i + 1,
                        deduction=2,
                    ))


def _extract_count(text: str, pattern: str) -> Optional[int]:
    """Extract a number from text using a regex pattern."""
    match = re.search(pattern, text, re.IGNORECASE)
    if match:
        return int(match.group(1))
    return None


# ---------------------------------------------------------------------------
# File Discovery
# ---------------------------------------------------------------------------

SOURCE_EXTENSIONS = {
    ".py", ".ts", ".tsx", ".js", ".jsx",
    ".go", ".rs", ".java", ".rb",
    ".c", ".cpp", ".h", ".hpp",
    ".cs", ".swift", ".kt",
}


def discover_source_files(targets: list[str]) -> list[Path]:
    """Find source files to analyze."""
    root = _project_root()
    files: list[Path] = []

    if not targets:
        # Scan src/ and tests/ by default
        for directory in ["src", "tests", "lib", "app", "pkg", "internal", "cmd"]:
            dir_path = root / directory
            if dir_path.exists():
                for ext in SOURCE_EXTENSIONS:
                    files.extend(dir_path.rglob(f"*{ext}"))
    else:
        for target in targets:
            path = Path(target)
            if path.is_file():
                files.append(path)
            elif path.is_dir():
                for ext in SOURCE_EXTENSIONS:
                    files.extend(path.rglob(f"*{ext}"))
            else:
                # Try as glob pattern
                files.extend(root.glob(target))

    return sorted(set(files))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def compute_score(targets: list[str], verbose: bool = False) -> ScoreResult:
    """Compute the quality score for the project or specific targets."""
    result = ScoreResult()

    # Phase 1: Build checks
    if verbose:
        print("Checking build...", file=sys.stderr)
    check_build(result)
    if result.auto_fail:
        return result

    # Phase 2: Test checks
    if verbose:
        print("Checking tests...", file=sys.stderr)
    check_tests(result)
    if result.auto_fail:
        return result

    # Phase 3: Lint checks
    if verbose:
        print("Checking lint...", file=sys.stderr)
    check_lint(result)

    # Phase 4: Type checks
    if verbose:
        print("Checking types...", file=sys.stderr)
    check_typecheck(result)

    # Phase 5: Source heuristics
    if verbose:
        print("Running source heuristics...", file=sys.stderr)
    files = discover_source_files(targets)
    check_source_heuristics(result, files)

    return result


def format_summary(result: ScoreResult) -> str:
    """One-line summary."""
    return (
        f"Quality Score: {result.score}/100 [{result.gate}] "
        f"({result.critical_count()} critical, "
        f"{result.major_count()} major, "
        f"{result.minor_count()} minor)"
    )


def format_verbose(result: ScoreResult) -> str:
    """Detailed breakdown."""
    lines = [
        f"Quality Score: {result.score}/100",
        f"Gate: {result.gate}",
        f"",
        f"Findings ({len(result.findings)}):",
    ]

    if result.auto_fail:
        lines.append(f"  AUTO-FAIL: {result.auto_fail_reason}")
        lines.append("")

    for severity in Severity:
        findings = [f for f in result.findings if f.severity == severity]
        if findings:
            lines.append(f"  [{severity.value.upper()}]")
            for f in findings:
                loc = f"{f.file}:{f.line}" if f.file else "project"
                lines.append(f"    - [{loc}] {f.message} (-{f.deduction})")
            lines.append("")

    lines.append("Quality Gates:")
    lines.append(f"  Commit (80):  {'PASS' if result.score >= 80 else 'FAIL'}")
    lines.append(f"  PR (90):      {'PASS' if result.score >= 90 else 'FAIL'}")
    lines.append(f"  Release (95): {'PASS' if result.score >= 95 else 'FAIL'}")

    return "\n".join(lines)


def format_json(result: ScoreResult) -> str:
    """JSON output."""
    return json.dumps(
        {
            "score": result.score,
            "gate": result.gate,
            "auto_fail": result.auto_fail,
            "auto_fail_reason": result.auto_fail_reason,
            "findings": [
                {
                    "severity": f.severity.value,
                    "category": f.category,
                    "message": f.message,
                    "file": f.file,
                    "line": f.line,
                    "deduction": f.deduction,
                }
                for f in result.findings
            ],
            "summary": {
                "critical": result.critical_count(),
                "major": result.major_count(),
                "minor": result.minor_count(),
                "total_deductions": result.total_deductions,
                "bonus": result.bonus,
            },
        },
        indent=2,
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Quality Score Calculator — rates your project 0-100",
    )
    parser.add_argument(
        "targets",
        nargs="*",
        help="Files or directories to score (default: entire project)",
    )
    parser.add_argument(
        "--summary", action="store_true", help="One-line summary output"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Detailed breakdown"
    )
    parser.add_argument(
        "--json", action="store_true", dest="json_output", help="JSON output"
    )

    args = parser.parse_args()

    result = compute_score(args.targets, verbose=args.verbose)

    if args.json_output:
        print(format_json(result))
    elif args.summary:
        print(format_summary(result))
    elif args.verbose:
        print(format_verbose(result))
    else:
        print(format_summary(result))
        if result.score < Gate.COMMIT.value:
            print()
            print(format_verbose(result))

    # Exit codes: 0 = commit-ready, 1 = blocked, 2 = auto-fail
    if result.auto_fail:
        sys.exit(2)
    elif result.score < Gate.COMMIT.value:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
