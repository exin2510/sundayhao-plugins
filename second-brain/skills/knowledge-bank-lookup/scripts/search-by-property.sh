#!/bin/bash
# search-by-property.sh - Search knowledge bank documents by frontmatter properties
#
# Usage: search-by-property.sh <property> <value> [project] [options]
#
# Efficiently filters knowledge bank documents based on YAML frontmatter
# properties. Designed for LLM-friendly output with context.
#
# Examples:
#   search-by-property.sh type concept
#   search-by-property.sh complexity advanced my-project
#   search-by-property.sh relevance-to "event processing"
#   search-by-property.sh status active --count

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# Configuration
# ============================================================================

# Source common utilities for KB path discovery
COMMON_DIR="$SCRIPT_DIR/../../common"
if [ -f "$COMMON_DIR/get_kb_path.sh" ]; then
    source "$COMMON_DIR/get_kb_path.sh"
fi

# Load knowledge bank path (use CLAUDE_KB_PATH if set, otherwise discover)
if [[ -n "${CLAUDE_KB_PATH:-}" ]]; then
    KB_PATH="$CLAUDE_KB_PATH"
elif type get_kb_path &>/dev/null; then
    KB_PATH=$(get_kb_path) || exit 1
else
    echo "ERROR: Knowledge bank not configured and get_kb_path not available." >&2
    echo "Run: setup_kb_path.sh --configure" >&2
    exit 1
fi

# Common properties for lookup
SEARCHABLE_PROPERTIES=(
    "type" "status" "complexity" "project"
    "relevance-to" "category" "package"
    "tags"
)

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Usage: $0 <property> <value> [project] [options]"
    echo ""
    echo "Arguments:"
    echo "  property    Frontmatter property to search (e.g., type, complexity, relevance-to)"
    echo "  value       Value to match (can be partial for array properties)"
    echo "  project     Optional project filter (auto-discovered from knowledge bank)"
    echo ""
    echo "Options:"
    echo "  --count     Only show count of matching documents"
    echo "  --paths     Only show file paths (no titles)"
    echo "  --full      Show full frontmatter for matches"
    echo "  --json      Output as JSON"
    echo ""
    echo "Searchable Properties:"
    for prop in "${SEARCHABLE_PROPERTIES[@]}"; do
        echo "  - $prop"
    done
    echo ""
    echo "Examples:"
    echo "  $0 type concept                       # All concept documents"
    echo "  $0 complexity advanced                # Advanced complexity docs"
    echo "  $0 relevance-to \"event\" my-project  # my-project docs about events"
    echo "  $0 status active --count              # Count of active docs"
    exit 1
}

# Extract frontmatter from a file
extract_frontmatter() {
    local file="$1"
    awk '/^---$/{if(p){exit}else{p=1;next}} p{print}' "$file"
}

# Get title from frontmatter
get_title() {
    local frontmatter="$1"
    echo "$frontmatter" | grep "^title:" | sed 's/^title:[[:space:]]*//' | tr -d '"'
}

# Check if property matches value
property_matches() {
    local frontmatter="$1"
    local property="$2"
    local value="$3"

    # Handle array properties (relevance-to, tags, etc.)
    if echo "$frontmatter" | grep -q "^$property:$"; then
        # Multi-line array format
        local array_content=$(echo "$frontmatter" | awk -v prop="$property:" '
            $0 ~ prop {found=1; next}
            found && /^[[:space:]]+-/ {print; next}
            found && /^[a-zA-Z]/ {exit}
        ')
        if echo "$array_content" | grep -qi "$value"; then
            return 0
        fi
    else
        # Single-line property
        local prop_value=$(echo "$frontmatter" | grep "^$property:" | sed "s/^$property:[[:space:]]*//" | tr -d '"')
        if [[ "$prop_value" == *"$value"* ]]; then
            return 0
        fi
    fi

    return 1
}

# Search documents matching criteria
search_documents() {
    local property="$1"
    local value="$2"
    local project_filter="${3:-}"
    local count_only="${4:-false}"
    local paths_only="${5:-false}"
    local full_output="${6:-false}"
    local json_output="${7:-false}"

    local search_path="$KB_PATH"
    if [[ -n "$project_filter" ]]; then
        search_path="$KB_PATH/projects/$project_filter"
        if [[ ! -d "$search_path" ]]; then
            echo "Error: Project directory not found: $search_path" >&2
            exit 1
        fi
    fi

    local match_count=0
    local results=()

    # Find all markdown files
    while IFS= read -r -d '' file; do
        local frontmatter=$(extract_frontmatter "$file")

        # Skip files without frontmatter
        [[ -z "$frontmatter" ]] && continue

        # Check if property matches
        if property_matches "$frontmatter" "$property" "$value"; then
            ((match_count++))

            if [[ "$count_only" == "true" ]]; then
                continue
            fi

            local title=$(get_title "$frontmatter")
            local rel_path="${file#$KB_PATH/}"

            if [[ "$json_output" == "true" ]]; then
                results+=("{\"path\":\"$rel_path\",\"title\":\"$title\"}")
            elif [[ "$full_output" == "true" ]]; then
                echo "=========================================="
                echo "File: $rel_path"
                echo "=========================================="
                echo "$frontmatter"
                echo ""
            elif [[ "$paths_only" == "true" ]]; then
                echo "$rel_path"
            else
                echo "- [$title]($rel_path)"
            fi
        fi
    done < <(find "$search_path" -name "*.md" -type f -print0 2>/dev/null)

    # Output results
    if [[ "$count_only" == "true" ]]; then
        echo "$match_count"
    elif [[ "$json_output" == "true" ]]; then
        echo "{\"property\":\"$property\",\"value\":\"$value\",\"count\":$match_count,\"results\":[$(IFS=,; echo "${results[*]}")]}"
    else
        echo ""
        echo "Found $match_count documents matching $property=\"$value\"${project_filter:+ in $project_filter}"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    if [[ $# -lt 2 ]]; then
        show_usage
    fi

    local property="$1"
    local value="$2"
    shift 2

    local project=""
    local count_only="false"
    local paths_only="false"
    local full_output="false"
    local json_output="false"

    # Parse remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --count)
                count_only="true"
                ;;
            --paths)
                paths_only="true"
                ;;
            --full)
                full_output="true"
                ;;
            --json)
                json_output="true"
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_usage
                ;;
            *)
                # Assume it's a project filter
                project="$1"
                ;;
        esac
        shift
    done

    # Run search
    search_documents "$property" "$value" "$project" "$count_only" "$paths_only" "$full_output" "$json_output"
}

# Run main
main "$@"
