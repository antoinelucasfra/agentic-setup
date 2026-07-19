#!/bin/bash

# Session Auto-Commit + PR Hook
# Commits and pushes uncommitted changes when a session ends, then ensures the
# current feature branch has a PR created (if it carries real work) and assigned
# to the authenticated GitHub user.

set -euo pipefail

# Check if SKIP_AUTO_COMMIT is set
if [[ "${SKIP_AUTO_COMMIT:-}" == "true" ]]; then
  echo "⏭️  Auto-commit skipped (SKIP_AUTO_COMMIT=true)"
  exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "⚠️  Not in a git repository"
  exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Commit and push any uncommitted changes (no-op if the tree is clean)
if [[ -n "$(git status --porcelain)" ]]; then
  echo "📦 Auto-committing changes from session..."

  # Stage all changes
  git add -A

  # Create timestamped commit
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  git commit -m "auto-commit: $TIMESTAMP" --no-verify 2>/dev/null || {
    echo "⚠️  Commit failed"
    exit 0
  }

  # Attempt to push
  if git push 2>/dev/null; then
    echo "✅ Changes committed and pushed successfully"
  else
    echo "⚠️  Push failed - changes committed locally"
  fi
fi

# Ensure the branch's PR is created (if it has real work) and assigned to self
maybe_pr "$BRANCH"

exit 0

# Create (if missing) and assign a PR for the given branch to the authenticated
# GitHub user. ponytail: only creates a PR when the branch has real (non-WIP)
# work and is already pushed; assignment is idempotent. Guarded by SKIP_AUTO_PR.
# Uses the REST API for assignment — `gh pr edit --add-assignee` is broken
# (GraphQL Projects-classic deprecation error).
maybe_pr() {
  local branch="$1"
  [[ "$branch" == "main" ]] && return 0
  [[ "${SKIP_AUTO_PR:-}" == "true" ]] && return 0

  command -v gh >/dev/null 2>&1 || { echo "⚠️  gh not found - skipping PR"; return 0; }
  gh auth status >/dev/null 2>&1 || { echo "⚠️  gh not authenticated - skipping PR"; return 0; }

  local assignee slug
  assignee=$(gh api user --jq .login 2>/dev/null) || return 0
  slug=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) || return 0

  # Resolve existing PR number for this branch
  local pr_num
  pr_num=$(gh pr view "$branch" --json number --jq .number 2>/dev/null) || pr_num=""

  if [[ -n "$pr_num" ]]; then
    gh api -X POST "repos/$slug/issues/$pr_num/assignees" -f "assignees[]=$assignee" >/dev/null 2>&1 \
      && echo "✅ PR #$pr_num assigned to @$assignee" \
      || echo "⚠️  Could not assign PR #$pr_num"
    return 0
  fi

  # No PR yet: only create one if the branch is pushed and carries real work
  git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" >/dev/null 2>&1 || {
    echo "⚠️  Branch not pushed - skipping PR creation"
    return 0
  }
  git log "@{upstream}"..HEAD --pretty=%s 2>/dev/null | grep -qv '^auto-commit:' || {
    echo "⚠️  Only WIP commits - skipping PR creation"
    return 0
  }

  local title
  title=$(git log "@{upstream}"..HEAD --pretty=%s | grep -v '^auto-commit:' | head -1)
  [[ -z "$title" ]] && title="$branch"

  # Create without --assignee (assign via REST after, to dodge the broken path)
  gh pr create --title "$title" --fill >/dev/null 2>&1 || {
    echo "⚠️  PR creation failed"
    return 0
  }
  pr_num=$(gh pr view "$branch" --json number --jq .number 2>/dev/null) || pr_num=""
  if [[ -n "$pr_num" ]]; then
    gh api -X POST "repos/$slug/issues/$pr_num/assignees" -f "assignees[]=$assignee" >/dev/null 2>&1 \
      && echo "✅ PR #$pr_num created and assigned to @$assignee" \
      || echo "✅ PR #$pr_num created but assignment failed"
  fi
}
