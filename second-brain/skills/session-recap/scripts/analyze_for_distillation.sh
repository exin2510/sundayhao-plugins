#!/bin/bash
# Analyze investigation documents to suggest what should be distilled
# This script provides a framework for categorizing knowledge

if [ $# -eq 0 ]; then
    echo "Usage: $0 <investigation-file.md>"
    echo "Analyzes a single investigation document for distillation"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

echo "=== Investigation Distillation Analysis ==="
echo "File: $(basename "$FILE")"
echo "Size: $(wc -c < "$FILE" | awk '{printf "%.1f KB", $1/1024}')"
echo ""

# Count lines
LINES=$(wc -l < "$FILE")
echo "Lines: $LINES"
echo ""

echo "=== Content Analysis ==="
echo ""

# Look for workflow patterns
WORKFLOWS=$(grep -c -iE "^(step |[0-9]+\.|workflow|process|flow)" "$FILE")
echo "Potential workflows: $WORKFLOWS sections"

# Look for component mentions
COMPONENTS=$(grep -c -iE "(class |interface |component |method |function )" "$FILE")
echo "Component references: $COMPONENTS mentions"

# Look for edge cases
EDGE_CASES=$(grep -c -iE "(edge case|boundary|constraint|limitation|warning|note:|important:)" "$FILE")
echo "Edge case markers: $EDGE_CASES instances"

# Look for decisions
DECISIONS=$(grep -c -iE "(decision|chose|selected|alternative|option [AB]|rationale)" "$FILE")
echo "Decision points: $DECISIONS mentions"

# Look for code blocks
CODE_BLOCKS=$(grep -c "^\`\`\`" "$FILE")
echo "Code blocks: $CODE_BLOCKS"

echo ""
echo "=== Distillation Estimate ==="

# Estimate distilled size (target 95% reduction)
TARGET_LINES=$((LINES * 5 / 100))
[ "$TARGET_LINES" -lt 100 ] && TARGET_LINES=100
[ "$TARGET_LINES" -gt 200 ] && TARGET_LINES=200

echo "Target distilled size: ~$TARGET_LINES lines (100-200 line range)"
echo "Reduction: ~$((100 - TARGET_LINES * 100 / LINES))%"

echo ""
echo "=== Recommended Extractions ==="
echo "✓ Extract workflows if found: $([ "$WORKFLOWS" -gt 2 ] && echo 'YES' || echo 'REVIEW')"
echo "✓ Document components: $([ "$COMPONENTS" -gt 5 ] && echo 'YES' || echo 'REVIEW')"
echo "✓ List edge cases: $([ "$EDGE_CASES" -gt 0 ] && echo 'YES' || echo 'NONE FOUND')"
echo "✓ Capture decisions: $([ "$DECISIONS" -gt 0 ] && echo 'YES' || echo 'NONE FOUND')"
echo ""
echo "💡 Tip: Focus on essential knowledge that answers:"
echo "   'What exists and why?' not 'How was it discovered?'"
