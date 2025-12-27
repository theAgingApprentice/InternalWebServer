#!/bin/bash
# cleanupBranches.sh - Delete all local and remote branches except 'main'

set -e

MAIN_BRANCH="main"
REPO_URL="origin"

# Switch to main branch before cleanup
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
  echo "Switching to '$MAIN_BRANCH' branch for cleanup..."
  git checkout "$MAIN_BRANCH"
fi

# Delete all local branches except main
echo "Deleting all local branches except '$MAIN_BRANCH'..."
for branch in $(git branch | grep -v "${MAIN_BRANCH}" | sed 's/*//'); do
  branch=$(echo $branch | xargs) # trim whitespace
  if [ -n "$branch" ]; then
    git branch -D "$branch"
    echo "Deleted local branch: $branch"
  fi
done

# Fetch remote branches
git fetch --prune

# Delete all remote branches except main
echo "Deleting all remote branches except '$MAIN_BRANCH'..."
for branch in $(git branch -r | grep "${REPO_URL}/" | grep -v "${REPO_URL}/${MAIN_BRANCH}" | sed "s|${REPO_URL}/||"); do
  branch=$(echo $branch | xargs) # trim whitespace
  if [ -n "$branch" ]; then
    git push "$REPO_URL" --delete "$branch"
    echo "Deleted remote branch: $branch"
  fi
  done

echo "Cleanup complete. Only '$MAIN_BRANCH' branch remains locally and remotely."
