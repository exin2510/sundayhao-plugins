# WikiLink Traversal Reference

This document provides comprehensive details on WikiLink following using Depth-First Search (DFS) for knowledge discovery.

## Overview

All documents in the knowledge bank are interconnected using Obsidian WikiLinks (`[[Document Name]]`). The skill follows these links using DFS to ensure comprehensive coverage of related knowledge.

**Benefits:**
- **Complete Information**: No missed concepts through natural document connections
- **Automatic Discovery**: Finds prerequisites, related patterns, and implementations
- **Context-Aware**: Prioritizes links by relevance to query keywords
- **Efficient Navigation**: Follows knowledge bank's natural structure

## How It Works

### Depth-First Search (DFS)

The traversal uses DFS to explore linked documents systematically:

1. **Start** at primary documents identified from MOC/query
2. **Extract** all WikiLinks from current document
3. **Prioritize** links by relevance to query keywords
4. **Follow** highest-priority links first (depth-first)
5. **Stop** when reaching max hop count or document limit

### Link Prioritization

WikiLinks are scored for relevance before traversal:

| Score | Criteria |
|-------|----------|
| +10 | Exact keyword match in link name |
| +5 | Pattern/Principle documents |
| +4 | Best practice documents |
| +3 | Component documents (Plugin, Provider, Builder, Extractor) |

Links are followed in priority order to maximize relevance within context budget.

### Cycle Prevention

- **Visited Tracking**: Documents tracked using temp file (`/tmp/wikilink_visited.*`)
- **Single Visit**: Each document visited only once per traversal
- **Depth Limits**: DFS stops at max hop count
- **Graceful Handling**: Broken links logged but don't fail traversal

## Traversal Strategies

| Lookup Type | Max Hops | Max Additional Docs | Strategy |
|-------------|----------|---------------------|----------|
| **Quick**   | 1 hop    | 2-3 docs            | Selective: Follow only key links from primary docs |
| **Standard**| 2 hops   | 5-7 docs            | Prioritized: Follow top-scored links by relevance |
| **Deep**    | 3 hops   | Up to 20 docs       | Comprehensive: Full DFS with link graph analysis |

## Context Budget Allocation

| Lookup Type | Primary Docs | WikiLink Budget | Total Lines |
|-------------|--------------|-----------------|-------------|
| Quick       | 600 lines    | 300 lines       | 900 lines   |
| Standard    | 1200 lines   | 750 lines       | 1950 lines  |
| Deep        | 4000 lines   | 3300 lines      | 7300 lines  |

## WikiLink Utilities

Located at `scripts/wikilink-utils.sh`:

| Function | Purpose |
|----------|---------|
| `extract_wikilinks()` | Extract all `[[WikiLinks]]` from markdown |
| `resolve_wikilink()` | Resolve link name to file path (concepts → components → best-practices priority) |
| `prioritize_wikilinks()` | Score links by relevance to query keywords |
| `dfs_traverse()` | Perform DFS traversal with hop limits and cycle prevention |
| `reset_visited()` | Clear visited tracking for new traversal |

**Test**: Run `./scripts/test-wikilinks.sh` to validate functionality.

## JSON Response Fields

### linked_concepts

Array of concepts discovered through WikiLinks:

```json
{
  "concept_name": "Vert.x Event Loop Safety",
  "link_source": "Parallel Execution Pattern.md",
  "depth": 1,
  "relevance": "Explains thread safety guarantees",
  "key_insight": "Single event loop prevents race conditions",
  "doc_path": "/path/to/linked/doc.md"
}
```

**Field descriptions:**
- `concept_name`: Name of the linked concept
- `link_source`: Document where WikiLink was found
- `depth`: Hop count from primary documents (1-3)
- `relevance`: Why this concept matters to the query
- `key_insight`: Main takeaway from linked document
- `doc_path`: Absolute path for navigation

### link_traversal

Traversal statistics:

```json
{
  "total_links_found": 23,
  "links_followed": 8,
  "max_depth_reached": 2,
  "traversal_strategy": "prioritized-2hop",
  "traversal_path": [
    {"doc": "Pattern.md", "depth": 0},
    {"doc": "Concept.md", "depth": 1}
  ]
}
```

## Integration with Lookup Templates

WikiLink following is integrated into subagent prompts. Example workflow step:

```bash
# In subagent prompt:
4. Follow WikiLinks (DFS - 1 hop):
   - source ~/.claude/skills/knowledge-bank-lookup/scripts/wikilink-utils.sh
   - reset_visited
   - extract_wikilinks "primary_doc.md"
   - Follow 1-hop links (max 2-3 docs)
```

See [templates.md](templates.md) for complete workflow integration.

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| No links followed | All links below relevance threshold | Lower keyword specificity or use Deep lookup |
| Missing concepts | Document not in expected path | Check `resolve_wikilink()` search order |
| Cycle warning | Same doc linked multiple times | Normal - cycle prevention working |
| Broken link logged | WikiLink target doesn't exist | Update source document or create target |
