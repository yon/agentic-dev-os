#!/bin/sh
# block-dangerous-git.sh — Git guardrails for Claude Code
# Blocks destructive git commands that could cause data loss.
# Exit 2 = blocked, Exit 0 = allowed
#
# Usage: Called as a PreToolUse hook for Bash(git *) commands.
# The full command string is passed as $1.

COMMAND="$1"

# No command provided — nothing to block
if [ -z "$COMMAND" ]; then
    exit 0
fi

# Only check git commands
case "$COMMAND" in
    git\ *) ;;
    *)      exit 0 ;;
esac

# --- push --force (but allow --force-with-lease) ---
# Match "push" followed by "--force" or "-f" that is NOT "--force-with-lease"
case "$COMMAND" in
    *push*--force-with-lease*) ;;  # safe — allow
    *push*--force*|*push*\ -f\ *|*push*\ -f)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git push --force' rewrites remote history and can destroy"
        echo "other people's work."
        echo ""
        echo "Safe alternative: git push --force-with-lease"
        echo "(only force-pushes if no one else has pushed since your last fetch)"
        exit 2
        ;;
esac

# --- reset --hard ---
case "$COMMAND" in
    *reset*--hard*)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git reset --hard' discards all uncommitted changes permanently."
        echo ""
        echo "Safe alternatives:"
        echo "  git stash          — save changes for later"
        echo "  git reset --soft   — undo commits but keep changes staged"
        echo "  git reset --mixed  — undo commits but keep changes in working tree"
        exit 2
        ;;
esac

# --- clean -f / -fd / -fx ---
case "$COMMAND" in
    *clean*-f*|*clean*-d*-f*|*clean*-x*-f*)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git clean -f' permanently deletes untracked files."
        echo ""
        echo "Safe alternatives:"
        echo "  git clean -n   — dry run, show what would be deleted"
        echo "  git stash -u   — stash untracked files instead of deleting"
        exit 2
        ;;
esac

# --- branch -D (force delete) ---
case "$COMMAND" in
    *branch*-D\ *|*branch*-D)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git branch -D' force-deletes a branch even if it has"
        echo "unmerged changes, potentially losing work."
        echo ""
        echo "Safe alternative: git branch -d (only deletes fully merged branches)"
        exit 2
        ;;
esac

# --- checkout . (discard all working tree changes) ---
case "$COMMAND" in
    *checkout\ .)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git checkout .' discards all uncommitted changes in the"
        echo "working tree. This cannot be undone."
        echo ""
        echo "Safe alternatives:"
        echo "  git stash                — save changes for later"
        echo "  git checkout -- <file>   — discard changes in a specific file"
        exit 2
        ;;
esac

# --- restore . (discard all working tree changes) ---
case "$COMMAND" in
    *restore\ .)
        echo "BLOCKED: $COMMAND"
        echo ""
        echo "Reason: 'git restore .' discards all uncommitted changes in the"
        echo "working tree. This cannot be undone."
        echo ""
        echo "Safe alternatives:"
        echo "  git stash               — save changes for later"
        echo "  git restore <file>      — discard changes in a specific file"
        exit 2
        ;;
esac

# Command is allowed
exit 0
