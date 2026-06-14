#!/bin/bash
#
# One-command helper to turn this folder into a real GitHub repo and push it.
# Run this on your VPS (where you have internet + GitHub auth).
#
# Usage:
#   ./scripts/setup_github_repo.sh my-username openclaw-skills public
#

set -e

GITHUB_USER=${1:-"yourusername"}
REPO_NAME=${2:-"openclaw-skills"}
VISIBILITY=${3:-"public"}   # public or private

echo "=== Setting up GitHub repo: $GITHUB_USER/$REPO_NAME ($VISIBILITY) ==="

# Initialize git if needed
if [ ! -d .git ]; then
    git init
    echo "Initialized new git repository."
fi

# Add all files
git add .

# Create initial commit if none exists
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    git commit -m "Initial commit: uncensored-fallback v2.3 + OpenClaw skills collection"
    echo "Created initial commit."
fi

# Create remote if it doesn't exist
if ! git remote | grep -q origin; then
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "Added remote origin."
fi

# Create the repo on GitHub using gh CLI (recommended) or give manual instructions
if command -v gh &> /dev/null; then
    echo "Creating repo via GitHub CLI..."
    gh repo create "$GITHUB_USER/$REPO_NAME" --$VISIBILITY --source=. --remote=origin --push || true
else
    echo ""
    echo "gh CLI not found. Please create the repo manually:"
    echo "1. Go to https://github.com/new"
    echo "2. Repository name: $REPO_NAME"
    echo "3. Visibility: $VISIBILITY"
    echo "4. Do NOT initialize with README (we already have files)"
    echo ""
    echo "Then run these commands:"
    echo "  git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "  git branch -M main"
    echo "  git push -u origin main"
fi

echo ""
echo "✅ Done! Repo should now be live at:"
echo "https://github.com/$GITHUB_USER/$REPO_NAME"