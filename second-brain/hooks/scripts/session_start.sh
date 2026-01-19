#!/bin/bash
# SessionStart hook - creates session folder AND checks first-run configuration
# This script is called when a new Claude Code session starts.
# It creates a session-specific folder to store session data.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Source common utilities for KB path discovery
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../skills/common/get_kb_path.sh"

# Try to get KB path (will fail if not configured)
KB_PATH=$(get_kb_path 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$KB_PATH" ]; then
    # NOT CONFIGURED - Guide user to setup
    # Construct the setup script path relative to plugin root
    SETUP_SCRIPT="$SCRIPT_DIR/../../skills/common/setup_kb_path.sh"

    cat << EOF
{
  "continue": true,
  "systemMessage": "⚠️ Second Brain Plugin: Knowledge bank not configured!\n\nRun this command to configure:\n  $SETUP_SCRIPT --configure\n\nOr use the short form after sourcing:\n  setup_kb_path.sh --configure"
}
EOF
    exit 0
fi

# CONFIGURED - Normal operation
TODAY=$(date +%Y-%m-%d)
SESSION_FOLDER="$KB_PATH/_sessions/$TODAY/$SESSION_ID"

# Create session folder structure
mkdir -p "$SESSION_FOLDER"

# Write session info (in session folder, not shared!)
cat > "$SESSION_FOLDER/session-info.json" << EOF
{
  "session_id": "$SESSION_ID",
  "date": "$TODAY",
  "cwd": "$CWD",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Notify user
cat << EOF
{
  "continue": true,
  "systemMessage": "Session folder created: $SESSION_FOLDER"
}
EOF
