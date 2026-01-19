# Session-Recap Skill

**Version**: 2.6.0
**Last Updated**: 2026-01-18
**Author**: sundayhao
**License**: Internal Use

## Overview

The session-recap skill is a comprehensive knowledge management system for Claude Code sessions. It systematically extracts, documents, and cross-references knowledge from work sessions into a structured knowledge bank, enabling knowledge compounding over time.

## Key Features

### Core Capabilities

- **Automated Session Documentation** - Create rich, cross-referenced daily session logs
- **Knowledge Extraction** - Distill concepts, components, and best practices from investigations
- **Multi-Project Support** - Handles 4 projects: [project-a], [project-b], Claude Code, [project-c]
- **Cross-Reference Discovery** - Find related documentation across 8+ categories
- **Quality Verification** - Ensure 10-15 WikiLinks per document for knowledge integration
- **Project Detection** - Automatically identify project from file paths
- **Session Manager** (v2.4.0) - Preserve full context across context compactions via hooks
- **Transcript Parsing** (v2.4.0) - Extract structured data from transcript.jsonl files

### What Makes This Skill Unique

1. **BRAIN vs ARCHIVE Philosophy** - Distills essential knowledge, not verbose archives
2. **Rich Cross-Referencing** - Minimum 10-15 WikiLinks per document ensures knowledge connectivity
3. **Multi-Project Architecture** - Supports multiple projects with shared and project-specific docs
4. **SOP-Driven Maintenance** - Complete standard operating procedures for updates
5. **Quality-First Approach** - Built-in verification and validation protocols

### Obsidian Integration (v2.5.0)

When obsidian skills are installed, session-recap automatically uses Obsidian Flavored Markdown for all knowledge bank documents:

- **WikiLinks**: `[[Note]]`, `[[Note#Heading]]`, `[[Note|Display]]`
- **Callouts**: `> [!note]`, `> [!warning]`, `> [!tip]`
- **Properties**: YAML frontmatter with Obsidian-compatible fields
- **Tags**: `#tag`, `#nested/tag`
- **Embeds**: `![[Note]]`, `![[image.png]]`
- **Block References**: `[[Note#^block-id]]`

**To enable**: Install the `obsidian:obsidian-markdown` skill in your Claude Code environment.

## Quick Start

### Prerequisites

- Claude Code CLI installed
- Knowledge bank at: `${KB_PATH}/`
- Bash shell (macOS/Linux)
- **Obsidian Skills** (optional, recommended) - For proper Obsidian markdown syntax
  - Install from: `obsidian:obsidian-markdown` skill
  - Enables: WikiLinks, callouts, embeds, block references

### Basic Usage

The skill activates automatically when you say:
- "recap the session"
- "summarize the work"
- "document this in the knowledge bank"

**Manual activation**:
```
User: "Recap the session"
Claude: [Follows SKILL.md workflow to create documentation]
```

## Manual Invocation

This skill can be invoked manually via:

1. **Slash command**: `/second-brain:session-recap`
2. **Skill tool**: `Skill({ skill: "second-brain:session-recap" })`

### Recommended Workflow

**Important**: Run session-recap in a **new session** after your work session ends.

1. **Note the session path** at startup (displayed when Claude Code starts)
2. **Exit your work session** - transcript is saved automatically
3. **Start a new session** and provide the path:
   ```
   Recap the session at /path/to/session.jsonl
   ```

### Visibility Settings

| Setting | Value | Effect |
|---------|-------|--------|
| `user-invocable` | `true` | Appears in slash menu, can be invoked via Skill tool |

### Invocation Options

- **New session with path**: Start fresh session, provide previous session path (recommended)
- **Slash command**: `/second-brain:session-recap /path/to/session.jsonl`
- **Programmatic**: `Skill({ skill: "second-brain:session-recap", args: "/path/to/session.jsonl" })`

## Project Structure

```
session-recap/
├── SKILL.md                          # Main skill documentation
├── README.md                         # This file
├── CHANGELOG.md                      # Version history and changes
├── SOP-SKILL-UPDATES.md              # Standard operating procedures
│
├── scripts/                          # Utility scripts
│   ├── search_cross_references.sh   # Cross-reference discovery (multi-project)
│   ├── count_wikilinks.sh           # WikiLink validation
│   ├── detect_project.sh            # Project detection from paths
│   ├── verify_quality.sh            # Quality verification
│   ├── detect_external_docs.sh      # Investigation document detection
│   ├── analyze_for_distillation.sh  # Distillation candidate analysis
│   ├── validate_cross_references.sh # WikiLink validation and broken link detection
│   ├── verify_session_recap.sh      # Final verification gate
│   ├── validate_obsidian_syntax.sh  # Obsidian syntax validation
│   ├── generate_knowledge_base.sh   # Obsidian Base index generation
│   ├── generate_moc_canvas.sh       # MOC Canvas visualization
│   ├── parse_transcript.sh          # Transcript.jsonl parsing (v2.4.0)
│   ├── session_start.sh             # SessionStart hook handler (v2.4.0)
│   ├── pre_compact.sh               # PreCompact hook handler (v2.4.0)
│   └── session_end.sh               # SessionEnd hook handler (v2.4.0)
│
├── references/                       # Document templates
│   ├── daily-log-template.md        # Daily session log template
│   ├── concept-template.md          # Concept documentation template
│   ├── component-template.md        # Component documentation template
│   ├── best-practice-template.md    # Best practice template
│   ├── distilled-concept-template.md # Distilled concept template
│   └── process-reflection-template.md # Process reflection template
│
├── common/                           # Shared utilities (v2.3.0)
│   ├── get_kb_path.sh               # KB path discovery
│   └── setup_kb_path.sh             # Configuration diagnostic
│
└── backups/                          # Timestamped backups
    └── YYYYMMDD-HHMMSS/             # Backup snapshots
```

## Documentation Types

The skill creates multiple document types:

### 1. Daily Session Logs (LOW Priority)
**Location**: `/knowledge-bank/daily-log/YYYY-MM-DD [Topic].md`
**Purpose**: Archival record of session for historical reference
**Cross-References**: 10-15 WikiLinks

### 2. Distilled Concepts (HIGH Priority)
**Location**: `/knowledge-bank/projects/{project}/concepts/[Concept Name].md`
**Purpose**: Reusable architectural patterns and technical principles
**Cross-References**: 10-15 WikiLinks

### 3. Components
**Location**: `/knowledge-bank/projects/{project}/components/[Component Name].md`
**Purpose**: System component documentation
**Cross-References**: 10-15 WikiLinks

### 4. Best Practices
**Location**: `/knowledge-bank/projects/{project}/best-practices/[Practice Name].md`
**Purpose**: Reusable methodologies and guidelines
**Cross-References**: 10-15 WikiLinks

## Supported Projects

| Project | Identifier | Path Pattern | Project Field |
|---------|------------|--------------|---------------|
| [project-a] Service | `[project-a]` | `/AAD-[project-a-service]/` or `/[project-a-service]/` | `[project-a-service]` |
| [project-b] Server | `[project-b]` | `/[project-b-server]/` | `[project-b-server]` |
| Claude Code | `cc` | `/.claude/` or `/claude-code/` | `Claude Code` |
| [project-c] | `[project-c]` | `/[project-c]/` | `[project-c]` |

## Knowledge Bank Structure

```
knowledge-bank/
├── daily-log/                        # Shared daily logs (all projects)
├── projects/
│   ├── [project-a]/                # [project-a] Service (75 docs)
│   │   ├── concepts/               # Architectural patterns
│   │   ├── components/             # System components
│   │   ├── best-practices/         # [project-a]-specific practices (20 files)
│   │   ├── performance/            # Performance docs
│   │   ├── operation/              # Operational runbooks
│   │   ├── plugins/                # Plugin documentation
│   │   └── rules/                  # Rule documentation
│   ├── [project-b]/                # [project-b] Server (16 docs)
│   ├── cc/                         # Claude Code (7 docs)
│   └── [project-c]/                # [project-c] (2 docs)
├── _index/                         # Maps of Content (MOCs)
├── concepts/                       # Cross-project concepts
├── best-practices/                 # Cross-project practices
└── rules/                          # Cross-project rules
```

## Workflow Phases

### Phase 0: Determine Project Context
Automatically detect which project based on file paths.

### Phase 1: Session Analysis & Data Gathering
Review conversation history, create technical inventory, extract code changes.

### Phase 2: Cross-Reference Discovery (CRITICAL)
Search for related documentation across all categories and projects:
- Concepts (architectural patterns)
- Components (system components)
- Best practices (methodologies)
- Recent sessions (daily logs)
- MOCs (maps of content)

### Phase 2.5: Investigation Distillation (If Applicable)
Distill verbose investigation documents into essential knowledge.

### Phase 3: Knowledge Extraction
Identify reusable patterns, best practices, anti-patterns, and decision rationales.

### Phase 4: Documentation Creation
Create distilled concepts, components, best practices, and daily logs.

### Phase 5: Quality Verification
Verify cross-references (10-15 minimum), documentation quality, and standards compliance.

### Phase 6: Index Maintenance
Regenerate Obsidian Base indices and update MOC Canvas visualizations when new documents are created.

## Scripts Reference

### search_cross_references.sh
Discover related documentation across all projects and categories.

**Usage**:
```bash
# Search all projects
./scripts/search_cross_references.sh "keyword"

# Search specific project
./scripts/search_cross_references.sh "keyword" [project-a]
```

**Categories Searched**:
- Concepts, Components, Best Practices, Daily Logs, Performance
- [project-a]-specific: Operation, Plugins, Rules

### count_wikilinks.sh
Verify WikiLink count and categorization.

**Usage**:
```bash
./scripts/count_wikilinks.sh /path/to/document.md
```

**Validates**:
- Minimum 10 WikiLinks required
- Target 15 WikiLinks for excellence
- Categorizes by type (components, concepts, practices, sessions, MOCs)

### detect_project.sh
Detect project from file paths.

**Usage**:
```bash
./scripts/detect_project.sh /path/to/file.java
# Output: [project-a] | [project-b] | cc | [project-c] | unknown
```

### parse_transcript.sh (v2.4.0)
Extract structured data from transcript.jsonl files.

**Usage**:
```bash
# Get session statistics
./scripts/parse_transcript.sh transcript.jsonl stats

# Extract user messages
./scripts/parse_transcript.sh transcript.jsonl users

# Extract files modified
./scripts/parse_transcript.sh transcript.jsonl files-mod

# Extract errors
./scripts/parse_transcript.sh transcript.jsonl errors

# Run all extractions
./scripts/parse_transcript.sh transcript.jsonl all
```

**Commands**: `stats`, `users`, `files-read`, `files-mod`, `commands`, `errors`, `subagents`, `project`, `all`

### verify_session_recap.sh
Final verification gate for session recap completion.

**Usage**:
```bash
./scripts/verify_session_recap.sh \
  --kb-path "$KB_PATH" \
  --project "$PROJECT" \
  --daily-log "YYYY-MM-DD [Topic].md" \
  --reflection-required
```

**Validates**:
- Daily log exists and meets quality standards
- Required distilled documents created
- Cross-references meet minimum thresholds
- All completion criteria satisfied

### verify_quality.sh
Verify documentation quality against standards.

**Usage**:
```bash
./scripts/verify_quality.sh /path/to/document.md
```

**Checks**:
- Required frontmatter fields present
- WikiLink count meets minimums
- Code references include file paths
- Technical decisions include rationale

### validate_cross_references.sh
Validate WikiLinks and detect broken links.

**Usage**:
```bash
./scripts/validate_cross_references.sh /path/to/document.md
```

**Validates**:
- WikiLink syntax correctness
- Target documents exist
- Heading anchors resolve
- Reports broken links

### detect_external_docs.sh
Scan directories for investigation documents to distill.

**Usage**:
```bash
./scripts/detect_external_docs.sh "$SESSION_FOLDER"
```

**Detects**:
- Investigation documents (>1000 words)
- Files with verbose content suitable for distillation
- Documents outside knowledge bank structure

### analyze_for_distillation.sh
Analyze investigation documents for distillation requirements.

**Usage**:
```bash
./scripts/analyze_for_distillation.sh /path/to/document.md
```

**Output**:
- Estimated 95% reduction target
- Key concepts to extract
- Recommendations for component/practice documentation

### validate_obsidian_syntax.sh
Validate Obsidian-specific markdown syntax.

**Usage**:
```bash
./scripts/validate_obsidian_syntax.sh /path/to/document.md
```

**Validates**:
- Frontmatter required fields (title, tags, type, created)
- Callout syntax (`[!note]`, `[!warning]`, etc.)
- WikiLink format and heading anchors
- Embed syntax correctness

### generate_knowledge_base.sh
Generate Obsidian Base (.base) index files.

**Usage**:
```bash
./scripts/generate_knowledge_base.sh --project "$PROJECT"
```

**Generates**:
- Queryable indices for concepts, components, practices, and sessions
- Filterable views by project, type, and tags
- Summary statistics for knowledge bank health

### generate_moc_canvas.sh
Create MOC Canvas visualization from WikiLinks.

**Usage**:
```bash
./scripts/generate_moc_canvas.sh /path/to/moc.md
```

**Output**:
- JSON Canvas file for visual graph navigation
- Node positioning based on document relationships
- Edge connections from WikiLinks

## Session Manager (v2.4.0)

The Session Manager preserves full context across context compactions using Claude Code hooks.

### How It Works

1. **SessionStart** - Creates session folder when a new session begins
2. **PreCompact** - Saves segment before each context compaction
3. **SessionEnd** - Saves final segment when session ends

### Configuration

Add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/session-recap/scripts/session_start.sh"
      }]
    }],
    "PreCompact": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/session-recap/scripts/pre_compact.sh"
      }]
    }],
    "SessionEnd": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/session-recap/scripts/session_end.sh"
      }]
    }]
  }
}
```

### Session Folder Structure

```
{KB_PATH}/_sessions/YYYY-MM-DD/{session_id}/
├── session-info.json          # Session metadata
├── segment-0/                 # First pre-compaction snapshot
│   ├── transcript.jsonl
│   ├── metadata.json
│   ├── agents/
│   └── plans/
├── segment-1/                 # Second pre-compaction snapshot
└── segment-final/             # Final session snapshot
```

### Key Features

- **Stateless design** - Safe for concurrent sessions
- **Agent deduplication** - Only copies new agents per segment
- **SessionStart matcher** - Only triggers on new sessions (`"startup"`)
- **Overlapping transcripts** - Final segment contains complete conversation

## Quality Standards

### Cross-Reference Requirements
- **Minimum**: 10 WikiLinks per document
- **Target**: 15 WikiLinks
- **Distribution**: Across categories (components, concepts, practices, sessions, MOCs)
- **Quality**: Meaningful connections, not superficial links

### Documentation Standards
- All code references include file path and line numbers
- Technical decisions include rationale
- Before/after comparisons for changes
- Metrics and measurements included
- Problem-solution pairs documented
- Actionable lessons learned

### Metadata Requirements
Every document includes YAML frontmatter:
```yaml
---
title: Document Title
aliases: [Alternative Name]
tags: [category, topic, type]
type: concept|component|investigation|best-practice
created: YYYY-MM-DD
modified: YYYY-MM-DD
project: [project-a-service]|[project-b-server]|Claude Code|[project-c]
---
```

## Maintenance

### Updating the Skill

**IMPORTANT**: Follow the procedures in `SOP-SKILL-UPDATES.md` for all updates.

**Quick Reference**:
1. Create backup: `mkdir backups/$(date +%Y%m%d-%H%M%S)`
2. Make changes following SOP Section 4
3. Run all 7 test protocols (SOP Section 5)
4. Update CHANGELOG.md with changes
5. Verify all tests pass before deployment

### When to Update

**Critical Triggers** (update required):
- Knowledge bank directory structure changes
- New projects added or removed
- Metadata standards change

**Important Triggers** (update recommended):
- New document categories introduced
- Template requirements change

**Optional Triggers** (update as needed):
- Performance optimizations
- Enhanced features

### Testing Protocol

Run these tests after any updates:
```bash
cd "${CLAUDE_PLUGIN_ROOT}/skills/session-recap"

# Test 1: Project detection
./scripts/detect_project.sh /path/to/your/project/File.java

# Test 2: Single project search
./scripts/search_cross_references.sh "filter" [project-a]

# Test 3: Multi-project search
./scripts/search_cross_references.sh "test"

# Test 4: WikiLink counting
KB="${KB_PATH}"
DOC=$(ls -t "$KB/daily-log/"*.md | head -1)
./scripts/count_wikilinks.sh "$DOC"

# Test 5: Obsidian syntax validation
./scripts/validate_obsidian_syntax.sh "$DOC"

# Test 6: Knowledge base generation
./scripts/generate_knowledge_base.sh --project [project-a]

# Test 7: MOC Canvas generation
./scripts/generate_moc_canvas.sh "$KB/_index/[project-a] MOC.md"
```

## Version History

See `CHANGELOG.md` for complete version history.

**Current Version**: 2.6.0 (2026-01-18)
- Integrated 5 previously undocumented scripts into workflow phases
- Added Phase 6 (Index Maintenance) with Obsidian Base and MOC Canvas generation
- Added Obsidian syntax validation in Phase 4.2
- Updated Scripts Reference documentation (12 scripts total)
- Updated completion criteria (7 items)

**Previous Releases**:
- 2.5.0 - Obsidian skills integration for proper Obsidian Flavored Markdown
- 2.4.0 - Session Manager hooks (SessionStart, PreCompact, SessionEnd)
- 2.3.0 - Configurable KB path, best practices optimization
- 2.2.0 - Completion verification, reflection discovery framework
- 2.1.0 - Process reflection capability
- 2.0.0 - Project-based structure migration

## Troubleshooting

### Common Issues

**Issue: "Directory not found" errors**
- Verify knowledge bank exists at correct path
- Check project directories exist
- Run: `ls ${KB_PATH}/projects/`

**Issue: No cross-references found**
- Verify keyword spelling
- Try broader search terms
- Check category directories exist

**Issue: Project detection returns "unknown"**
- Verify file path matches patterns in `detect_project.sh`
- Add new patterns if needed (see SOP Section 4.3.2)

**Issue: Script permission denied**
- Make scripts executable: `chmod +x scripts/*.sh`

For detailed troubleshooting, see `SOP-SKILL-UPDATES.md` Section 9.

## Best Practices

### For Users

1. **Let the skill activate automatically** - Don't force documentation creation
2. **Provide context when requested** - Answer clarifying questions thoroughly
3. **Review cross-references** - Verify suggested links are meaningful
4. **Trust the distillation process** - Focus on "what matters" not "everything"

### For Maintainers

1. **Always backup before changes** - Use SOP Phase 1 backup procedures
2. **Test thoroughly** - Run all 7 test protocols before deployment
3. **Update CHANGELOG.md** - Document all changes with version numbers
4. **Follow the SOP** - Don't skip steps, even for "simple" changes
5. **Verify with actual data** - Test against real knowledge bank, not mock data

## Performance

### Metrics
- **Cross-reference discovery**: ~2-3 seconds per project
- **WikiLink counting**: <1 second per document
- **Project detection**: Instant (<0.1 seconds)
- **Full documentation workflow**: 3-5 minutes (including AI processing)

### Optimization Tips
- Use specific project parameter: `search_cross_references.sh "keyword" [project-a]`
- Limit keyword specificity for faster searches
- Run searches from SSD (not network drive)

## Support

### Documentation
- **SKILL.md**: Complete workflow documentation (589 lines)
- **SOP-SKILL-UPDATES.md**: Maintenance procedures (1,725 lines)
- **CHANGELOG.md**: Version history and changes
- **README.md**: This file (overview and quick start)

### Resources
- Knowledge Bank: `${KB_PATH}/`
- Skill Location: `${CLAUDE_PLUGIN_ROOT}/skills/session-recap/`
- Backups: `${CLAUDE_PLUGIN_ROOT}/skills/session-recap/backups/`

## License

Internal use only. Proprietary to sundayhao.
