#!/bin/bash
# setup_kb_path.sh - Knowledge Bank Configuration Tool
#
# Usage:
#   ./setup_kb_path.sh --configure              # Interactive configuration
#   ./setup_kb_path.sh --configure /path/to/kb  # Non-interactive (provide path)
#   ./setup_kb_path.sh --show                   # Show current configuration
#   ./setup_kb_path.sh                          # Same as --show
#
# Config file: ~/.claude/plugins/config/second-brain/config.json

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Config file location
CONFIG_DIR="${HOME}/.claude/plugins/config/second-brain"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# Show current configuration
show_config() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Second Brain - Knowledge Bank Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}✗ Not configured${NC}"
        echo ""
        echo "Run: $0 --configure"
        echo ""
        return 1
    fi

    # Read config
    local kb_path=""
    if command -v jq &> /dev/null; then
        kb_path=$(jq -r '.knowledge_bank_path // empty' "$CONFIG_FILE" 2>/dev/null)
    else
        kb_path=$(grep -o '"knowledge_bank_path"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/')
    fi

    if [ -z "$kb_path" ]; then
        echo -e "${RED}✗ Invalid config file${NC}"
        echo ""
        echo "Run: $0 --configure"
        return 1
    fi

    echo -e "${BLUE}Config file:${NC} $CONFIG_FILE"
    echo -e "${BLUE}Knowledge bank:${NC} $kb_path"
    echo ""

    if [ -d "$kb_path" ]; then
        echo -e "${GREEN}✓ Path exists${NC}"

        # Show some stats
        if [ -d "$kb_path/projects" ]; then
            local project_count=$(find "$kb_path/projects" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
            echo "  Projects: $project_count"
        fi

        if [ -d "$kb_path/daily-log" ]; then
            local log_count=$(find "$kb_path/daily-log" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
            echo "  Daily logs: $log_count"
        fi

        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}${BOLD}  ✅ Configuration valid${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 0
    else
        echo -e "${RED}✗ Path does not exist${NC}"
        echo ""
        echo "Run: $0 --configure"
        return 1
    fi
}

# Configuration (interactive or non-interactive)
# Usage: configure [optional_path]
configure() {
    local provided_path="${1:-}"
    local user_path=""

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Second Brain - Knowledge Bank Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show current config if exists
    if [ -f "$CONFIG_FILE" ]; then
        local current_path=""
        if command -v jq &> /dev/null; then
            current_path=$(jq -r '.knowledge_bank_path // empty' "$CONFIG_FILE" 2>/dev/null)
        else
            current_path=$(grep -o '"knowledge_bank_path"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/')
        fi
        if [ -n "$current_path" ]; then
            echo -e "${YELLOW}Current configuration:${NC} $current_path"
            echo ""
        fi
    fi

    # Use provided path or prompt interactively
    if [ -n "$provided_path" ]; then
        user_path="$provided_path"
        echo "Using provided path: $user_path"
    else
        # Interactive mode - prompt for path
        read -p "Enter knowledge bank path: " user_path
    fi

    # Expand tilde
    user_path="${user_path/#\~/$HOME}"

    # Validate input
    if [ -z "$user_path" ]; then
        echo -e "${RED}ERROR: Path cannot be empty${NC}"
        exit 1
    fi

    # Check if path exists
    if [ ! -d "$user_path" ]; then
        echo ""
        echo -e "${YELLOW}Directory does not exist: $user_path${NC}"
        if [ -n "$provided_path" ]; then
            # Non-interactive mode - create automatically
            mkdir -p "$user_path"
            echo -e "${GREEN}✓ Created: $user_path${NC}"
        else
            # Interactive mode - ask
            read -p "Create it? [y/N]: " create_dir
            if [[ "$create_dir" =~ ^[Yy]$ ]]; then
                mkdir -p "$user_path"
                echo -e "${GREEN}✓ Created: $user_path${NC}"
            else
                echo -e "${RED}Aborted${NC}"
                exit 1
            fi
        fi
    fi

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    # Write config file
    cat > "$CONFIG_FILE" << EOF
{
  "version": "1.0",
  "knowledge_bank_path": "$user_path",
  "configured_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}  ✅ Configuration saved!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  Path: $user_path"
    echo "  Config: $CONFIG_FILE"
    echo ""
    echo -e "${YELLOW}Note: Restart Claude Code to create session folder.${NC}"
    echo ""
}

# Main
case "${1:-}" in
    --configure|-c)
        # Pass optional second argument (path) to configure
        configure "${2:-}"
        ;;
    --show|-s|"")
        show_config
        ;;
    --help|-h)
        echo "Usage: $0 [OPTION] [PATH]"
        echo ""
        echo "Options:"
        echo "  --configure, -c [PATH]   Configure knowledge bank path"
        echo "                           If PATH provided: non-interactive"
        echo "                           If no PATH: interactive prompt"
        echo "  --show, -s               Show current configuration (default)"
        echo "  --help, -h               Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 --configure                           # Interactive"
        echo "  $0 --configure /path/to/knowledge-bank   # Non-interactive"
        echo "  $0 --show                                # Show config"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Run: $0 --help"
        exit 1
        ;;
esac
