#!/bin/bash
# Simple helper to install a skill from this collection into an OpenClaw workspace
# Usage: ./scripts/install_skill.sh uncensored-fallback /path/to/your-openclaw-workspace

set -e

SKILL_NAME=$1
OPENCLAW_WORKSPACE=$2

if [ -z "$SKILL_NAME" ] || [ -z "$OPENCLAW_WORKSPACE" ]; then
    echo "Usage: $0 <skill-name> <path-to-openclaw-workspace>"
    exit 1
fi

SRC_DIR="$(dirname "$0")/../skills/$SKILL_NAME"
DEST_DIR="$OPENCLAW_WORKSPACE/skills/$SKILL_NAME"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' not found in this collection."
    exit 1
fi

mkdir -p "$DEST_DIR"
cp -r "$SRC_DIR"/* "$DEST_DIR"/ 

echo "✅ Skill '$SKILL_NAME' installed to $DEST_DIR"
echo "Don't forget to add it to openclaw.json under skills.entries"