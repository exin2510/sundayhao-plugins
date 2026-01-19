#!/bin/bash
# Detect external investigation documents from conversation history or file paths
# This script helps identify investigation documents that should be distilled

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory-path>"
    echo "   or: $0 --scan-conversation"
    exit 1
fi

if [ "$1" = "--scan-conversation" ]; then
    echo "=== External Document Detection ==="
    echo ""
    echo "Scan conversation history for patterns:"
    echo "  - Paths: /llm-docs/, /docs/, /documentation/"
    echo "  - Phrases: 'created documents in', 'investigation folder'"
    echo "  - Multiple .md files in same directory"
    echo ""
    echo "This is a placeholder - actual implementation would scan"
    echo "conversation context for these patterns"
    exit 0
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' not found"
    exit 1
fi

echo "=== Scanning for Investigation Documents ==="
echo "Directory: $DIR"
echo ""

# Find all markdown files
MD_FILES=$(find "$DIR" -type f -name "*.md" | wc -l | tr -d ' ')

if [ "$MD_FILES" -eq 0 ]; then
    echo "No markdown files found"
    exit 0
fi

echo "Found $MD_FILES markdown files:"
echo ""

# List files with sizes
find "$DIR" -type f -name "*.md" -exec ls -lh {} \; | awk '{print $9, "(" $5 ")"}'

echo ""

# Calculate total size
TOTAL_SIZE=$(find "$DIR" -type f -name "*.md" -exec cat {} \; | wc -c | awk '{printf "%.1f KB", $1/1024}')
echo "Total size: $TOTAL_SIZE"

echo ""
echo "Confidence: $([ "$MD_FILES" -ge 4 ] && echo 'HIGH' || [ "$MD_FILES" -ge 2 ] && echo 'MEDIUM' || echo 'LOW')"
echo "Recommendation: $([ "$MD_FILES" -ge 2 ] && echo 'Consider distillation' || echo 'Manual review needed')"
