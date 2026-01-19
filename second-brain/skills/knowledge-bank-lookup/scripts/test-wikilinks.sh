#!/bin/bash
# test-wikilinks.sh - Test WikiLink utilities
#
# Validates WikiLink extraction, resolution, and DFS traversal
# Run this after updating wikilink-utils.sh to ensure functionality
#
# Uses dynamic MOC discovery - no hardcoded project names

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="$SCRIPT_DIR/../../common"

# Source the WikiLink utilities
source "$SCRIPT_DIR/wikilink-utils.sh"

# Source KB path utilities
if [ -f "$COMMON_DIR/get_kb_path.sh" ]; then
    source "$COMMON_DIR/get_kb_path.sh"
    KB_PATH=$(get_kb_path)
    if ! validate_kb_path "$KB_PATH"; then
        echo -e "${RED}ERROR: Knowledge bank path not configured properly${NC}"
        exit 1
    fi
else
    echo -e "${RED}ERROR: Common utilities not found at $COMMON_DIR/${NC}"
    exit 1
fi

echo "Testing WikiLink Utilities"
echo "Knowledge Bank Path: $KB_PATH"
echo "=========================================="
echo ""

# Test helper functions
test_pass() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

test_fail() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo -e "  ${YELLOW}Expected: $2${NC}"
    echo -e "  ${YELLOW}Got: $3${NC}"
}

test_skip() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    if [ -n "$2" ]; then
        echo -e "  ${YELLOW}Reason: $2${NC}"
    fi
}

# Dynamically find a MOC file to use for testing
TEST_MOC=$(find_first_moc "$KB_PATH" 2>/dev/null)
if [ -n "$TEST_MOC" ]; then
    TEST_MOC_NAME=$(basename "$TEST_MOC")
    echo "Using MOC for tests: $TEST_MOC_NAME"
    echo ""
else
    echo -e "${YELLOW}NOTE: No MOC files found in knowledge bank${NC}"
    echo "Some tests will be skipped. Create a MOC file to enable full testing."
    echo ""
fi

# Test 1: Extract WikiLinks from MOC
echo "Test 1: Extract WikiLinks from MOC"
echo "--------------------------------------"
if [ -n "$TEST_MOC" ] && [ -f "$TEST_MOC" ]; then
    links=$(extract_wikilinks "$TEST_MOC")
    link_count=$(echo "$links" | grep -c '^' || echo 0)

    if [ "$link_count" -gt 0 ]; then
        test_pass "Extracted $link_count WikiLinks from $(basename "$TEST_MOC")"
        echo "  Sample links:"
        echo "$links" | head -5 | sed 's/^/    - /'
    else
        test_fail "Extract WikiLinks from MOC" "At least 1 link" "0 links"
    fi
else
    test_skip "Extract WikiLinks from MOC" "No MOC file found in knowledge bank"
fi
echo ""

# Test 2: Resolve WikiLink to file path
echo "Test 2: Resolve WikiLink paths"
echo "--------------------------------------"
if [ -n "$TEST_MOC" ] && [ -f "$TEST_MOC" ]; then
    first_link=$(extract_wikilinks "$TEST_MOC" | head -1)

    if [ -n "$first_link" ]; then
        resolved=$(resolve_wikilink "$first_link" "$KB_PATH")

        if [ -n "$resolved" ] && [ -f "$resolved" ]; then
            test_pass "Resolved '$first_link' to file"
            echo "  Path: $resolved"
        else
            test_fail "Resolve WikiLink" "Valid file path" "Not found or invalid"
        fi
    else
        test_skip "Resolve WikiLink" "No WikiLinks found to resolve"
    fi
else
    test_skip "Resolve WikiLink" "No MOC file found in knowledge bank"
fi
echo ""

# Test 3: Score WikiLink relevance
echo "Test 3: Score WikiLink relevance"
echo "--------------------------------------"
score1=$(score_wikilink_relevance "Parallel Execution Pattern" "parallel execution")
score2=$(score_wikilink_relevance "Random Document" "parallel execution")

if [ "$score1" -gt "$score2" ]; then
    test_pass "Relevance scoring (exact match scored higher)"
    echo "  'Parallel Execution Pattern' score: $score1"
    echo "  'Random Document' score: $score2"
else
    test_fail "Relevance scoring" "score1 > score2" "score1=$score1, score2=$score2"
fi
echo ""

# Test 4: Prioritize WikiLinks
echo "Test 4: Prioritize WikiLinks"
echo "--------------------------------------"
test_links="Parallel Execution Pattern\nRandom Document\nFilter Plugin\nCache Pattern"
prioritized=$(prioritize_wikilinks "$test_links" "parallel execution")
first_result=$(echo "$prioritized" | head -1)

if [[ "$first_result" == *"Parallel"* ]]; then
    test_pass "WikiLink prioritization (relevant links first)"
    echo "  Top result: $first_result"
else
    test_fail "WikiLink prioritization" "Parallel... as first result" "$first_result"
fi
echo ""

# Test 5: DFS traversal (limited depth)
echo "Test 5: DFS traversal"
echo "--------------------------------------"
if [ -n "$TEST_MOC" ] && [ -f "$TEST_MOC" ]; then
    reset_visited
    results=$(dfs_traverse "$TEST_MOC" 0 1 "$KB_PATH" 10)
    result_count=$(echo "$results" | grep -c '^' || echo 0)
    visited_count=$(get_visited_count)

    if [ "$result_count" -gt 1 ]; then
        test_pass "DFS traversal ($visited_count docs visited, max depth 1)"
        echo "  Documents visited:"
        echo "$results" | head -5 | sed 's/^/    /'
        if [ "$result_count" -gt 5 ]; then
            echo "    ... and $((result_count - 5)) more"
        fi
    else
        test_fail "DFS traversal" "At least 2 documents" "$result_count documents"
    fi
else
    test_skip "DFS traversal" "No MOC file found in knowledge bank"
fi
echo ""

# Test 6: Cycle prevention
echo "Test 6: Cycle prevention"
echo "--------------------------------------"
if [ -n "$TEST_MOC" ] && [ -f "$TEST_MOC" ]; then
    reset_visited
    # Run DFS twice on same document
    results1=$(dfs_traverse "$TEST_MOC" 0 2 "$KB_PATH" 20)
    count1=$(echo "$results1" | grep -c '^' || echo 0)

    # If we try to traverse again, visited count shouldn't increase
    results2=$(dfs_traverse "$TEST_MOC" 0 2 "$KB_PATH" 20)
    count2=$(get_visited_count)

    if [ "$count2" -eq "$count1" ]; then
        test_pass "Cycle prevention (visited count unchanged on re-traversal)"
        echo "  Initial visits: $count1"
        echo "  After re-traverse: $count2"
    else
        test_fail "Cycle prevention" "Same count" "count1=$count1, count2=$count2"
    fi
else
    test_skip "Cycle prevention" "No MOC file found in knowledge bank"
fi
echo ""

# Test 7: Show WikiLink paths (utility test)
echo "Test 7: Show WikiLink paths utility"
echo "--------------------------------------"
if [ -n "$TEST_MOC" ] && [ -f "$TEST_MOC" ]; then
    path_results=$(show_wikilink_paths "$TEST_MOC" "$KB_PATH" | head -3)
    path_count=$(echo "$path_results" | grep -c ' -> ' || echo 0)

    if [ "$path_count" -gt 0 ]; then
        test_pass "Show WikiLink paths utility"
        echo "  Sample results:"
        echo "$path_results" | sed 's/^/    /'
    else
        test_fail "Show WikiLink paths" "At least 1 result" "0 results"
    fi
else
    test_skip "Show WikiLink paths utility" "No MOC file found in knowledge bank"
fi
echo ""

# Test Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Tests run:    $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"

if [ "$TESTS_SKIPPED" -gt 0 ]; then
    echo -e "${YELLOW}Tests skipped: $TESTS_SKIPPED${NC}"
fi

if [ "$TESTS_FAILED" -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
else
    echo -e "Tests failed: 0"
    echo ""
    if [ "$TESTS_SKIPPED" -gt 0 ]; then
        echo -e "${YELLOW}Some tests were skipped due to missing MOC files.${NC}"
        echo -e "${YELLOW}Create a MOC file in your knowledge bank to enable full testing.${NC}"
    else
        echo -e "${GREEN}All tests passed!${NC}"
    fi
    exit 0
fi
