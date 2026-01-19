# Common Utilities for Second Brain Plugin

This directory contains shared utilities used by the second-brain plugin skills.

## Overview

Common utilities provide reusable functionality for knowledge bank path discovery and validation.

## Available Utilities

### get_kb_path.sh

**Purpose**: Discovers the knowledge bank path from the plugin configuration file.

**Config Location**: `~/.claude/plugins/config/second-brain/config.json`

**Usage**:
```bash
# In your skill script
source /path/to/common/get_kb_path.sh

# Get the KB path
KB_PATH=$(get_kb_path)

# Validate the path exists
if ! validate_kb_path "$KB_PATH"; then
    exit 1
fi

# Use the path
echo "Knowledge bank: $KB_PATH"
```

**Functions**:
- `get_kb_path()` - Returns the configured knowledge bank path
- `validate_kb_path(path)` - Validates that the path exists and is accessible

### setup_kb_path.sh

**Purpose**: Interactive configuration tool for setting up the knowledge bank path.

**Usage**:
```bash
# Configure knowledge bank path interactively
./setup_kb_path.sh --configure

# Show current configuration
./setup_kb_path.sh --show
./setup_kb_path.sh  # Default: same as --show
```

**Config File Format**:
```json
{
  "version": "1.0",
  "knowledge_bank_path": "/path/to/your/knowledge-bank",
  "configured_at": "2026-01-07T12:00:00Z"
}
```

## Configuration

### Via setup_kb_path.sh

Use this directly if you need to change your KB path later:

```bash
./setup_kb_path.sh --configure
```

### Auto-Detection (First Run)

If the KB is not configured when you start Claude Code, the SessionStart hook will prompt you to run the setup.

## Error Handling

Skills that use common utilities fail fast with clear errors:

```bash
# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/get_kb_path.sh"

KB_PATH=$(get_kb_path)
if [ $? -ne 0 ] || [ -z "$KB_PATH" ]; then
    echo "Knowledge bank not configured"
    exit 1
fi
```

## Skills Using Common Utilities

- **session-recap**: Uses `get_kb_path.sh` for knowledge bank location
- **knowledge-bank-lookup**: Uses `get_kb_path.sh` for knowledge bank location
- **Hook scripts**: SessionStart, SessionEnd, PreCompact hooks use `get_kb_path.sh`

## Troubleshooting

### "Knowledge bank not configured" Error

**Cause**: The plugin configuration file doesn't exist or is invalid.

**Solution**:
1. Run the setup script: `setup_kb_path.sh --configure`
2. Enter your knowledge bank path
3. Verify with: `setup_kb_path.sh --show`

### "Knowledge bank directory not found" Error

**Cause**: The configured path doesn't exist.

**Solution**:
1. Check your configuration: `setup_kb_path.sh --show`
2. Verify the path exists: `ls /path/to/knowledge-bank`
3. Re-run configuration if needed: `setup_kb_path.sh --configure`

### Path Detection Not Working

**Debug**: Use the diagnostic tool:
```bash
setup_kb_path.sh --show
```

This will show:
- Config file location
- Configured path
- Whether the path exists
- Project and daily log counts

## Versioning

Common utilities follow semantic versioning:
- **Major**: Breaking changes to function signatures or behavior
- **Minor**: New utilities or non-breaking enhancements
- **Patch**: Bug fixes

Current version: **2.0.0**

## Best Practices

1. **Always validate paths**: Use `validate_kb_path()` after `get_kb_path()`
2. **Fail fast**: Don't provide silent fallbacks in scripts
3. **Clear errors**: Provide actionable error messages with solutions
4. **Document dependencies**: If your script uses common utilities, document it

## License

Internal use only.
