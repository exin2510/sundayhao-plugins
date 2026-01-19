# External Document Distillation Guide

## Purpose

Extract essential knowledge from external investigation documents, distilling 100+ KB of details into 5-10 KB of actionable knowledge.

**Philosophy**: Knowledge Bank = BRAIN (remember conclusions), not ARCHIVE (preserve investigation journey).

---

## Step 1: Detect External Investigation Documents

Scan conversation history for external document patterns:

```bash
# Look for patterns indicating external investigation docs
- Paths like `/llm-docs/`, `/docs/`, `/documentation/`
- Phrases: "created documents in", "investigation folder", "see documents at"
- Multiple .md files mentioned in same directory
```

**Confidence scoring**:
- High: 4+ .md files in same external directory
- Medium: 2-3 .md files or explicit "created investigation docs"
- Ask user if confidence ≥ medium

---

## Step 2: Analyze & Categorize Knowledge

### Critical Knowledge (Preserve)

- **Workflows**: Step-by-step logic flows (6-10 steps max)
- **Components**: What they do, role, key methods (3-5 lines each)
- **Data Flow**: Input → Transform → Output chains
- **Edge Cases**: Critical boundaries, constraints, what breaks
- **Decisions**: Non-obvious choices with rationale
- **Patterns**: Reusable approaches discovered
- **Anti-patterns**: What to avoid and why

### Investigation Details (Leave Behind)

- Discovery process ("first looked at X, then Y")
- All alternatives explored (keep final choice + rationale only)
- Detailed calculations (keep conclusions: "<1% overhead")
- Initial misunderstandings and corrections
- Step-by-step debugging traces
- Verbose analysis and intermediate iterations

---

## Step 3: Distillation Test

**For each piece of information, apply the 6-month test**:
> "If modifying/debugging this in 6 months, MUST this be known?"

**Examples**:
- ✅ **Critical**: "Slot-level categories are AdX-only per ADR-001"
- ❌ **Detail**: "Investigation started in enrichment layer first"
- ✅ **Critical**: "`generateBlocklistFor()` methods in [project-b-request-generator]"
- ❌ **Detail**: "Initial thought was single method, user corrected"
- ✅ **Critical**: "Performance impact negligible (<1%)"
- ❌ **Detail**: "Exact 187μs calculation: 30μs parsing + 1.5μs lookup + ..."

---

## Step 4: Present Distillation Proposal

Present analysis to user:

```
🔍 Detected 6 external investigation documents (139 KB)
   Location: /path/to/investigation/

📊 Distillation Analysis:
   ✓ 1 core workflow (6-step sequence)
   ✓ 2 key components (roles + methods)
   ✓ 3 critical edge cases
   ✓ 1 design pattern (reusable)
   ✓ 1 anti-pattern warning

   Result: 139 KB → ~5 KB (96% reduction)
   Time: ~20-25 minutes

📝 Proceed with distillation?
   [Show Analysis] [Customize] [Skip]
```

---

## Step 5: Execute Distillation

### Read External Documents
Scan investigation files to extract essential knowledge.

### Extract Essential Knowledge

- **Workflows**: 6-10 step sequences (not 30-paragraph explanations)
- **Components**: Role + key method signatures (not full code)
- **Data Flow**: Transformation chains (not performance breakdowns)
- **Edge Cases**: Bullet list of boundaries (not discovery stories)
- **Decisions**: Choice + rationale (not all alternatives)

### Create Concept Document

Use `references/distilled-concept-template.md`:
- **Title**: Core concept name (e.g., "bcat Bidder Blocklist Processing")
- **Size**: 3-5 KB target (100-150 lines)
- **Cross-references**: 10-15 WikiLinks to existing KB
- **Frontmatter**: `distilled-from` field with original path

### Update Component Documents

If new methods/behaviors discovered, update relevant component documentation.

### Archive Reference in Daily Log

```markdown
## Investigation Documents

Knowledge distilled from investigation at:
`/path/to/original/investigation/` (139 KB)

Distilled into:
- [[Concept Name]] - Core workflow/pattern (3 KB)
- [[Component Name]] - Updated with key methods (+1 KB)

Original investigation archived in codebase for implementation reference.
```

---

## Step 6: Distillation Quality Check

**Verify essential knowledge preserved**:
- [ ] Workflow captures complete sequence
- [ ] Components show role + integration points
- [ ] Edge cases highlight what will break
- [ ] Decisions explain non-obvious choices (when needed)
- [ ] Performance summarized (not detailed analysis)
- [ ] Cross-references connect to existing KB (10+)
- [ ] Daily log references distilled docs (not external paths)

**Apply the 6-Month Test**:
> "If reading only the distilled docs, can the system be understood and extended?"

If NO → Extract missing critical knowledge

---

## Distillation Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| Size Reduction | 90-96% | 100+ KB → 5-10 KB |
| Workflow Steps | 6-10 | Not 30+ paragraphs |
| Component Descriptions | 3-5 lines each | Role + key methods |
| Cross-References | 10-15 | Connect to existing KB |
| Time Required | 20-30 min | Per investigation set |

---

## Common Distillation Pitfalls

1. **Over-preserving details**: Keep asking "MUST this be known in 6 months?"
2. **Under-cross-referencing**: Link to existing KB documents
3. **Missing edge cases**: Document what breaks the system
4. **Losing decision rationale**: Explain why choices were made
5. **Creating orphan docs**: Always link from daily log and MOC
