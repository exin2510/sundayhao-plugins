# Knowledge Bank Structure

**Base Path**: Dynamically resolved via common utilities

The path is configured in your `~/.claude/CLAUDE.md` or via environment variables.
See Configuration section in SKILL.md for details on path resolution.

## Directory Organization

```
projects/
├── [project-a]/                        # ~81 documents (53 modified in last 30 days - very active!)
│   ├── concepts/               # Architectural patterns (Parallel Execution, Test Isolation) (33 files)
│   ├── components/             # Component docs (TieredCacheDataProvider, RuleBasedFilterPlugin) (17 files)
│   ├── best-practices/         # [project-a]-specific best practices (22 files)
│   ├── operation/              # Operational runbooks and developer guides (1 file)
│   ├── performance/            # Optimization patterns and trade-off decisions (2 files)
│   ├── plugins/                # Plugin-specific documentation (1 file)
│   └── rules/                  # [project-a]-specific implementation rules (5 files)
│       ├── guides/             # Developer guides
│       └── scripts/            # LLM executable scripts
│
├── [project-b]/                        # ~18 documents (18 modified in last 30 days - very active!)
│   ├── concepts/               # Architectural patterns
│   ├── components/             # System components
│   └── best-practices/         # [project-b]-specific best practices
│
├── cc/                         # Claude Code patterns (~7 documents, 7 modified in last 30 days - very active!)
│   ├── concepts/               # Meta-patterns for AI agents (3 files)
│   ├── components/             # Infrastructure components (2 files)
│   └── best-practices/         # AI agent best practices (2 files)
│
└── [project-c]/        # ~2 documents (2 modified in last 30 days - very active!)
    ├── concepts/               # Domain concepts
    ├── components/             # System components
    └── best-practices/         # Domain-specific practices

# NOTE: Daily logs have been moved to /daily-log/ for tracking purposes only and are NOT included in lookups

_index/                         # Maps of Content (MOCs)
├── [project-a] MOC.md                  # Map of Content for [project-a]
├── [project-b] MOC.md                  # Map of Content for [project-b]
└── Migration MOC.md            # Map of Content for migrations

reflections/                    # Process reflections (dynamically discovered categories)
├── {category}/                 # Create any category folders (e.g., architecture-patterns/, debugging/)
│   └── [topic].md              # Reflection documents with 5-8 cross-references
└── ...                         # System discovers all subdirectories automatically
                                # Contains: what worked, what didn't, what failed, improvements, what would make it seamless
                                # PURPOSE: Learn from past mistakes, apply proven approaches
                                # ⚠️ CHECK REFLECTIONS FIRST before diving into technical docs

manual/                         # Documentation manuals
├── DOCUMENTATION-MANUAL.md     # Documentation generation guide
├── INTEGRATION-MANUAL.md       # Integration patterns and guides
├── MANUAL_UPDATES_SUMMARY.md   # Summary of manual updates
└── README.md                   # Manual overview

rules/                          # Cross-project process rules (3 files)
├── existing-doc-migration.md
├── knowledge-bank-lookup.md
└── session-documentation-and-knowledge-extraction.md
```

## Document Counts

**Total Documentation**: 172 markdown files (as of 2025-11-08)
- **Projects Only**: [project-a] (81), [project-b] (18), CC (7), Supply-Opt (2) = 108 files
- **Additional**: MOCs, manuals, rules, reflections = 64 files
- **Note**: Daily logs (~40 files) moved to `/daily-log/` and excluded from lookups
- **[project-c]**: No MOC yet (small project with 2 docs, similar to CC which also has no MOC)

## Navigation Strategy: MOC-First

Always start with the Map of Content (MOC) for the relevant service to understand structure and identify relevant documents before reading specific files. This approach achieves 94% context reduction compared to reading all documents.

### Service MOC Locations

- **[project-a]**: `/knowledge-bank/_index/[project-a] MOC.md`
- **[project-b]**: `/knowledge-bank/_index/[project-b] MOC.md`
- **Migration**: `/knowledge-bank/_index/Migration MOC.md`
- **CC**: No MOC yet (navigate directly to project files)
- **[project-c]**: No MOC yet (navigate directly to project files)

## Document Types

### Concepts
Architectural patterns, design principles, and system-level ideas. Examples:
- Parallel Execution
- Test Isolation
- Hook-Subagent Patterns

### Components
Specific implementations and system parts. Examples:
- TieredCacheDataProvider
- RuleBasedFilterPlugin
- build-interceptor

### Best Practices
Reusable methodologies and guidelines. Examples:
- [project-a] Testing Patterns
- Trust the Model (CC)
- Context Efficiency Techniques

### Reflections
Process insights and workflow lessons learned. Format: `YYYY-MM-DD [Topic].md`
Contains 5 reflection questions capturing what worked, what didn't, what failed, improvements needed, and what would make it seamless.
