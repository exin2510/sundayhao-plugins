# Frontmatter-Based Retrieval Reference

This document provides comprehensive details on using frontmatter properties for efficient document discovery and filtering.

## Overview

Documents in the knowledge bank use LLM-optimized frontmatter properties designed for efficient lookup. These properties enable filtering documents by category, status, complexity, and relationships without reading full content.

**Benefits:**
- **Efficient Filtering**: Filter by type, status, complexity without reading content
- **Cross-Domain Matching**: Use `relevance-to` for topic-based discovery
- **Graph Navigation**: Follow relationship properties to build context
- **Version Awareness**: Track document evolution through supersedes chains
- **Freshness Detection**: Prioritize recently reviewed documents

## Priority Properties

| Property | Purpose | Example Query |
|----------|---------|---------------|
| `type` | Filter by document category | `type: concept` for architectural patterns |
| `status` | Exclude deprecated/archived | `status: active` for current knowledge |
| `complexity` | Match detail to question scope | `complexity: advanced` for deep topics |
| `relevance-to` | Cross-domain topic matching | `relevance-to: event processing` |
| `related-concepts` | Graph traversal for context | Follow links to build understanding |
| `related-components` | Implementation connections | Find code that implements concepts |
| `supersedes/superseded-by` | Version chains | Follow to find current documentation |
| `last-reviewed` | Freshness indicator | Prioritize recently validated knowledge |

## Lookup Strategy

### Step 1: MOC Navigation (unchanged)

- Start with MOCs (`type: moc`) for service overview
- Identify relevant document categories

### Step 2: Property-Based Filtering

```bash
# Find active concepts about a topic
grep -l "type: concept" *.md | xargs grep -l "status: active" | xargs grep -l "relevance-to:.*event"

# Or use the search-by-property.sh script
./scripts/search-by-property.sh relevance-to "event processing" [project-a]
```

### Step 3: Graph Traversal (enhanced)

Follow relationship properties to build complete context:

| Property | Use Case |
|----------|----------|
| `related-concepts` | Theoretical context and prerequisites |
| `related-components` | Implementation details |
| `related-practices` | Methodologies and workflows |
| `superseded-by` | Newer versions of documentation |

### Step 4: Version Awareness

| Scenario | Action |
|----------|--------|
| Document has `superseded-by` | Follow to current version |
| Document has `status: deprecated` | Note in response, suggest alternatives |
| `last-reviewed` is old (>6 months) | Flag for potential staleness |

## Search Scripts

### search-by-property.sh

Filter documents by frontmatter property values:

```bash
# Find all advanced-complexity concepts
./scripts/search-by-property.sh complexity advanced

# Find docs relevant to "caching" in [project-a]
./scripts/search-by-property.sh relevance-to caching [project-a]

# Options
--count    # Show count only
--paths    # Show file paths only
--full     # Show full frontmatter
--json     # Output as JSON
```

**Supported properties:** type, status, complexity, relevance-to, category, package, tags

### find-related.sh

Graph traversal from a starting document:

```bash
# Find all docs connected to EventBuilder
./scripts/find-related.sh components/EventBuilder.md

# With depth limit
./scripts/find-related.sh components/EventBuilder.md --depth 2

# Output formats
--json     # JSON output
--graph    # DOT graph format
```

**Traverses properties:** related-concepts, related-components, related-practices, implements, depends-on, used-by, supersedes, superseded-by, extracted-to

## Response Enhancement

When returning lookup results, include property-based insights in the JSON response:

```json
{
  "executive_summary": "...",
  "property_insights": {
    "complexity_distribution": {"simple": 2, "intermediate": 5, "advanced": 1},
    "status_check": "All 8 docs are active",
    "freshness": "3 docs reviewed in last 30 days, 2 over 6 months old",
    "deprecated_found": ["OldPattern.md → superseded by NewPattern.md"]
  },
  "relevant_patterns": [...],
  "linked_concepts": [...]
}
```

### property_insights Fields

| Field | Description |
|-------|-------------|
| `complexity_distribution` | Count of docs by complexity level |
| `status_check` | Summary of document statuses |
| `freshness` | Review date distribution |
| `deprecated_found` | List of deprecated docs with successors |

## Best Practices

1. **Combine with MOC-First**: Use property filtering after MOC identifies relevant area
2. **Check Version Chains**: Always follow `superseded-by` to get current info
3. **Note Staleness**: Flag documents not reviewed in 6+ months
4. **Use Complexity Matching**: Match document complexity to query depth
5. **Track Status**: Filter out deprecated/archived unless specifically needed

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| No results from property search | Property value mismatch | Check exact property values in frontmatter |
| Graph traversal stops early | Missing relationship properties | Add relationships to source documents |
| Deprecated doc returned | Status filter not applied | Add `status: active` to search |
| Stale information | Old `last-reviewed` date | Check `superseded-by` for updates |
