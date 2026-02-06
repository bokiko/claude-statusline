#!/bin/bash
# Claude Code Custom Statusline - Installer
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/scripts/status.sh"

mkdir -p "$HOME/.claude/scripts"
cp "$SCRIPT_DIR/scripts/claude-statusline.sh" "$DEST"
chmod +x "$DEST"

echo "Installed to $DEST"

# Check if settings.json exists and has statusLine configured
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
    if grep -q '"statusLine"' "$SETTINGS" 2>/dev/null; then
        echo "statusLine already configured in $SETTINGS"
    else
        echo ""
        echo "Add to $SETTINGS:"
        echo '  "statusLine": { "type": "command", "command": "$HOME/.claude/scripts/status.sh" }'
    fi
else
    echo ""
    echo "Create $SETTINGS with:"
    echo '{'
    echo '  "statusLine": { "type": "command", "command": "$HOME/.claude/scripts/status.sh" }'
    echo '}'
fi

echo ""
echo "Restart Claude Code to activate."
