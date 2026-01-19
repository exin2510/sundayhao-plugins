#!/bin/bash
# find-related.sh - Graph traversal to find related documents in knowledge bank
#
# Usage: find-related.sh <document.md> [options]
#
# Traverses related-concepts, related-components, related-practices properties
# to discover connected knowledge. Useful for building context around a topic.
#
# Examples:
#   find-related.sh /path/to/EventBuilder.md
#   find-related.sh concepts/MyPattern.md --depth 2
#   find-related.sh components/Filter.md --json

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

# Relationship properties to traverse
RELATIONSHIP_PROPERTIES=(
    "related-concepts"
    "related-components"
    "related-practices"
    "implements"
    "depends-on"
    "used-by"
    "supersedes"
    "superseded-by"
    "extracted-to"
)

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================================
# State
# ============================================================================

declare -A VISITED
GRAPH_EDGES=()

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Usage: $0 <document.md> [options]"
    echo ""
    echo "Arguments:"
    echo "  document.md   Path to the document (relative or absolute)"
    echo ""
    echo "Options:"
    echo "  --depth N     Maximum traversal depth (default: 1)"
    echo "  --json        Output as JSON"
    echo "  --graph       Output as graph edges"
    echo "  --all         Show all relationship types"
    echo ""
    echo "Relationship Types Traversed:"
    for prop in "${RELATIONSHIP_PROPERTIES[@]}"; do
        echo "  - $prop"
    done
    echo ""
    echo "Examples:"
    echo "  $0 concepts/EventBuilder.md"
    echo "  $0 /full/path/to/doc.md --depth 2"
    echo "  $0 components/Filter.md --json"
    exit 1
}

# Extract frontmatter from a file
extract_frontmatter() {
    local file="$1"
    awk '/^---$/{if(p){exit}else{p=1;next}} p{print}' "$file" 2>/dev/null
}

# Get title from frontmatter
get_title() {
    local frontmatter="$1"
    echo "$frontmatter" | grep "^title:" | sed 's/^title:[[:space:]]*//' | tr -d '"'
}

# Get document type from frontmatter
get_type() {
    local frontmatter="$1"
    echo "$frontmatter" | grep "^type:" | sed 's/^type:[[:space:]]*//' | tr -d '"'
}

# Extract WikiLinks from a property value
extract_links_from_property() {
    local frontmatter="$1"
    local property="$2"

    # Check if property exists
    if ! echo "$frontmatter" | grep -q "^$property:"; then
        return
    fi

    # Handle array format (indented with -)
    echo "$frontmatter" | awk -v prop="$property:" '
        $0 ~ prop {found=1; next}
        found && /^[[:space:]]+-/ {
            gsub(/^[[:space:]]+-[[:space:]]*/, "")
            gsub(/\[\[/, "")
            gsub(/\]\].*/, "")
            gsub(/"/, "")
            if ($0 != "") print
            next
        }
        found && /^[a-zA-Z]/ {exit}
    '

    # Handle inline format: property: [[Link1]], [[Link2]]
    local inline=$(echo "$frontmatter" | grep "^$property:" | grep -oE '\[\[[^\]]+\]\]' | sed 's/\[\[//g; s/\]\]//g' | sed 's/|.*//g' | sed 's/#.*//g')
    if [[ -n "$inline" ]]; then
        echo "$inline"
    fi
}

# Resolve a link name to a file path
resolve_link() {
    local link="$1"
    local base_path="$2"

    # Remove anchor and display text
    link="${link%%|*}"
    link="${link%%#*}"
    link=$(echo "$link" | xargs)  # Trim whitespace

    [[ -z "$link" ]] && return

    # Try direct path first
    if [[ -f "$KB_PATH/$link.md" ]]; then
        echo "$KB_PATH/$link.md"
        return
    fi

    # Search in projects directory
    local found=$(find "$KB_PATH/projects" -name "$link.md" -type f 2>/dev/null | head -1)
    if [[ -n "$found" ]]; then
        echo "$found"
        return
    fi

    # Try with common prefixes
    for subdir in "concepts" "components" "best-practices"; do
        found=$(find "$KB_PATH" -path "*/$subdir/$link.md" -type f 2>/dev/null | head -1)
        if [[ -n "$found" ]]; then
            echo "$found"
            return
        fi
    done
}

# Traverse relationships from a document
traverse_document() {
    local file="$1"
    local current_depth="$2"
    local max_depth="$3"
    local show_all="$4"

    # Check if already visited
    local abs_path=$(realpath "$file" 2>/dev/null || echo "$file")
    if [[ -n "${VISITED[$abs_path]:-}" ]]; then
        return
    fi
    VISITED["$abs_path"]=1

    # Get file info
    local frontmatter=$(extract_frontmatter "$file")
    if [[ -z "$frontmatter" ]]; then
        return
    fi

    local title=$(get_title "$frontmatter")
    local doc_type=$(get_type "$frontmatter")
    local rel_path="${file#$KB_PATH/}"

    # Output current document
    local indent=""
    for ((i=0; i<current_depth; i++)); do
        indent+="  "
    done

    if [[ $current_depth -eq 0 ]]; then
        echo -e "${CYAN}Root: $title${NC} ($doc_type)"
        echo "Path: $rel_path"
        echo ""
    else
        echo -e "${indent}${GREEN}→${NC} $title ($doc_type)"
        echo -e "${indent}  Path: $rel_path"
    fi

    # Stop if at max depth
    if [[ $current_depth -ge $max_depth ]]; then
        return
    fi

    # Traverse each relationship type
    for prop in "${RELATIONSHIP_PROPERTIES[@]}"; do
        local links=$(extract_links_from_property "$frontmatter" "$prop")

        [[ -z "$links" ]] && continue

        echo -e "${indent}  ${YELLOW}$prop:${NC}"

        while IFS= read -r link; do
            [[ -z "$link" ]] && continue

            # Store graph edge
            GRAPH_EDGES+=("\"$title\" --[$prop]--> \"$link\"")

            local resolved=$(resolve_link "$link" "$file")
            if [[ -n "$resolved" && -f "$resolved" ]]; then
                traverse_document "$resolved" $((current_depth + 1)) "$max_depth" "$show_all"
            else
                echo -e "${indent}    - $link (unresolved)"
            fi
        done <<< "$links"
    done
}

# Output as JSON
output_json() {
    local file="$1"
    local max_depth="$2"

    local frontmatter=$(extract_frontmatter "$file")
    local title=$(get_title "$frontmatter")
    local doc_type=$(get_type "$frontmatter")
    local rel_path="${file#$KB_PATH/}"

    local relationships="{"

    for prop in "${RELATIONSHIP_PROPERTIES[@]}"; do
        local links=$(extract_links_from_property "$frontmatter" "$prop")
        if [[ -n "$links" ]]; then
            local link_array=$(echo "$links" | while read -r link; do
                echo "\"$link\""
            done | paste -sd,)
            relationships+="\"$prop\":[$link_array],"
        fi
    done

    relationships="${relationships%,}}"

    cat << EOF
{
  "document": {
    "title": "$title",
    "type": "$doc_type",
    "path": "$rel_path"
  },
  "relationships": $relationships,
  "traversal_depth": $max_depth,
  "visited_count": ${#VISITED[@]}
}
EOF
}

# Output as graph
output_graph() {
    echo "Graph Edges:"
    echo "============"
    for edge in "${GRAPH_EDGES[@]}"; do
        echo "$edge"
    done
    echo ""
    echo "Total edges: ${#GRAPH_EDGES[@]}"
    echo "Unique nodes: ${#VISITED[@]}"
}

# ============================================================================
# Main
# ============================================================================

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
    fi

    local document="$1"
    shift

    local max_depth=1
    local json_output="false"
    local graph_output="false"
    local show_all="false"

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --depth)
                shift
                max_depth="${1:-1}"
                ;;
            --json)
                json_output="true"
                ;;
            --graph)
                graph_output="true"
                ;;
            --all)
                show_all="true"
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_usage
                ;;
        esac
        shift
    done

    # Resolve document path
    local file="$document"
    if [[ ! -f "$file" ]]; then
        # Try relative to knowledge bank
        file="$KB_PATH/$document"
    fi

    if [[ ! -f "$file" ]]; then
        echo "Error: Document not found: $document" >&2
        echo "Tried: $document, $KB_PATH/$document" >&2
        exit 1
    fi

    echo "=========================================="
    echo "Knowledge Graph Traversal"
    echo "=========================================="
    echo "Max depth: $max_depth"
    echo ""

    # Perform traversal
    traverse_document "$file" 0 "$max_depth" "$show_all"

    # Output format
    if [[ "$json_output" == "true" ]]; then
        echo ""
        output_json "$file" "$max_depth"
    elif [[ "$graph_output" == "true" ]]; then
        echo ""
        output_graph
    fi

    echo ""
    echo "=========================================="
    echo "Summary: Visited ${#VISITED[@]} documents"
    echo "=========================================="
}

# Run main
main "$@"
