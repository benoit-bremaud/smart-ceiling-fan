#!/usr/bin/env bash
# Point git at the versioned hooks (scripts/hooks). Run once per clone. The path is
# relative, so each worktree runs its own checkout's hook; a worktree-level override
# (config.worktree) would shadow it, so it is removed. Requires gitleaks on PATH (the
# hook fails closed).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath scripts/hooks
git config --worktree --unset core.hooksPath 2>/dev/null || true
echo "core.hooksPath = $(git config core.hooksPath)"
