#!/bin/bash
# Verify documentation quality against knowledge bank standards

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file>"
    echo "Verifies documentation meets quality standards"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

echo "=== Quality Verification for $(basename "$FILE") ==="
echo ""

# Check frontmatter
echo "🔍 Checking frontmatter..."
if grep -q "^---$" "$FILE"; then
    if grep -q "^title:" "$FILE" && grep -q "^tags:" "$FILE" && grep -q "^type:" "$FILE"; then
        echo "  ✅ Frontmatter present with required fields"
    else
        echo "  ⚠️  Frontmatter incomplete (missing title, tags, or type)"
    fi
else
    echo "  ❌ No frontmatter found"
fi
echo ""

# Check cross-references
echo "🔗 Checking cross-references..."
link_count=$(grep -o '\[\[' "$FILE" | wc -l | tr -d ' ')
if [ "$link_count" -ge 10 ]; then
    echo "  ✅ Cross-references: $link_count (meets minimum of 10)"
else
    echo "  ⚠️  Cross-references: $link_count (below minimum of 10)"
fi
echo ""

# Check for file paths with line numbers
echo "📁 Checking code references..."
if grep -qE '`/[^`]+`.*\(lines [0-9]+-[0-9]+\)' "$FILE"; then
    echo "  ✅ Found file paths with line numbers"
else
    echo "  ⚠️  No file paths with line numbers found"
fi
echo ""

# Check for before/after code examples
echo "💾 Checking code examples..."
code_blocks=$(grep -c "^```" "$FILE")
if [ "$code_blocks" -ge 2 ]; then
    echo "  ✅ Found $code_blocks code blocks"
else
    echo "  ⚠️  Limited code examples ($code_blocks blocks)"
fi
echo ""

# Check for decision rationales
echo "🎯 Checking decision documentation..."
if grep -qiE "rationale|why|because|decision|chose" "$FILE"; then
    echo "  ✅ Found decision rationale language"
else
    echo "  ⚠️  No clear decision rationales found"
fi
echo ""

# Check for metrics/measurements
echo "📊 Checking metrics..."
if grep -qE "[0-9]+%" "$FILE" || grep -qE "[0-9]+ lines" "$FILE" || grep -qE "[0-9]+ms" "$FILE"; then
    echo "  ✅ Found quantitative metrics"
else
    echo "  ⚠️  No quantitative metrics found"
fi
echo ""

# Summary
echo "=== Summary ==="
errors=0
warnings=0

if ! grep -q "^---$" "$FILE"; then
    errors=$((errors + 1))
fi

if [ "$link_count" -lt 10 ]; then
    warnings=$((warnings + 1))
fi

if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
    echo "✅ Document meets all quality standards"
    exit 0
elif [ "$errors" -eq 0 ]; then
    echo "⚠️  Document has $warnings warnings but passes"
    exit 0
else
    echo "❌ Document has $errors errors and $warnings warnings"
    exit 1
fi
