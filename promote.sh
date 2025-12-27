#!/bin/bash
# promote.sh - Promote local changes to a new branch and print PR link

set -e



if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <branch-name>"
  exit 1
fi

BRANCH="$1"
REPO_URL="https://github.com/theAgingApprentice/InternalWebServer"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "$BRANCH" ]; then
  echo "Already on branch '$BRANCH'. Staying on this branch and committing outstanding changes."
else
  echo "Creating and switching to branch: $BRANCH"
  git checkout -b "$BRANCH"
fi

echo "Staging all outstanding changes..."
git add .

if git diff --cached --quiet; then
  echo "No outstanding changes to commit."
else
  echo "Committing changes..."
  git commit -m "Promote outstanding changes to $BRANCH"
fi

echo "Pushing branch $BRANCH to remote..."
git push origin "$BRANCH"

PR_LINK="$REPO_URL/compare/main...$BRANCH"
echo "\nBranch '$BRANCH' promoted."
echo "Create a PR by visiting: $PR_LINK"
echo "(Click the link above to open the PR page in your browser.)"
