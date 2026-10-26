#!/bin/bash
# Script to push Sultan Voic Flutter (Android V2 2026) to GitHub

echo "👑 Sultan Voic - GitHub Push Automation"
echo "---------------------------------------"

if [ -z "$1" ]; then
  echo "Usage: ./push_to_github.sh <GITHUB_USERNAME> [GITHUB_TOKEN]"
  echo "Example: ./push_to_github.sh myusername"
  echo "Or with token: ./push_to_github.sh myusername ghp_xxxxxxxxxxxxxxxxxxxx"
  exit 1
fi

USERNAME=$1
TOKEN=$2
REPO="sultan-voice-new"

if [ -n "$TOKEN" ]; then
  REMOTE_URL="https://${USERNAME}:${TOKEN}@github.com/${USERNAME}/${REPO}.git"
else
  REMOTE_URL="https://github.com/${USERNAME}/${REPO}.git"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"
git branch -M main
echo "🚀 Pushing to $REPO on branch main..."
git push -u origin main --force

echo "✅ Push completed successfully!"
