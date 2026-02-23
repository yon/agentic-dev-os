#!/usr/bin/env bash
# install.sh — Install the Agentic Development Framework into an existing project
#
# Usage:
#   ./install.sh [OPTIONS] [TARGET_DIR]
#
# Downloads framework files from GitHub (or uses a local source) and installs
# them into the target project with automatic stack detection and configuration.
#
# Options:
#   --source PATH    Use local framework repo instead of GitHub download
#   --ref REF        GitHub branch/tag to download (default: main)
#   --force          Overwrite existing .claude/ directory
#   --no-detect      Skip language/stack auto-detection
#   --dry-run        Show what would happen without making changes
#   --help, -h       Show usage information

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

readonly INSTALLER_VERSION="1.0.0"
readonly GITHUB_REPO="yon/agentic-dev-os"
readonly DEFAULT_REF="main"

# Colors (only if terminal supports them)
if [[ -t 1 ]]; then
    readonly BOLD=$'\033[1m'
    readonly DIM=$'\033[2m'
    readonly RED=$'\033[31m'
    readonly GREEN=$'\033[32m'
    readonly YELLOW=$'\033[33m'
    readonly BLUE=$'\033[34m'
    readonly CYAN=$'\033[36m'
    readonly RESET=$'\033[0m'
    readonly CHECK="${GREEN}✓${RESET}"
    readonly CROSS="${RED}✗${RESET}"
    readonly ARROW="${BLUE}→${RESET}"
else
    readonly BOLD="" DIM="" RED="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
    readonly CHECK="[OK]" CROSS="[FAIL]" ARROW="->"
fi

# Counters
FILES_COPIED=0
FILES_SKIPPED=0
WARNINGS=()
STEP_NUM=0
STEP_TOTAL=0

# ---------------------------------------------------------------------------
# Utility functions
# ---------------------------------------------------------------------------

info()    { echo "  ${BLUE}info${RESET}  $*"; }
success() { echo "  ${GREEN}ok${RESET}    $*"; }
warn()    { echo "  ${YELLOW}warn${RESET}  $*"; WARNINGS+=("$*"); }
die()     { echo "  ${RED}error${RESET} $*" >&2; exit 1; }

step() {
    STEP_NUM=$((STEP_NUM + 1))
    echo ""
    echo "${BOLD}[${STEP_NUM}/${STEP_TOTAL}] $*${RESET}"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local yn

    if [[ "$default" == "y" ]]; then
        printf "  %s [Y/n] " "$prompt"
    else
        printf "  %s [y/N] " "$prompt"
    fi

    read -r yn
    yn="${yn:-$default}"
    case "$yn" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

# Portable sed-in-place using temp file (avoids macOS vs Linux sed -i issues)
safe_sed() {
    local pattern="$1"
    local file="$2"
    local tmp="${file}.tmp.$$"
    sed "$pattern" "$file" > "$tmp" && mv "$tmp" "$file"
}

usage() {
    cat <<EOF
${BOLD}Agentic Development Framework Installer${RESET} v${INSTALLER_VERSION}

Install the framework into an existing project.

${BOLD}Usage:${RESET}
  ./install.sh [OPTIONS] [TARGET_DIR]

${BOLD}Arguments:${RESET}
  TARGET_DIR          Target project directory (default: current directory)

${BOLD}Options:${RESET}
  --source PATH       Use local framework repo instead of downloading from GitHub
  --ref REF           GitHub branch or tag to download (default: ${DEFAULT_REF})
  --force             Overwrite existing .claude/ directory
  --no-detect         Skip language/stack auto-detection
  --dry-run           Show what would be installed without making changes
  --help, -h          Show this help message

${BOLD}Examples:${RESET}
  # Install into current directory (downloads from GitHub)
  ./install.sh

  # Install into a specific project
  ./install.sh /path/to/my-project

  # Use a specific version
  ./install.sh --ref v1.0.0 /path/to/my-project

  # Use a local clone instead of downloading
  ./install.sh --source ~/src/agentic-dev-os /path/to/my-project

  # Force reinstall
  ./install.sh --force

${BOLD}What gets installed:${RESET}
  .claude/            Rules, agents, skills, hooks, settings
  MEMORY.md           Auto-memory template (also copied to ~/.claude/projects/...)
  Makefile            Self-documenting build commands (skipped if exists)
  scripts/score.py    Quality scoring (0-100)
  working/            Plan and session log directories
  .gitignore          Merged with existing (never overwrites)
EOF
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------

check_prerequisites() {
    local target_dir="$1"
    local force="$2"

    command -v git >/dev/null 2>&1 || die "git is not installed"

    git -C "$target_dir" rev-parse --git-dir >/dev/null 2>&1 \
        || die "Target is not a git repository: $target_dir"

    if [[ -d "$target_dir/.claude" ]] && [[ "$force" != "true" ]]; then
        die "Framework already installed (.claude/ exists). Use --force to overwrite."
    fi
}

validate_source() {
    local source_dir="$1"

    [[ -d "$source_dir" ]] \
        || die "Source directory does not exist: $source_dir"
    [[ -f "$source_dir/.claude/CLAUDE.md" ]] \
        || die "Not a valid framework repo (missing .claude/CLAUDE.md): $source_dir"
    [[ -d "$source_dir/.claude/rules" ]] \
        || die "Not a valid framework repo (missing .claude/rules/): $source_dir"
}

# ---------------------------------------------------------------------------
# Fetch framework from GitHub
# ---------------------------------------------------------------------------

fetch_from_github() {
    local ref="$1"
    local tmpdir="$2"
    local archive_name="${GITHUB_REPO##*/}-${ref}"
    local url="https://github.com/${GITHUB_REPO}/archive/${ref}.tar.gz"

    command -v curl >/dev/null 2>&1 || die "curl is required for GitHub download (or use --source)"

    info "Downloading from github.com/${GITHUB_REPO} (ref: ${ref})"

    # Download and extract only the directories we need
    local http_code
    http_code=$(curl -sL -w "%{http_code}" -o "${tmpdir}/archive.tar.gz" "$url")

    if [[ "$http_code" != "200" ]]; then
        die "GitHub download failed (HTTP ${http_code}). Check repo/ref: ${url}"
    fi

    tar xzf "${tmpdir}/archive.tar.gz" -C "$tmpdir" --strip-components=1 \
        || die "Failed to extract archive"

    rm -f "${tmpdir}/archive.tar.gz"

    validate_source "$tmpdir"
    success "Downloaded framework (ref: ${ref})"
}

# ---------------------------------------------------------------------------
# Stack detection
# ---------------------------------------------------------------------------

detect_stack() {
    local target_dir="$1"

    # Reset detection globals
    DETECTED_LANG=""
    DETECTED_BUILD=""
    DETECTED_TEST=""
    DETECTED_TEST_UNIT=""
    DETECTED_TEST_INT=""
    DETECTED_LINT=""
    DETECTED_FORMAT=""
    DETECTED_TYPECHECK=""
    DETECTED_SECURITY=""
    DETECTED_COVERAGE=""
    DETECTED_DEPS=""

    # Python
    if [[ -f "$target_dir/pyproject.toml" ]] || [[ -f "$target_dir/setup.py" ]] \
       || [[ -f "$target_dir/requirements.txt" ]] || [[ -f "$target_dir/Pipfile" ]]; then
        DETECTED_LANG="python"
        DETECTED_BUILD="python -m build"
        DETECTED_TEST="pytest"
        DETECTED_TEST_UNIT="pytest tests/unit -x -q"
        DETECTED_TEST_INT="pytest tests/integration -x -q"
        DETECTED_LINT="ruff check src tests"
        DETECTED_FORMAT="ruff format src tests"
        DETECTED_TYPECHECK="mypy src"
        DETECTED_SECURITY="pip-audit"
        DETECTED_COVERAGE="pytest --cov=src --cov-report=html"
        DETECTED_DEPS="pip install -e '.[dev]'"

        # Detect specific tools from pyproject.toml
        if [[ -f "$target_dir/pyproject.toml" ]]; then
            if grep -q 'flake8' "$target_dir/pyproject.toml" 2>/dev/null; then
                DETECTED_LINT="flake8 src tests"
            fi
            if grep -q 'black' "$target_dir/pyproject.toml" 2>/dev/null; then
                DETECTED_FORMAT="black src tests"
            fi
            if grep -q 'pyright' "$target_dir/pyproject.toml" 2>/dev/null; then
                DETECTED_TYPECHECK="pyright src"
            fi
        fi
        return
    fi

    # Node.js / TypeScript
    if [[ -f "$target_dir/package.json" ]]; then
        DETECTED_LANG="node"
        DETECTED_BUILD="npm run build"
        DETECTED_TEST="npm test"
        DETECTED_DEPS="npm install"
        DETECTED_SECURITY="npm audit"

        if [[ -f "$target_dir/tsconfig.json" ]]; then
            DETECTED_LANG="typescript"
            DETECTED_TYPECHECK="npx tsc --noEmit"
        fi

        # Detect test runner
        if grep -q '"vitest"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_TEST="npx vitest run"
            DETECTED_TEST_UNIT="npx vitest run tests/unit"
            DETECTED_TEST_INT="npx vitest run tests/integration"
            DETECTED_COVERAGE="npx vitest run --coverage"
        elif grep -q '"jest"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_TEST="npx jest"
            DETECTED_TEST_UNIT="npx jest tests/unit"
            DETECTED_TEST_INT="npx jest tests/integration"
            DETECTED_COVERAGE="npx jest --coverage"
        fi

        # Detect linter
        if grep -q '"eslint"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_LINT="npx eslint src tests"
        elif grep -q '"biome"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_LINT="npx biome check src tests"
        fi

        # Detect formatter
        if grep -q '"prettier"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_FORMAT="npx prettier --write src tests"
        elif grep -q '"biome"' "$target_dir/package.json" 2>/dev/null; then
            DETECTED_FORMAT="npx biome format --write src tests"
        fi
        return
    fi

    # Go
    if [[ -f "$target_dir/go.mod" ]]; then
        DETECTED_LANG="go"
        DETECTED_BUILD="go build ./..."
        DETECTED_TEST="go test ./..."
        DETECTED_TEST_UNIT="go test ./..."
        DETECTED_TEST_INT="go test -tags=integration ./..."
        DETECTED_LINT="golangci-lint run"
        DETECTED_FORMAT="gofmt -w ."
        DETECTED_TYPECHECK="go vet ./..."
        DETECTED_SECURITY="govulncheck ./..."
        DETECTED_COVERAGE="go test -coverprofile=coverage.out ./..."
        DETECTED_DEPS="go mod download"
        return
    fi

    # Rust
    if [[ -f "$target_dir/Cargo.toml" ]]; then
        DETECTED_LANG="rust"
        DETECTED_BUILD="cargo build"
        DETECTED_TEST="cargo test"
        DETECTED_TEST_UNIT="cargo test --lib"
        DETECTED_TEST_INT="cargo test --test '*'"
        DETECTED_LINT="cargo clippy -- -D warnings"
        DETECTED_FORMAT="cargo fmt"
        DETECTED_TYPECHECK="cargo check"
        DETECTED_SECURITY="cargo audit"
        DETECTED_COVERAGE="cargo tarpaulin --out Html"
        DETECTED_DEPS="cargo fetch"
        return
    fi

    # Java (Maven)
    if [[ -f "$target_dir/pom.xml" ]]; then
        DETECTED_LANG="java-maven"
        DETECTED_BUILD="mvn compile"
        DETECTED_TEST="mvn test"
        DETECTED_LINT="mvn checkstyle:check"
        DETECTED_DEPS="mvn dependency:resolve"
        return
    fi

    # Java (Gradle)
    if [[ -f "$target_dir/build.gradle" ]] || [[ -f "$target_dir/build.gradle.kts" ]]; then
        DETECTED_LANG="java-gradle"
        DETECTED_BUILD="./gradlew build"
        DETECTED_TEST="./gradlew test"
        DETECTED_LINT="./gradlew check"
        DETECTED_DEPS="./gradlew dependencies"
        return
    fi
}

# ---------------------------------------------------------------------------
# File installation
# ---------------------------------------------------------------------------

copy_claude_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local force="$3"

    if [[ -d "$target_dir/.claude" ]]; then
        if [[ "$force" == "true" ]]; then
            warn "Overwriting existing .claude/ directory"
            rm -rf "$target_dir/.claude"
        fi
    fi

    mkdir -p "$target_dir/.claude"

    # Top-level config files
    cp "$source_dir/.claude/CLAUDE.md" "$target_dir/.claude/CLAUDE.md"
    cp "$source_dir/.claude/settings.json" "$target_dir/.claude/settings.json"
    FILES_COPIED=$((FILES_COPIED + 2))

    # Hooks
    mkdir -p "$target_dir/.claude/hooks"
    for f in "$source_dir"/.claude/hooks/*; do
        [[ -f "$f" ]] || continue
        cp "$f" "$target_dir/.claude/hooks/"
        chmod +x "$target_dir/.claude/hooks/$(basename "$f")"
        FILES_COPIED=$((FILES_COPIED + 1))
    done

    # Rules
    mkdir -p "$target_dir/.claude/rules"
    local count=0
    for f in "$source_dir"/.claude/rules/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$target_dir/.claude/rules/"
        count=$((count + 1))
    done
    FILES_COPIED=$((FILES_COPIED + count))
    info "Copied ${count} rules"

    # Agents
    mkdir -p "$target_dir/.claude/agents"
    count=0
    for f in "$source_dir"/.claude/agents/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$target_dir/.claude/agents/"
        count=$((count + 1))
    done
    FILES_COPIED=$((FILES_COPIED + count))
    info "Copied ${count} agents"

    # Skills (recursive — each skill is a directory)
    mkdir -p "$target_dir/.claude/skills"
    count=0
    local skill_count=0
    for skill_dir in "$source_dir"/.claude/skills/*/; do
        [[ -d "$skill_dir" ]] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        mkdir -p "$target_dir/.claude/skills/$skill_name"
        skill_count=$((skill_count + 1))
        for f in "$skill_dir"*; do
            [[ -f "$f" ]] || continue
            cp "$f" "$target_dir/.claude/skills/$skill_name/"
            count=$((count + 1))
        done
    done
    FILES_COPIED=$((FILES_COPIED + count))
    info "Copied ${count} skill files across ${skill_count} skills"

    success ".claude/ directory installed"
}

copy_scripts() {
    local source_dir="$1"
    local target_dir="$2"

    mkdir -p "$target_dir/scripts"

    if [[ -f "$target_dir/scripts/score.py" ]]; then
        warn "scripts/score.py already exists — skipping"
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        return
    fi

    cp "$source_dir/scripts/score.py" "$target_dir/scripts/score.py"
    chmod +x "$target_dir/scripts/score.py"
    FILES_COPIED=$((FILES_COPIED + 1))
    success "scripts/score.py installed"
}

create_working_dirs() {
    local target_dir="$1"

    mkdir -p "$target_dir/working/plans" "$target_dir/working/logs"
    [[ -f "$target_dir/working/plans/.gitkeep" ]] || touch "$target_dir/working/plans/.gitkeep"
    [[ -f "$target_dir/working/logs/.gitkeep" ]] || touch "$target_dir/working/logs/.gitkeep"
    success "working/plans/ and working/logs/ ready"
}

merge_gitignore() {
    local source_dir="$1"
    local target_dir="$2"
    local source_file="$source_dir/.gitignore"
    local target_file="$target_dir/.gitignore"

    if [[ ! -f "$source_file" ]]; then
        warn "No .gitignore in framework source"
        return
    fi

    # No existing .gitignore — just copy
    if [[ ! -f "$target_file" ]]; then
        cp "$source_file" "$target_file"
        FILES_COPIED=$((FILES_COPIED + 1))
        success ".gitignore created"
        return
    fi

    # Check if already merged (idempotency)
    local marker="# --- Agentic Development Framework ---"
    if grep -qF "$marker" "$target_file" 2>/dev/null; then
        info ".gitignore already contains framework entries"
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        return
    fi

    # Merge: append new entries
    local added=0
    local skipped=0

    {
        echo ""
        echo "$marker"
    } >> "$target_file"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Pass through comments and blank lines
        if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then
            echo "$line" >> "$target_file"
            continue
        fi

        # Skip entries that already exist in the target
        if grep -qxF "$line" "$target_file" 2>/dev/null; then
            skipped=$((skipped + 1))
        else
            echo "$line" >> "$target_file"
            added=$((added + 1))
        fi
    done < "$source_file"

    success ".gitignore merged (${added} added, ${skipped} already present)"
}

install_makefile() {
    local source_dir="$1"
    local target_dir="$2"

    if [[ -f "$target_dir/Makefile" ]]; then
        warn "Makefile already exists — skipping (see ${source_dir}/Makefile for framework targets)"
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        return
    fi

    cp "$source_dir/Makefile" "$target_dir/Makefile"
    FILES_COPIED=$((FILES_COPIED + 1))

    # Pre-fill with detected stack commands
    if [[ -n "$DETECTED_LANG" ]]; then
        info "Pre-filling Makefile for ${DETECTED_LANG}"

        local makefile="$target_dir/Makefile"

        [[ -n "$DETECTED_BUILD" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your build command\"|${DETECTED_BUILD}|" "$makefile"
        [[ -n "$DETECTED_TEST" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your test command\"|${DETECTED_TEST}|" "$makefile"
        [[ -n "$DETECTED_TEST_UNIT" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with unit test command (e.g., pytest tests/unit)\"|${DETECTED_TEST_UNIT}|" "$makefile"
        [[ -n "$DETECTED_TEST_INT" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with integration test command (e.g., pytest tests/integration)\"|${DETECTED_TEST_INT}|" "$makefile"
        [[ -n "$DETECTED_LINT" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your lint command\"|${DETECTED_LINT}|" "$makefile"
        [[ -n "$DETECTED_FORMAT" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your format command\"|${DETECTED_FORMAT}|" "$makefile"
        [[ -n "$DETECTED_TYPECHECK" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your typecheck command\"|${DETECTED_TYPECHECK}|" "$makefile"
        [[ -n "$DETECTED_SECURITY" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your security audit command\"|${DETECTED_SECURITY}|" "$makefile"
        [[ -n "$DETECTED_COVERAGE" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your coverage command\"|${DETECTED_COVERAGE}|" "$makefile"
        [[ -n "$DETECTED_DEPS" ]] && \
            safe_sed "s|echo \"\[PLACEHOLDER\] Replace with your dependency install command\"|${DETECTED_DEPS}|" "$makefile"

        success "Makefile installed with ${DETECTED_LANG} defaults"
    else
        success "Makefile installed (placeholders need manual configuration)"
    fi
}

# ---------------------------------------------------------------------------
# Auto-memory setup
# ---------------------------------------------------------------------------

compute_memory_path() {
    local target_dir="$1"
    local abs_path
    abs_path="$(cd "$target_dir" && pwd -P)"

    # Claude Code format: replace / with - (e.g. /Users/yon/src/foo → -Users-yon-src-foo)
    local slug
    slug="$(echo "$abs_path" | sed 's|/|-|g')"

    echo "${HOME}/.claude/projects/${slug}/memory"
}

setup_auto_memory() {
    local source_dir="$1"
    local target_dir="$2"

    # Copy to project root
    cp "$source_dir/MEMORY.md" "$target_dir/MEMORY.md"
    FILES_COPIED=$((FILES_COPIED + 1))
    success "MEMORY.md copied to project root"

    # Copy to auto-memory directory
    local memory_dir
    memory_dir="$(compute_memory_path "$target_dir")"

    mkdir -p "$memory_dir"
    cp "$source_dir/MEMORY.md" "$memory_dir/MEMORY.md"
    FILES_COPIED=$((FILES_COPIED + 1))
    success "MEMORY.md → ${memory_dir}/MEMORY.md"
}

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

validate_installation() {
    local target_dir="$1"
    local all_pass=true

    info "Validating installation..."

    # Check directories
    local dirs=(".claude" ".claude/rules" ".claude/agents" ".claude/skills" ".claude/hooks"
                "scripts" "working/plans" "working/logs")
    for dir in "${dirs[@]}"; do
        if [[ -d "$target_dir/$dir" ]]; then
            echo "    ${CHECK} ${dir}/"
        else
            echo "    ${CROSS} ${dir}/ (missing)"
            all_pass=false
        fi
    done

    # Check key files
    local files=(".claude/CLAUDE.md" ".claude/settings.json"
                 ".claude/hooks/block-dangerous-git.sh" "MEMORY.md" "scripts/score.py")
    for file in "${files[@]}"; do
        if [[ -f "$target_dir/$file" ]]; then
            echo "    ${CHECK} ${file}"
        else
            echo "    ${CROSS} ${file} (missing)"
            all_pass=false
        fi
    done

    # Check hook is executable
    if [[ -x "$target_dir/.claude/hooks/block-dangerous-git.sh" ]]; then
        echo "    ${CHECK} hook script is executable"
    else
        echo "    ${CROSS} hook script is not executable"
        all_pass=false
    fi

    # Check auto-memory
    local memory_dir
    memory_dir="$(compute_memory_path "$target_dir")"
    if [[ -f "$memory_dir/MEMORY.md" ]]; then
        echo "    ${CHECK} auto-memory MEMORY.md"
    else
        echo "    ${CROSS} auto-memory MEMORY.md (expected at ${memory_dir})"
        all_pass=false
    fi

    # Count installed files
    local rules_count agents_count skills_count
    rules_count=$(find "$target_dir/.claude/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    agents_count=$(find "$target_dir/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    skills_count=$(find "$target_dir/.claude/skills" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "    ${CHECK} ${rules_count} rules, ${agents_count} agents, ${skills_count} skill files"

    if $all_pass; then
        success "All checks passed"
    else
        warn "Some checks failed (see above)"
    fi
}

# ---------------------------------------------------------------------------
# Post-install: LLM analysis prompt & manual checklist
# ---------------------------------------------------------------------------

print_analysis_prompt() {
    echo ""
    echo "  ${BOLD}${CYAN}Recommended: Let Claude analyze your project${RESET}"
    echo ""
    echo "  Start a Claude session in your project and paste this prompt:"
    echo ""
    echo "  ${DIM}────────────────────────────────────────────────${RESET}"
    cat <<'PROMPT'

  Analyze this project and customize the framework for it:

  1. Read .claude/CLAUDE.md — find all [BRACKETED PLACEHOLDERS]
  2. Explore the codebase (src/, tests/, config files, README)
  3. Fill in CLAUDE.md:
     - Project name, description, tech stack
     - Folder structure (actual, not template)
     - Design patterns used
     - Current project state
  4. Update MEMORY.md (project root + auto-memory copy):
     - Replace [PROJECT NAME]
     - Update Current Project State
     - Update Verification Checklist
  5. Check Makefile: run `make help` and fix any remaining placeholders
  6. Remove CLAUDE.md sections that don't apply

PROMPT
    echo "  ${DIM}────────────────────────────────────────────────${RESET}"
    echo ""
}

print_manual_checklist() {
    local target_dir="$1"

    echo ""
    echo "  ${BOLD}Manual Customization Checklist${RESET}"
    echo ""
    echo "  ${BOLD}1. .claude/CLAUDE.md${RESET} (most important)"
    echo "     ${ARROW} Replace [YOUR PROJECT NAME], [DESCRIBE YOUR PROJECT HERE]"
    echo "     ${ARROW} Fill in Tech Stack table"
    echo "     ${ARROW} Update Folder Structure"
    echo "     ${ARROW} Remove sections that don't apply"
    echo ""
    echo "  ${BOLD}2. Makefile${RESET}"
    if [[ -n "$DETECTED_LANG" ]]; then
        echo "     ${ARROW} Partially pre-filled for ${DETECTED_LANG} — verify commands"
    fi
    echo "     ${ARROW} Replace any remaining [PLACEHOLDER] values"
    echo "     ${ARROW} Run ${CYAN}make help${RESET} to verify"
    echo ""
    echo "  ${BOLD}3. MEMORY.md${RESET} (project root + auto-memory copy)"
    echo "     ${ARROW} Replace [PROJECT NAME]"
    echo "     ${ARROW} Update Current Project State"
    echo ""
    echo "  ${BOLD}4. .claude/rules/code-conventions.md${RESET}"
    echo "     ${ARROW} Set naming conventions for your language"
    echo ""
}

print_summary() {
    local target_dir="$1"

    echo ""
    echo "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo "  ${BOLD}${GREEN}  Installation Complete${RESET}"
    echo "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo "  ${BOLD}Files copied:${RESET}  ${FILES_COPIED}"
    echo "  ${BOLD}Files skipped:${RESET} ${FILES_SKIPPED}"
    [[ -n "$DETECTED_LANG" ]] && echo "  ${BOLD}Detected stack:${RESET} ${DETECTED_LANG}"
    echo ""

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo "  ${YELLOW}${BOLD}Warnings:${RESET}"
        for w in "${WARNINGS[@]}"; do
            echo "    ${YELLOW}!${RESET} $w"
        done
        echo ""
    fi

    echo "  ${BOLD}Installed:${RESET}"
    echo "    ${ARROW} .claude/rules/         9 engineering rules (auto-loaded)"
    echo "    ${ARROW} .claude/agents/        8 review specialist agents"
    echo "    ${ARROW} .claude/skills/        14 slash commands"
    echo "    ${ARROW} .claude/hooks/         Git guardrails"
    echo "    ${ARROW} .claude/settings.json  Permissions + verification hook"
    echo "    ${ARROW} scripts/score.py       Quality scoring (0-100)"
    echo "    ${ARROW} working/               Plans + session logs"
    echo "    ${ARROW} MEMORY.md              Auto-memory template"
    [[ -f "$target_dir/Makefile" ]] && \
    echo "    ${ARROW} Makefile               Build commands"
    echo "    ${ARROW} .gitignore             Merged"
    echo ""

    echo "  ${BOLD}Next steps:${RESET}"
    echo "    1. Customize .claude/CLAUDE.md with your project details"
    echo "    2. Verify Makefile: ${CYAN}make help${RESET}"
    echo "    3. Start Claude: ${CYAN}cd ${target_dir} && claude${RESET}"
    echo "    4. Try: ${CYAN}/explore-module src/${RESET}"
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    local force=false
    local no_detect=false
    local dry_run=false
    local source_dir=""
    local ref="$DEFAULT_REF"
    local target_dir="."

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)      force=true; shift ;;
            --no-detect)  no_detect=true; shift ;;
            --dry-run)    dry_run=true; shift ;;
            --source)
                [[ -n "${2:-}" ]] || die "--source requires a path"
                source_dir="$2"; shift 2 ;;
            --source=*)   source_dir="${1#--source=}"; shift ;;
            --ref)
                [[ -n "${2:-}" ]] || die "--ref requires a value"
                ref="$2"; shift 2 ;;
            --ref=*)      ref="${1#--ref=}"; shift ;;
            --help|-h)    usage; exit 0 ;;
            -*)           die "Unknown option: $1 (see --help)" ;;
            *)            target_dir="$1"; shift ;;
        esac
    done

    # Resolve target to absolute path
    [[ -d "$target_dir" ]] || die "Target directory does not exist: $target_dir"
    target_dir="$(cd "$target_dir" && pwd -P)"

    # If running from within the framework repo and no --source given,
    # auto-detect the script's own directory as the source
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    if [[ -z "$source_dir" ]] && [[ -f "$script_dir/.claude/CLAUDE.md" ]]; then
        # Running from the framework repo — use it as source
        source_dir="$script_dir"
    fi

    # Prevent installing into the framework repo itself
    if [[ -n "$source_dir" ]]; then
        source_dir="$(cd "$source_dir" && pwd -P)"
        [[ "$source_dir" != "$target_dir" ]] || die "Cannot install framework into itself"
    fi

    # Header
    echo ""
    echo "${BOLD}${CYAN}Agentic Development Framework${RESET} ${DIM}v${INSTALLER_VERSION}${RESET}"
    echo "${DIM}Target: ${target_dir}${RESET}"
    echo ""

    # Determine step count
    STEP_TOTAL=6
    [[ "$no_detect" != "true" ]] && STEP_TOTAL=7

    # --- Step 1: Prerequisites ---
    step "Checking prerequisites"
    check_prerequisites "$target_dir" "$force"
    success "Prerequisites OK"

    # --- Step 2: Fetch framework (if no local source) ---
    local tmpdir=""
    if [[ -z "$source_dir" ]]; then
        step "Downloading framework"
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT
        fetch_from_github "$ref" "$tmpdir"
        source_dir="$tmpdir"
    else
        step "Using local source"
        validate_source "$source_dir"
        success "Source: ${source_dir}"
    fi

    # --- Step 3: Detect stack (optional) ---
    DETECTED_LANG=""
    if [[ "$no_detect" != "true" ]]; then
        step "Detecting project stack"
        detect_stack "$target_dir"
        if [[ -n "$DETECTED_LANG" ]]; then
            success "Detected: ${DETECTED_LANG}"
            [[ -n "$DETECTED_BUILD" ]]     && info "Build:     ${DETECTED_BUILD}"
            [[ -n "$DETECTED_TEST" ]]      && info "Test:      ${DETECTED_TEST}"
            [[ -n "$DETECTED_LINT" ]]      && info "Lint:      ${DETECTED_LINT}"
            [[ -n "$DETECTED_FORMAT" ]]    && info "Format:    ${DETECTED_FORMAT}"
            [[ -n "$DETECTED_TYPECHECK" ]] && info "Typecheck: ${DETECTED_TYPECHECK}"
        else
            info "No specific stack detected — Makefile will use placeholders"
        fi
    fi

    # --- Dry run exit ---
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        info "Dry run complete. No files were modified."
        exit 0
    fi

    # --- Step 4: Install .claude/ ---
    step "Installing .claude/ directory"
    copy_claude_directory "$source_dir" "$target_dir" "$force"

    # --- Step 5: Install support files ---
    step "Installing support files"
    copy_scripts "$source_dir" "$target_dir"
    create_working_dirs "$target_dir"
    merge_gitignore "$source_dir" "$target_dir"
    install_makefile "$source_dir" "$target_dir"

    # --- Step 6: Auto-memory ---
    step "Setting up auto-memory"
    setup_auto_memory "$source_dir" "$target_dir"

    # --- Step 7: Validate ---
    step "Validating"
    validate_installation "$target_dir"

    # --- Post-install: LLM analysis question ---
    echo ""
    echo "  ${BOLD}Would you like Claude to analyze your project and fill in CLAUDE.md?${RESET}"
    echo "  ${DIM}(Recommended — saves 15+ minutes of manual editing)${RESET}"
    echo ""
    if ask_yes_no "Print the analysis prompt?" "y"; then
        print_analysis_prompt
    else
        print_manual_checklist "$target_dir"
    fi

    # --- Summary ---
    print_summary "$target_dir"
}

main "$@"
