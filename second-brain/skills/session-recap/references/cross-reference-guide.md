# Cross-Reference Discovery Guide

## Purpose

Discover 10-15 meaningful cross-references BEFORE writing documentation. This phase is critical for knowledge integration and preventing "documentation islands".

---

## Step 1: Search Concepts

Use the bundled script for multi-project search:

```bash
./scripts/search_cross_references.sh "keyword"
```

Or search manually:

```bash
# Search current project
grep -r "pattern_keyword" ${KB_PATH}/projects/{project}/concepts/
ls ${KB_PATH}/projects/{project}/concepts/

# Search all projects for broader context
grep -r "pattern_keyword" ${KB_PATH}/projects/*/concepts/
```

**Look for**:
- Architectural patterns (e.g., `[[Parallel Execution Pattern]]`)
- Design principles (e.g., `[[Fail-safe Filter Principles]]`)
- Technical patterns (e.g., `[[Test Isolation and Data Independence]]`)

**Target**: 3-5 concept cross-references

---

## Step 2: Find Related Components

```bash
# Search current project
grep -r "component_name" ${KB_PATH}/projects/{project}/components/
ls ${KB_PATH}/projects/{project}/components/

# Search all projects for related components
grep -r "component_name" ${KB_PATH}/projects/*/components/
```

**Look for**:
- Filter plugins (e.g., `[[AbstractRuleBasedFilterPlugin]]`)
- Data providers (e.g., `[[TieredCacheDataProvider]]`)
- Configuration classes (e.g., `[[[project-a]ExchangeLiveConfigImpl]]`)

**Target**: 3-5 component cross-references

---

## Step 3: Discover Best Practices

```bash
# List best practices for current project
ls ${KB_PATH}/projects/{project}/best-practices/

# Search current project
grep -r "practice_keyword" ${KB_PATH}/projects/{project}/best-practices/

# Search all projects for related practices
grep -r "practice_keyword" ${KB_PATH}/projects/*/best-practices/
```

**Available best practices by project**:
- **[project-a]** (20 files): [project-a]-test-patterns, legacy-code-migration-methodology, metrics-*, validation-filters-design
- **[project-b]** (5 files): early-traffic-filtering, sqs-dlq-processing, test-channel-usage, stream-refactoring
- **CC** (2 files): simplifying-ai-agent-instructions, trust-model-intelligence
- **Supply Optimization** (1 file)

**Target**: 1-2 best practice cross-references

---

## Step 4: Review Recent Sessions

```bash
# List recent sessions across all projects
ls -lt ${KB_PATH}/daily-log/ | head -10

# Search for related topics across all sessions
grep -r "topic" ${KB_PATH}/daily-log/

# Filter by specific project using tags
grep -r "project: [project-a-service]" ${KB_PATH}/daily-log/
grep -r "project: [project-b-server]" ${KB_PATH}/daily-log/
```

**Connect to**:
- Sessions solving similar problems
- Previous implementations in same area
- Related refactoring sessions

**Target**: 1-2 investigation cross-references

---

## Step 5: Check Maps of Content

```bash
cat ${KB_PATH}/_index/[project-a]\ MOC.md
cat ${KB_PATH}/_index/Migration\ MOC.md
```

**Target**: 1-2 MOC cross-references

---

## Minimum Cross-Reference Requirements

| Document Type | Minimum | Target | Distribution |
|---------------|---------|--------|--------------|
| Daily Session Log | 10 | 15 | Components (3-5), Concepts (3-5), Best Practices (1-2), Sessions (1-2), MOCs (1-2) |
| Concept Document | 10 | 15 | Related Concepts (4-6), Components (2-4), Best Practices (1-2), Sessions (1-2), MOCs (1) |
| Component Document | 10 | 15 | Related Components (3-5), Concepts (3-5), Best Practices (1-2), Sessions (1-2), MOCs (1) |
| Best Practice | 10 | 15 | Related Practices (2-3), Concepts (3-5), Components (2-4), Sessions (1-2), MOCs (1) |

---

## Cross-Reference Quality Guidelines

### Meaningful vs Superficial Links

**✅ Meaningful Cross-References**:
- Direct dependencies (Component A uses Component B)
- Pattern implementations (Implements Pattern X)
- Problem-solution pairs (Investigation → Concept created)
- Methodology applications (Follows Methodology Y)
- Related concepts (Pattern A similar to Pattern B)

**❌ Superficial Cross-References**:
- Tangential mentions with no clear connection
- Links added just to increase count
- Distant relationships with no practical value
- Generic terms that happen to match document names

---

## Link Placement Strategy

### Rules

1. **First Mention Rule**: Link on first mention in each major section
2. **Context Preservation**: Include enough surrounding text to show relevance
3. **Natural Language**: Use aliases when linking improves readability
4. **Avoid Link Spam**: Don't link every mention of common terms

### Example

**✅ Good**: First mention linked, natural context
```markdown
The [[TieredCacheDataProvider]] provides base functionality for caching.
Later mentions of the provider use plain text.
```

**❌ Bad**: Every mention linked
```markdown
The [[TieredCacheDataProvider]] provides caching. The [[TieredCacheDataProvider]]
extends the cache interface. Use [[TieredCacheDataProvider]] to...
```

---

## Cross-Reference Workflow

### Phase 2 (BEFORE Writing Documentation)

1. **Search Concepts** → Identify 3-5 architectural/design patterns
2. **Find Components** → Identify 3-5 related components
3. **Discover Practices** → Identify 1-2 relevant best practices
4. **Review Sessions** → Identify 1-2 previous related sessions
5. **Check MOCs** → Identify 1-2 MOC references

**Total**: 10-15 cross-references before writing begins

### During Documentation (Phase 4)

- Weave discovered cross-references naturally into documentation
- Link on first mention in each section
- Add context around links to show relevance
- Use aliases for readability

### After Documentation (Phase 5)

- Verify minimum cross-references met using `./scripts/count_wikilinks.sh`
- If below minimum, return to discovery phase
- Ensure distribution across categories (not all from one category)

---

## Verification

### Count WikiLinks

```bash
./scripts/count_wikilinks.sh document.md

# Expected output:
# ✅ SUCCESS: 12 cross-references found (minimum 10 met)
```

### Validate References

```bash
./scripts/validate_cross_references.sh document.md

# Checks:
# - All WikiLinks resolve to actual files
# - Suggests fixes for broken links
# - Exit code 0 for success, 1 for errors
```

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Cross-References as Afterthought
**Wrong**: Write documentation first, then search for links to add
**Right**: Discover cross-references first (Phase 2), then write with context

### ❌ Anti-Pattern 2: Superficial Linking
**Wrong**: Link to every document that mentions same keyword
**Right**: Link only to documents with meaningful relationships

### ❌ Anti-Pattern 3: Insufficient Distribution
**Wrong**: All 10 links to components, none to concepts/practices
**Right**: Distribute across categories per requirements table

### ❌ Anti-Pattern 4: Missing Context
**Wrong**: Link without explanation of relevance
**Right**: Explain why linked document is relevant

---

## Cross-Reference Template

Use this structure when adding cross-references:

```markdown
## Related Concepts
- [[Concept Name]] - Brief explanation of relationship
- [[Another Concept]] - Why this is relevant

## Related Components
- [[Component Name]] - How it's used in this context
- [[Another Component]] - Dependency relationship

## Related Best Practices
- [[Practice Name]] - Application in this scenario

## Related Sessions
- [[YYYY-MM-DD Session Title]] - Similar problem solved

## See Also
- [[MOC Name]] - For comprehensive overview
```

---

## Success Criteria

Cross-reference discovery is complete when:

✅ 10-15 total cross-references identified
✅ Distributed across categories (concepts, components, practices, sessions, MOCs)
✅ All references meaningful (not superficial)
✅ References discovered BEFORE writing documentation
✅ Context for each reference understood
