#!/bin/bash
# Count WikiLinks in a document to verify minimum cross-reference requirements

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file>"
    echo "Counts WikiLinks ([[Link Name]]) in the specified markdown file"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

# Count total WikiLinks
count=$(grep -o '\[\[' "$FILE" | wc -l | tr -d ' ')

echo "=== WikiLink Analysis for $(basename "$FILE") ==="
echo ""
echo "Total WikiLinks: $count"
echo ""

# List all unique WikiLinks
echo "Unique WikiLinks:"
grep -o '\[\[[^]]*\]\]' "$FILE" | sort | uniq | sed 's/^/  - /'
echo ""

# Count by category (rough heuristics)
# Note: These are approximate counts based on naming patterns
components=$(grep -o '\[\[[^]]*\]\]' "$FILE" | grep -iE "plugin|provider|builder|factory|impl|extractor|service|handler|processor" | wc -l | tr -d ' ')
concepts=$(grep -o '\[\[[^]]*\]\]' "$FILE" | grep -iE "pattern|principle|isolation|execution|caching|design|architecture" | wc -l | tr -d ' ')
practices=$(grep -o '\[\[[^]]*\]\]' "$FILE" | grep -iE "methodology|testing|migration|refactoring|optimization|metrics" | wc -l | tr -d ' ')
sessions=$(grep -o '\[\[[^]]*\]\]' "$FILE" | grep -E "20[0-9]{2}-[0-9]{2}-[0-9]{2}" | wc -l | tr -d ' ')
mocs=$(grep -o '\[\[[^]]*\]\]' "$FILE" | grep -iE "MOC|map of content" | wc -l | tr -d ' ')

echo "Category Breakdown (approximate):"
echo "  Components: $components"
echo "  Concepts: $concepts"
echo "  Best Practices: $practices"
echo "  Sessions: $sessions"
echo "  MOCs: $mocs"
echo ""

# Verify minimum requirements
if [ "$count" -lt 10 ]; then
    echo "⚠️  WARNING: Only $count cross-references found (minimum 10 required)"
    echo "   Target: 10-15 WikiLinks for proper knowledge integration"
    exit 1
else
    echo "✅ SUCCESS: $count cross-references found (minimum 10 met)"
    if [ "$count" -ge 15 ]; then
        echo "🌟 EXCELLENT: Exceeds target of 15 cross-references"
    fi
fi
