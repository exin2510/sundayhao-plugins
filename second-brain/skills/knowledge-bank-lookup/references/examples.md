# Integration Examples

This document shows how the knowledge-bank-lookup skill integrates into workflows with concrete examples.

**Note**: With `context: fork` and `agent: Explore` in the skill's YAML frontmatter, the skill automatically executes in an isolated subagent context.

## Example 1: User Mentions [project-a] Filter Implementation

**Trigger**: User says "I need to implement a new [project-a] filter for brand safety"

**Detection** (automatic):
- Service: [project-a]
- Topic: filter implementation
- Depth: Standard (implementation planning)

**What Happens**:
The skill automatically activates and the Explore subagent executes the following workflow:
1. Read the MOC: `{KB_PATH}/_index/[project-a] MOC.md`
2. Identify 5-7 relevant documents about:
   - Filter implementation patterns
   - Plugin architecture
   - Rule-based filtering (brand safety likely uses rules)
   - Test patterns
3. Read identified documents
4. Synthesize findings with practical recommendations
5. Return JSON response to main agent

**Manual Invocation** (if auto-detection doesn't apply):
```python
# Using Skill tool
Skill({
  skill: "second-brain:knowledge-bank-lookup"
})

# Or via slash command
/second-brain:knowledge-bank-lookup
```

**Main Agent Response Construction**:
```python
# After receiving JSON response from subagent
response = f"""
I found comprehensive patterns for implementing your [project-a] brand safety filter.

**Recommended Pattern: {json.relevant_patterns[0].pattern_name}**

{json.executive_summary.recommended_action}

**Key Implementation Steps**:
[Extract from relevant_patterns]

**Important Gotchas**:
{'\n'.join(f'- {g}' for g in json.relevant_patterns[0].gotchas)}

**References**:
- Pattern: {json.relevant_patterns[0].source_document}
- Best practices: {json.best_practices[0].doc_path}

Would you like me to implement this pattern, or explore any of these follow-up topics?
{'\n'.join(f'- {t}' for t in json.cross_references.follow_up_topics)}
"""
```

## Example 2: Investigation Request

**Trigger**: User says "investigate: how COPPA filter works in [project-a]"

**Detection**:
- Keyword: "investigate:"
- Service: [project-a]
- Topic: COPPA filter
- Depth: Standard

**Action**: Same as Example 1 but with topic="COPPA filter implementation and architecture"

## Example 3: Ultrathink Request

**Trigger**: User says "ultrathink: design comprehensive brand safety system across [project-a] and [project-b]"

**Detection**:
- Keyword: "ultrathink"
- Services: [project-a], [project-b] (cross-service)
- Depth: Deep

**Action**: Use Deep Lookup Template with general-purpose subagent, analyzing 10+ documents across both services, synthesizing architectural patterns, implementation roadmap, and cross-service integration strategies.

## Example 4: Progressive Refinement

**Initial Query**: "What's the pattern for [project-a] filters?" → Quick lookup

**Follow-Up**: "Tell me more about Event Ruler patterns"

**What the Skill Does Internally**:
When the skill executes for a follow-up lookup, the Explore subagent:

1. Uses context from previous lookup (documents already analyzed)
2. Focuses on the refined topic: Event Ruler patterns
3. Reads Event Ruler Integration component documentation in detail
4. Reviews Event Ruler Dynamic Field Patterns concept
5. Extracts code examples from COPPA and other filter implementations
6. Analyzes best practices for rule structure

**Focus Areas** (determined by the skill):
- Rule JSON syntax
- Field path expressions
- Matching operators
- Complex boolean logic
- Testing approach

**Invocation**: Automatic on follow-up questions, or manual via:
```python
Skill({ skill: "second-brain:knowledge-bank-lookup" })
```

## Example 5: WikiLink Following (v2.2.0+)

**Trigger**: User asks "Explain the Parallel Execution Pattern in [project-a]"

**Detection** (automatic):
- Service: [project-a]
- Topic: Parallel Execution Pattern
- Depth: Standard (needs complete understanding with related concepts)
- WikiLink traversal: Yes (pattern will reference related concepts)

**What the Skill Does Internally**:
The Explore subagent automatically executes this workflow:

1. **Reflections check**: Search `{KB_PATH}/reflections/*.md` for "parallel" or "execution"
2. **Read MOC**: `{KB_PATH}/_index/[project-a] MOC.md`
3. **Identify primary document**: Parallel Execution Pattern
4. **WikiLink DFS traversal (depth 1-2)**:
   - Extract WikiLinks from the Pattern document
   - Prioritize by relevance to "parallel execution async"
   - Follow top 5-7 links using DFS (max depth 2)
   - For each linked doc, extract key insights and relationships
5. **Synthesize**: Combine pattern definition, prerequisites, implementation details, and gotchas

**Expected JSON Response Structure**:
```json
{
  "executive_summary": {
    "key_findings": ["What the pattern is", "When to use it", "Key prerequisites"],
    "confidence_level": "high",
    "recommended_action": "Next steps for implementation"
  },
  "relevant_patterns": [...],
  "linked_concepts": [
    {
      "concept_name": "Vert.x Event Loop Safety",
      "link_source": "Parallel Execution Pattern.md",
      "depth": 1,
      "relevance": "Explains why single event loop prevents race conditions",
      "key_insight": "All operations execute on same event loop thread"
    }
  ],
  "link_traversal": {
    "total_links_found": 8,
    "links_followed": 5,
    "max_depth_reached": 2,
    "traversal_strategy": "prioritized-2hop"
  }
}
```

**Manual Invocation** (if needed):
```python
Skill({ skill: "second-brain:knowledge-bank-lookup" })
```

**Main Agent Response Construction**:
```python
# After receiving JSON response with WikiLink traversal
response = f"""
I've thoroughly explored the Parallel Execution Pattern by following {json.link_traversal.links_followed} WikiLinks across {json.link_traversal.max_depth_reached} levels of related documents.

**Pattern Overview**:
{json.relevant_patterns[0].applicability}

**How It Works** (from linked concepts):

1. **{json.linked_concepts[0].concept_name}** (prerequisite):
   {json.linked_concepts[0].key_insight}
   → This is why you don't need locks or synchronization

2. **{json.linked_concepts[1].concept_name}** (implementation):
   {json.linked_concepts[1].key_insight}
   → This is how you actually write the code

**Important Gotchas**:
{'\n'.join(f'- {g}' for g in json.relevant_patterns[0].gotchas)}

**Documents Explored**:
- Primary: {json.metadata.primary_documents}
- Discovered via WikiLinks: {json.metadata.linked_documents}
- Traversal depth: {json.link_traversal.max_depth_reached} hops

The WikiLink traversal ensured we discovered all the prerequisite concepts ({json.linked_concepts[0].concept_name}) and implementation patterns ({json.linked_concepts[1].concept_name}) that make this pattern work.

**References**:
{'\n'.join(f'- [{c["concept_name"]}]({c["doc_path"]}) (depth {c["depth"]})' for c in json.linked_concepts)}

Would you like me to dive deeper into any of these linked concepts?
"""
```

**Key Benefits Demonstrated**:
- **Complete Understanding**: WikiLink following discovered Vert.x Event Loop Safety (prerequisite) and CompositeFuture.all (implementation)
- **No Missed Concepts**: DFS ensured all related docs were found
- **Depth Tracking**: Know which concepts are prerequisites (depth 1) vs implementation details (depth 2)
- **Efficient**: Only followed 5 of 8 links based on relevance scoring
