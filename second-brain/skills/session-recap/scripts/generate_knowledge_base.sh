#!/bin/bash
# generate_knowledge_base.sh - Generate Obsidian Base files for queryable indices
#
# Usage: generate_knowledge_base.sh <type> [project] [output-dir]
#
# Types: concepts, components, practices, sessions, all
#
# Generates .base files that provide database-like views of knowledge bank
# documents with filters, sorting, and grouping capabilities.

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

# ============================================================================
# Functions
# ============================================================================

show_usage() {
    echo "Usage: $0 <type> [project] [output-dir]"
    echo ""
    echo "Arguments:"
    echo "  type        Type of base to generate: concepts, components, practices, sessions, all"
    echo "  project     Project filter (optional): auto-discovered from knowledge bank"
    echo "  output-dir  Output directory (default: knowledge bank _index directory)"
    echo ""
    echo "Examples:"
    echo "  $0 concepts                      # All concepts across projects"
    echo "  $0 components my-project         # my-project components only"
    echo "  $0 all backend /tmp/bases        # All backend bases to /tmp/bases"
    exit 1
}

# Generate concepts base file
generate_concepts_base() {
    local project="$1"
    local output_dir="$2"
    local filter_clause=""

    if [[ -n "$project" ]]; then
        filter_clause="
  and:
    - property: type
      eq: concept
    - property: status
      neq: archived
    - property: project
      eq: $project"
    else
        filter_clause="
  and:
    - property: type
      eq: concept
    - property: status
      neq: archived"
    fi

    local filename="${project:-all}-concepts.base"

    cat > "$output_dir/$filename" << EOF
name: "${project:-All} Concepts Index"
description: "Queryable index of concept documents${project:+ for $project}"
filter:$filter_clause
defaultView: table
views:
  - type: table
    name: "All Concepts"
    config:
      properties:
        - title
        - complexity
        - relevance-to
        - status
        - last-reviewed
      sortBy: modified
      sortOrder: desc
  - type: cards
    name: "By Complexity"
    config:
      properties:
        - title
        - relevance-to
        - related-concepts
      groupBy: complexity
  - type: table
    name: "Recently Reviewed"
    config:
      properties:
        - title
        - complexity
        - last-reviewed
      sortBy: last-reviewed
      sortOrder: desc
      filter:
        property: last-reviewed
        isNotEmpty: true
EOF

    echo "Generated: $output_dir/$filename"
}

# Generate components base file
generate_components_base() {
    local project="$1"
    local output_dir="$2"
    local filter_clause=""

    if [[ -n "$project" ]]; then
        filter_clause="
  and:
    - property: type
      eq: component
    - property: status
      neq: archived
    - property: project
      eq: $project"
    else
        filter_clause="
  and:
    - property: type
      eq: component
    - property: status
      neq: archived"
    fi

    local filename="${project:-all}-components.base"

    cat > "$output_dir/$filename" << EOF
name: "${project:-All} Components Index"
description: "Queryable index of component documents${project:+ for $project}"
filter:$filter_clause
defaultView: table
views:
  - type: table
    name: "All Components"
    config:
      properties:
        - title
        - package
        - complexity
        - status
        - last-reviewed
      sortBy: title
      sortOrder: asc
  - type: cards
    name: "By Package"
    config:
      properties:
        - title
        - implements
        - depends-on
      groupBy: package
  - type: table
    name: "Dependency View"
    config:
      properties:
        - title
        - depends-on
        - used-by
        - implements
      sortBy: title
      sortOrder: asc
EOF

    echo "Generated: $output_dir/$filename"
}

# Generate best practices base file
generate_practices_base() {
    local project="$1"
    local output_dir="$2"
    local filter_clause=""

    if [[ -n "$project" ]]; then
        filter_clause="
  and:
    - property: type
      eq: best-practice
    - property: status
      neq: archived
    - property: project
      eq: $project"
    else
        filter_clause="
  and:
    - property: type
      eq: best-practice
    - property: status
      neq: archived"
    fi

    local filename="${project:-all}-practices.base"

    cat > "$output_dir/$filename" << EOF
name: "${project:-All} Best Practices Index"
description: "Queryable index of best practice documents${project:+ for $project}"
filter:$filter_clause
defaultView: table
views:
  - type: table
    name: "All Practices"
    config:
      properties:
        - title
        - category
        - complexity
        - applicability
        - status
      sortBy: title
      sortOrder: asc
  - type: cards
    name: "By Category"
    config:
      properties:
        - title
        - applicability
        - complexity
      groupBy: category
  - type: table
    name: "By Complexity"
    config:
      properties:
        - title
        - category
        - applicability
      sortBy: complexity
      sortOrder: asc
EOF

    echo "Generated: $output_dir/$filename"
}

# Generate sessions base file
generate_sessions_base() {
    local project="$1"
    local output_dir="$2"
    local filter_clause=""

    if [[ -n "$project" ]]; then
        filter_clause="
  and:
    - property: type
      eq: daily-log
    - property: project
      eq: $project"
    else
        filter_clause="
  property: type
  eq: daily-log"
    fi

    local filename="${project:-all}-sessions.base"

    cat > "$output_dir/$filename" << EOF
name: "${project:-All} Session Timeline"
description: "Queryable index of daily log sessions${project:+ for $project}"
filter:$filter_clause
defaultView: table
views:
  - type: table
    name: "Recent Sessions"
    config:
      properties:
        - title
        - topics-covered
        - outcome
        - duration-hours
        - extracted-to
      sortBy: created
      sortOrder: desc
  - type: cards
    name: "By Outcome"
    config:
      properties:
        - title
        - topics-covered
        - duration-hours
      groupBy: outcome
  - type: table
    name: "Knowledge Extraction"
    config:
      properties:
        - title
        - extracted-to
        - topics-covered
      sortBy: created
      sortOrder: desc
      filter:
        property: extracted-to
        isNotEmpty: true
EOF

    echo "Generated: $output_dir/$filename"
}

# ============================================================================
# Main
# ============================================================================

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
    fi

    local base_type="$1"
    local project="${2:-}"
    local output_dir="${3:-$KB_PATH/_index}"

    # Validate type
    case "$base_type" in
        concepts|components|practices|sessions|all)
            ;;
        *)
            echo "Error: Invalid type '$base_type'" >&2
            echo "Valid types: concepts, components, practices, sessions, all" >&2
            exit 1
            ;;
    esac

    # Ensure output directory exists
    mkdir -p "$output_dir"

    echo "Generating Obsidian Base files..."
    echo "  Type: $base_type"
    echo "  Project: ${project:-all}"
    echo "  Output: $output_dir"
    echo ""

    case "$base_type" in
        concepts)
            generate_concepts_base "$project" "$output_dir"
            ;;
        components)
            generate_components_base "$project" "$output_dir"
            ;;
        practices)
            generate_practices_base "$project" "$output_dir"
            ;;
        sessions)
            generate_sessions_base "$project" "$output_dir"
            ;;
        all)
            generate_concepts_base "$project" "$output_dir"
            generate_components_base "$project" "$output_dir"
            generate_practices_base "$project" "$output_dir"
            generate_sessions_base "$project" "$output_dir"
            ;;
    esac

    echo ""
    echo "Base file generation complete."
    echo "Open these files in Obsidian with the Bases plugin enabled."
}

# Run main
main "$@"
