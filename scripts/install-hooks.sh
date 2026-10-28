#!/usr/bin/env bash
# Point git at the versioned hooks (scripts/hooks). Run once per clone. The path is
# relative, so each worktree runs its own checkout's hook; a worktree-level override
# (config.worktree) would shadow it, so it is removed. Requires gitleaks on PATH (the
# hook fails closed).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath scripts/hooks
# Without extensions.worktreeConfig, --worktree means --local and would undo the line above.
if [ "$(git config --bool extensions.worktreeConfig || true)" = true ]; then
  git config --worktree --unset core.hooksPath || true
fi
echo "core.hooksPath = $(git config core.hooksPath)"
