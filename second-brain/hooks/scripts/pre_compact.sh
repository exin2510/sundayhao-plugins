#!/bin/bash
# PreCompact hook - saves pre-compaction segment (stateless!)
# This script is called BEFORE context compaction occurs.
# It saves the full transcript and associated files before they get summarized.

# Enable nullglob so globs that don't match return empty list
shopt -s nullglob

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

# Derive session_id from transcript path (no shared config!)
# transcript_path: ~/.claude/projects/.../abc123-def456.jsonl
SESSION_ID=$(basename "$TRANSCRIPT_PATH" .jsonl)

# Source common utilities for KB path discovery
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../skills/common/get_kb_path.sh"

# Get KB path (exit silently if not configured)
KB_PATH=$(get_kb_path 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$KB_PATH" ]; then
    cat << 'EOF'
{
  "continue": true,
  "systemMessage": "Pre-compact: Knowledge bank not configured - segment not saved."
}
EOF
    exit 0
fi

# Find existing session folder (may be in a different date folder if session spans days)
SESSION_FOLDER=$(find "$KB_PATH/_sessions" -type d -name "$SESSION_ID" 2>/dev/null | head -1)

if [ -z "$SESSION_FOLDER" ]; then
    # No existing folder - create with today's date
    TODAY=$(date +%Y-%m-%d)
    SESSION_FOLDER="$KB_PATH/_sessions/$TODAY/$SESSION_ID"
fi

# Create session folder if it doesn't exist (in case SessionStart didn't run)
mkdir -p "$SESSION_FOLDER"

# Count existing segments to get next segment number (exclude segment-final for backwards compat)
SEGMENT_COUNT=$(ls -d "$SESSION_FOLDER"/segment-* 2>/dev/null | grep -v 'segment-final' | wc -l | tr -d ' ')
SEGMENT_FOLDER="$SESSION_FOLDER/segment-$SEGMENT_COUNT"

# Create segment folder
mkdir -p "$SEGMENT_FOLDER/agents"
mkdir -p "$SEGMENT_FOLDER/plans"

# Copy transcript
cp "$TRANSCRIPT_PATH" "$SEGMENT_FOLDER/transcript.jsonl"

# Copy ONLY session-associated, NEW agent transcripts
TRANSCRIPT_DIR=$(dirname "$TRANSCRIPT_PATH")
AGENTS_COPIED=""

# Extract agent IDs mentioned in THIS session's transcript
AGENT_IDS=$(grep -o 'agent-[a-f0-9]\{7\}' "$TRANSCRIPT_PATH" 2>/dev/null | sort -u)

# Get agents already copied in previous segments
EXISTING_AGENTS=""
for prev_segment in "$SESSION_FOLDER"/segment-*/agents/; do
    if [ -d "$prev_segment" ]; then
        for existing in "$prev_segment"*.jsonl; do
            [ -f "$existing" ] && EXISTING_AGENTS="$EXISTING_AGENTS $(basename "$existing" .jsonl)"
        done
    fi
done

# Only copy new, session-associated agents
for agent_id in $AGENT_IDS; do
    if ! echo "$EXISTING_AGENTS" | grep -q "$agent_id"; then
        agent_file="$TRANSCRIPT_DIR/${agent_id}.jsonl"
        if [ -f "$agent_file" ]; then
            cp "$agent_file" "$SEGMENT_FOLDER/agents/"
            AGENTS_COPIED="$AGENTS_COPIED\"agents/${agent_id}.jsonl\","
        fi
    fi
done

# Extract and copy plan files from transcript (also deduplicate)
PLANS_COPIED=""
PLAN_FILES=$(grep -o 'plans/[^"]*\.md' "$TRANSCRIPT_PATH" 2>/dev/null | sort -u)

# Get plans already copied in previous segments
EXISTING_PLANS=""
for prev_segment in "$SESSION_FOLDER"/segment-*/plans/; do
    if [ -d "$prev_segment" ]; then
        for existing in "$prev_segment"*.md; do
            [ -f "$existing" ] && EXISTING_PLANS="$EXISTING_PLANS $(basename "$existing")"
        done
    fi
done

for plan_rel_path in $PLAN_FILES; do
    plan_name=$(basename "$plan_rel_path")
    if ! echo "$EXISTING_PLANS" | grep -q "$plan_name"; then
        plan_full_path="$HOME/.claude/$plan_rel_path"
        if [ -f "$plan_full_path" ]; then
            cp "$plan_full_path" "$SEGMENT_FOLDER/plans/"
            PLANS_COPIED="$PLANS_COPIED\"plans/$plan_name\","
        fi
    fi
done

# Write segment metadata
cat > "$SEGMENT_FOLDER/metadata.json" << EOF
{
  "segment": $SEGMENT_COUNT,
  "type": "pre-compact",
  "ended_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files": {
    "transcript": "transcript.jsonl",
    "agents": [${AGENTS_COPIED%,}],
    "plans": [${PLANS_COPIED%,}]
  }
}
EOF

# Notify user (no config file to update - stateless!)
cat << EOF
{
  "continue": true,
  "systemMessage": "Segment $SEGMENT_COUNT saved to: $SEGMENT_FOLDER"
}
EOF
