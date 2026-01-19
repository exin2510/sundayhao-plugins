# Knowledge Bank Lookup Skill

**Version**: 2.4.0
**Last Updated**: 2026-01-18
**Author**: sundayhao
**License**: Internal Use

## Overview

The knowledge-bank-lookup skill is an intelligent knowledge retrieval system for Claude Code sessions. It delegates lookups to Explore subagents with a reflections-first strategy, automatically learning from past mistakes before consulting documentation. The skill achieves 69-94% context reduction compared to direct lookups.

## Key Features

### Core Capabilities

- **Reflections-First Strategy** - Learns from past mistakes before consulting documentation
- **Portable Configuration** - Uses common utilities for dynamic path resolution
- **Automatic Activation** - Triggers on service mentions, investigation requests, and component references
- **Context Efficiency** - 69-94% reduction in context consumption per lookup
- **WikiLink Following** - DFS traversal of interconnected docs with configurable hop count (1-3 hops)
- **Frontmatter Filtering** - Property-based document discovery (type, status, complexity)
- **Progressive Disclosure** - Lean SKILL.md with detailed reference files for on-demand loading
- **Structured Insights** - JSON responses with reflection_insights, linked_concepts, patterns, gotchas
- **Progressive Refinement** - Follow-up queries reuse subagent cached context
- **MOC-First Navigation** - Optimized document discovery strategy
- **Process Learning** - Extracts workflow lessons from reflection documents

### What Makes This Skill Unique

1. **Subagent Delegation** - Research happens in isolated context, returning only distilled insights
2. **Reflections-First Pattern** - Check `/reflections/` before technical docs to learn from past failures
3. **WikiLink DFS Traversal** - Automatically follows interconnected knowledge with cycle prevention
4. **Frontmatter-Based Filtering** - Search by document properties without reading full content
5. **Configurable Lookup Types** - Quick, Standard, and Deep lookups with appropriate context budgets

## Quick Start

### Prerequisites

- Claude Code CLI installed
- Knowledge bank configured (see [Maintenance](#maintenance) section)
- Subagent execution capability (Task tool)

### Basic Usage

The skill activates automatically when you:
- **Mention services**: [project-a], [project-b], [project-c], Claude Code
- **Request investigations**: "investigate:", "analyze:", "understand X"
- **Ask about patterns**: "how should I", "what's the pattern for"
- **Query past lessons**: "how did we handle X before", "what went wrong with"

**Manual activation**:
```
User: "Look up filter patterns in the knowledge bank"
Claude: [Follows SKILL.md workflow to lookup documentation]
```

## Manual Invocation

This skill can be invoked manually via:

1. **Slash command**: `/second-brain:knowledge-bank-lookup`
2. **Skill tool**: `Skill({ skill: "second-brain:knowledge-bank-lookup" })`

### Visibility Settings

The skill uses these visibility settings in SKILL.md:

| Setting | Value | Effect |
|---------|-------|--------|
| `user-invocable` | `true` | Appears in slash menu, can be invoked via Skill tool |
| `context` | `fork` | Runs in isolated subagent context |
| `agent` | `Explore` | Uses Explore agent optimized for codebase research |

### Invocation Options

- **Automatic**: Skill triggers automatically on detected patterns (recommended)
- **Manual**: Use slash command or Skill tool when auto-detection doesn't apply
- **Programmatic**: Other skills/agents can invoke via Skill tool

## Project Structure

```
knowledge-bank-lookup/
├── SKILL.md                          # Main skill documentation (230 lines)
├── README.md                         # This file
├── VERSION                           # Version tracking
├── CHANGELOG.md                      # Detailed update history
│
├── scripts/                          # Utility scripts
│   ├── wikilink-utils.sh            # WikiLink DFS traversal (5 core functions)
│   ├── search-by-property.sh        # Frontmatter property search
│   ├── find-related.sh              # Relationship graph traversal
│   └── test-wikilinks.sh            # Comprehensive test suite
│
├── references/                       # Progressive disclosure docs
│   ├── templates.md                 # Subagent prompt templates
│   ├── examples.md                  # Integration examples
│   ├── json-schemas.md              # Response format specs
│   ├── knowledge-bank-structure.md  # Directory organization
│   ├── wikilink-traversal.md        # DFS algorithm details
│   ├── frontmatter-retrieval.md     # Property-based filtering
│   ├── optimization-techniques.md   # Context efficiency
│   └── session-documentation.md     # Documentation guidelines
│
└── common/                           # Shared utilities (symlinked)
    ├── get_kb_path.sh               # KB path discovery
    └── setup_kb_path.sh             # Configuration diagnostic
```

## Lookup Types

Choose the appropriate lookup type based on your context needs:

### Quick Lookup

**When to Use**: Service mention, simple component reference

| Aspect | Value |
|--------|-------|
| Context Budget | ~900 lines → 300 returned |
| Model | haiku |
| Reflections | 3-5 recent reflections |
| Documents | MOC + 2-3 docs |
| WikiLink Hops | 1 hop (2-3 additional docs) |

**Example Triggers**: "How does [project-a] handle...", "What is the filter plugin?"

### Standard Lookup

**When to Use**: Investigation mode, implementation planning, best practice queries

| Aspect | Value |
|--------|-------|
| Context Budget | ~1950 lines → 600 returned |
| Model | sonnet |
| Reflections | Topic-specific search |
| Documents | MOC + 5-7 docs |
| WikiLink Hops | 1-2 hops (5-7 additional docs) |

**Example Triggers**: "investigate:", "implement", "best practice for"

### Deep Lookup

**When to Use**: Major refactoring, architectural decisions, cross-service analysis

| Aspect | Value |
|--------|-------|
| Context Budget | ~7300 lines → 1500 returned |
| Model | sonnet |
| Reflections | Comprehensive analysis |
| Documents | All MOCs + 10+ docs |
| WikiLink Hops | Full DFS (up to 20 docs, 3 hops) |

**Example Triggers**: "architectural decision", "cross-service", "major refactoring"

### CC (Claude Code) Lookup

**When to Use**: User mentions Claude Code, CC, hooks, subagents, AI agent patterns

| Aspect | Value |
|--------|-------|
| Context Budget | Varies by depth |
| Model | sonnet |
| Navigation | Direct to `/knowledge-bank/projects/cc/` |
| Note | No CC MOC exists yet |

**Example Triggers**: "Claude Code patterns", "hook configuration", "subagent design"

## Scripts Reference

### wikilink-utils.sh

WikiLink extraction and DFS traversal utilities. Provides 5 core functions for following Obsidian WikiLinks in knowledge bank documentation.

**Core Functions**:

| Function | Description |
|----------|-------------|
| `extract_wikilinks` | Extract all WikiLinks from a markdown file |
| `resolve_wikilink` | Resolve a WikiLink name to file path with priority search |
| `score_wikilink_relevance` | Calculate relevance score based on query context |
| `prioritize_wikilinks` | Sort WikiLinks by relevance score |
| `dfs_traverse` | Depth-First Search traversal of WikiLink graph |

**Usage**:
```bash
source scripts/wikilink-utils.sh

# Extract links from a document
extract_wikilinks "/path/to/doc.md"

# Resolve a WikiLink to file path
resolve_wikilink "Document Name" "$KB_PATH"

# DFS traversal with max depth 2, limit 10 docs
reset_visited
dfs_traverse "/path/to/start.md" 0 2 "$KB_PATH" 10 "filter cache"

# Show resolved paths for all links in a document
show_wikilink_paths "/path/to/doc.md" "$KB_PATH"
```

**Helper Functions**:
- `reset_visited` - Clear visited tracking before new traversal
- `get_visited_count` - Get count of visited documents
- `is_visited` - Check if a document has been visited
- `cleanup_visited` - Clean up temporary tracking file

### search-by-property.sh

Search knowledge bank documents by YAML frontmatter properties. Efficiently filters documents without reading full content.

**Usage**:
```bash
# Basic search
./scripts/search-by-property.sh <property> <value> [project] [options]

# Examples
./scripts/search-by-property.sh type concept              # All concept documents
./scripts/search-by-property.sh complexity advanced [project-a]   # Advanced [project-a] docs
./scripts/search-by-property.sh relevance-to "event"      # Docs about events
./scripts/search-by-property.sh status active --count     # Count active docs
```

**Searchable Properties**:
- `type` - Document type (concept, component, investigation, best-practice)
- `status` - Document status (active, deprecated, draft)
- `complexity` - Complexity level (basic, intermediate, advanced)
- `project` - Project identifier
- `relevance-to` - Relevance topics (array)
- `category` - Category classification
- `package` - Java package reference
- `tags` - Document tags (array)

**Options**:
- `--count` - Only show count of matching documents
- `--paths` - Only show file paths (no titles)
- `--full` - Show full frontmatter for matches
- `--json` - Output as JSON

### find-related.sh

Graph traversal to find related documents by following relationship properties in frontmatter.

**Usage**:
```bash
# Basic traversal
./scripts/find-related.sh <document.md> [options]

# Examples
./scripts/find-related.sh concepts/EventBuilder.md           # Default depth 1
./scripts/find-related.sh components/Filter.md --depth 2     # Traverse 2 levels
./scripts/find-related.sh best-practices/Testing.md --json   # JSON output
./scripts/find-related.sh concepts/Pattern.md --graph        # Graph edges output
```

**Relationship Properties Traversed**:
- `related-concepts` - Connected architectural patterns
- `related-components` - Connected system components
- `related-practices` - Connected best practices
- `implements` - Implementation relationships
- `depends-on` - Dependency relationships
- `used-by` - Usage relationships
- `supersedes` / `superseded-by` - Version chains
- `extracted-to` - Extraction relationships

**Options**:
- `--depth N` - Maximum traversal depth (default: 1)
- `--json` - Output as JSON
- `--graph` - Output as graph edges
- `--all` - Show all relationship types

### test-wikilinks.sh

Comprehensive test suite for WikiLink utilities. Run this after updating wikilink-utils.sh to ensure functionality.

**Usage**:
```bash
./scripts/test-wikilinks.sh
```

**Test Coverage**:
1. **Extract WikiLinks** - Test extraction from [project-a] MOC
2. **Resolve WikiLink paths** - Test link resolution
3. **Score WikiLink relevance** - Test relevance scoring
4. **Prioritize WikiLinks** - Test link prioritization
5. **DFS traversal** - Test depth-limited traversal
6. **Cycle prevention** - Test visited tracking
7. **Show WikiLink paths** - Test utility output

**Output**: Color-coded pass/fail results with summary statistics

## Quality Standards

### JSON Response Fields

Subagents return structured JSON with these fields:

| Field | Description |
|-------|-------------|
| `executive_summary` | Key findings and recommended action |
| `reflection_insights` | Past mistakes, proven approaches, workflow gotchas |
| `relevant_patterns` | Technical patterns with gotchas |
| `related_concepts` | Prerequisites and alternatives |
| `linked_concepts` | Concepts discovered through WikiLink traversal |
| `best_practices` | Reusable methodologies |
| `cross_references` | Follow-up topics for deeper exploration |
| `link_traversal` | WikiLink traversal statistics (docs visited, hops taken) |
| `metadata` | Analysis depth, document counts, limitations |

See [references/json-schemas.md](references/json-schemas.md) for complete schema specifications.

### Automatic Triggers

The skill automatically activates when detecting:

| Category | Trigger Examples |
|----------|------------------|
| **Service Mentions** | [project-a], [project-b-server], [project-b], [project-c], Claude Code, CC |
| **Investigation Requests** | "investigate:", "analyze:", "understand X" |
| **Component References** | filter, cache, LiveConfig, plugin, EnrichmentGraph, DLQ |
| **Best Practice Queries** | "how should I", "what's the pattern for", "best practice" |
| **Implementation Planning** | "implement", "refactor", "migrate" |
| **Documentation Requests** | "recap the session", "document this" |
| **Process Learning** | "how did we handle X before", "past lessons on" |

## Maintenance

### Configuration

Knowledge bank path is dynamically resolved via common utilities.

**Initial Setup**:
```bash
# Configure knowledge bank path
skills/common/setup_kb_path.sh --configure

# Verify configuration
skills/common/setup_kb_path.sh --show

# Use in scripts
source skills/common/get_kb_path.sh && KB_PATH=$(get_kb_path)
```

**Configuration File Location**: `~/.claude/plugins/config/second-brain/config.json`

See `skills/common/README.md` for detailed configuration instructions.

### Knowledge Bank Contents

**Base Path**: Dynamically resolved via common utilities

| Metric | Value |
|--------|-------|
| Total Documents | 172 markdown files |
| Projects | 4 ([project-a], [project-b], CC, [project-c]) |
| MOCs Available | [project-a], [project-b] (CC and [project-c] pending) |

**Key Directories**:
- `projects/{service}/` - Service-specific documentation
- `_index/` - Maps of Content (MOCs) for efficient navigation
- `reflections/` - Process reflections (check first!)
- `manual/` - Documentation and integration manuals
- `rules/` - Cross-project process rules

See [references/knowledge-bank-structure.md](references/knowledge-bank-structure.md) for detailed structure.

## Version History

See `CHANGELOG.md` for complete version history.

**Current Version**: 2.4.0 (2026-01-18)
- Structure refactoring with 49% reduction in SKILL.md
- Terminology standardization (lookup type vs hop count)
- New reference files for WikiLink traversal and frontmatter retrieval

**Previous Releases**:
- 2.3.0 - Frontmatter-based retrieval with property search scripts
- 2.2.0 - WikiLink following with DFS traversal
- 2.1.0 - Common utilities integration, reflections-first strategy
- 2.0.1 - Production packaging with README
- 1.1.0 - Daily log exclusion, separated changelog
- 1.0.0 - Initial release with CC project, SOP, and automation scripts

## Troubleshooting

### Common Issues

**Issue: "Knowledge bank not configured" error**
- Run: `skills/common/setup_kb_path.sh --configure`
- Verify path exists: `ls ${KB_PATH}/`
- Check config file: `cat ~/.claude/plugins/config/second-brain/config.json`

**Issue: WikiLink resolution fails**
- Verify document exists in knowledge bank
- Check filename matches WikiLink exactly (case-sensitive)
- Run: `./scripts/wikilink-utils.sh` to test resolution
- Use `show_wikilink_paths` to debug specific links

**Issue: Context budget exceeded**
- Use Quick Lookup instead of Standard/Deep for simple queries
- Reduce WikiLink hop count in prompt template
- Limit documents per lookup type

**Issue: Property search returns no results**
- Verify property name is correct (case-sensitive)
- Check property exists in document frontmatter
- Try broader search terms
- Use `--full` option to see matching frontmatter

**Issue: DFS traversal visits too many documents**
- Reduce max_depth parameter (1-3)
- Reduce max_docs parameter
- Use more specific query keywords for prioritization

### Debugging Tips

```bash
# Test WikiLink utilities
./scripts/test-wikilinks.sh

# Check property search
./scripts/search-by-property.sh type concept --count

# Test relationship traversal
./scripts/find-related.sh concepts/EventBuilder.md --depth 1

# Verify KB path
source skills/common/get_kb_path.sh && echo $(get_kb_path)
```

## Best Practices

### For Users

| Practice | Rationale |
|----------|-----------|
| Let the skill activate automatically | Triggers are tuned for optimal detection |
| Use specific queries | Better relevance in returned insights |
| Trust the reflections-first pattern | Past failures inform current decisions |
| Check linked_concepts in responses | WikiLink traversal often reveals hidden connections |
| Don't force Deep Lookups for simple queries | Context efficiency matters |

### For Maintainers

| Practice | Rationale |
|----------|-----------|
| Test scripts after changes | Run `test-wikilinks.sh` after any updates |
| Update reference docs alongside SKILL.md | Progressive disclosure requires sync |
| Document new frontmatter properties | Add to search-by-property.sh searchable list |
| Maintain MOC currency | MOC-first navigation depends on accurate MOCs |
| Version changes in CHANGELOG.md | Track evolution for debugging |

## Performance

### Context Efficiency Metrics

| Lookup Type | Input Context | Output Context | Reduction |
|-------------|---------------|----------------|-----------|
| Quick | ~900 lines | ~300 lines | 67% |
| Standard | ~1950 lines | ~600 lines | 69% |
| Deep | ~7300 lines | ~1500 lines | 79% |
| Average | - | - | 69-94% |

### WikiLink Traversal Performance

| Metric | Quick | Standard | Deep |
|--------|-------|----------|------|
| Max Depth | 1 hop | 2 hops | 3 hops |
| Max Documents | 5-8 | 12-14 | 20-30 |
| Typical Duration | <1s | 1-2s | 2-5s |

### Optimization Tips

- Use Quick Lookup for component references (lowest context cost)
- Specify project filter in property searches for faster results
- Prioritize WikiLinks by query relevance (reduces noise)
- Check reflections before technical docs (often has the answer faster)

## Support

### Documentation

| Document | Lines | Purpose |
|----------|-------|---------|
| SKILL.md | 230 | Complete workflow documentation |
| README.md | ~450 | This file (overview and quick start) |
| CHANGELOG.md | - | Version history and changes |
| references/*.md | 8 files | Progressive disclosure documentation |

### Resources

- **Knowledge Bank**: Dynamically resolved via `get_kb_path.sh`
- **Skill Location**: `${CLAUDE_PLUGIN_ROOT}/skills/knowledge-bank-lookup/`
- **Common Utilities**: `${CLAUDE_PLUGIN_ROOT}/skills/common/`
- **Reference Documentation**: `./references/` directory

### Entry Points

1. **New Users**: Start with [Quick Start](#quick-start)
2. **Script Users**: See [Scripts Reference](#scripts-reference)
3. **Troubleshooting**: See [Troubleshooting](#troubleshooting)
4. **Deep Dive**: Read SKILL.md and reference files

## License

Internal use only. Proprietary to sundayhao.
