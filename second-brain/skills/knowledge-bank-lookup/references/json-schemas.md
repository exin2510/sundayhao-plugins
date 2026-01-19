# JSON Response Schemas

This document specifies the JSON structure that subagents return when performing knowledge bank lookups.

## Standard Response Format

All subagents should return JSON with this structure:

```json
{
  "executive_summary": {
    "key_findings": ["finding 1", "finding 2", "finding 3"],
    "confidence_level": "high" | "medium" | "low",
    "recommended_action": "specific next step"
  },

  "reflection_insights": {
    "past_mistakes": ["documented failures to avoid"],
    "proven_approaches": ["what worked well in similar situations"],
    "workflow_gotchas": ["process friction points to watch for"],
    "tool_gaps": ["missing tools that would help"],
    "meta_insights": ["patterns across multiple sessions"]
  },

  "relevant_patterns": [
    {
      "pattern_name": "...",
      "source_document": "absolute path",
      "applicability": "why this pattern is relevant",
      "code_snippet": "...",  // if available
      "gotchas": ["gotcha 1", "gotcha 2"]
    }
  ],

  "related_concepts": [
    {
      "concept_name": "...",
      "relationship": "prerequisite" | "alternative" | "related",
      "brief_description": "1-2 sentences",
      "doc_path": "absolute path"
    }
  ],

  "recent_work": [
    {
      "date": "YYYY-MM-DD",
      "session_title": "...",
      "relevance": "why it matters",
      "lessons_learned": ["lesson 1", "lesson 2"],
      "doc_path": "absolute path"
    }
  ],

  "best_practices": [
    {
      "practice_name": "...",
      "when_to_apply": "...",
      "key_principles": ["principle 1", "principle 2"],
      "doc_path": "absolute path"
    }
  ],

  "linked_concepts": [
    {
      "concept_name": "...",
      "link_source": "document where WikiLink was found",
      "depth": 1,  // hop count: distance from primary documents (1 = directly linked, 2 = linked from linked doc, etc.)
      "relevance": "why this linked concept matters",
      "key_insight": "main takeaway from the linked document",
      "doc_path": "absolute path"
    }
  ],

  "cross_references": {
    "additional_documents": ["path 1", "path 2"],
    "related_services": ["service 1", "service 2"],
    "follow_up_topics": ["topic 1", "topic 2"]
  },

  "link_traversal": {
    "total_links_found": 50,  // all WikiLinks discovered
    "links_followed": 8,      // how many were actually traversed
    "max_depth_reached": 2,   // deepest level explored
    "traversal_strategy": "selective-1hop" | "prioritized-2hop" | "comprehensive-dfs-3hop",
    "traversal_path": [       // DFS path taken (optional, for deep lookups)
      {"doc": "Document.md", "depth": 0},
      {"doc": "Linked Doc.md", "depth": 1}
    ]
  },

  "metadata": {
    "documents_analyzed": 5,
    "primary_documents": 3,   // directly from MOC/query
    "linked_documents": 2,    // discovered via WikiLinks
    "analysis_depth": "quick" | "standard" | "deep",
    "knowledge_bank_version": "YYYY-MM-DD",
    "limitations": ["limitation 1", "limitation 2"]
  }
}
```

## Field Descriptions

### executive_summary
High-level findings and recommended actions:
- **key_findings**: 3-5 most important discoveries
- **confidence_level**: How certain the analysis is
- **recommended_action**: Concrete next step to take

### reflection_insights
Learning from past experience (v2.1.0+):
- **past_mistakes**: Documented failures to avoid repeating
- **proven_approaches**: Workflows that worked well before
- **workflow_gotchas**: Friction points to be aware of
- **tool_gaps**: Missing capabilities that would help
- **meta_insights**: Cross-session patterns and evolution

### relevant_patterns
Specific technical patterns found:
- **pattern_name**: Name of the pattern
- **source_document**: Absolute path for reference
- **applicability**: Why relevant to the query
- **code_snippet**: Example implementation if available
- **gotchas**: Known issues and pitfalls

### related_concepts
Connected ideas and prerequisites:
- **concept_name**: Name of related concept
- **relationship**: How it relates (prerequisite/alternative/related)
- **brief_description**: Quick explanation
- **doc_path**: Where to read more

### recent_work
Past sessions that provide context:
- **date**: When the work was done
- **session_title**: What was worked on
- **relevance**: Why it matters now
- **lessons_learned**: Key takeaways
- **doc_path**: Where to find details

### best_practices
Recommended approaches:
- **practice_name**: Name of the practice
- **when_to_apply**: Situations where it's appropriate
- **key_principles**: Core guidelines
- **doc_path**: Detailed documentation

### linked_concepts (v2.2.0+)
Concepts discovered through WikiLink traversal:
- **concept_name**: Name of the linked concept
- **link_source**: Which primary document contained the WikiLink
- **depth**: Hop count - distance from primary documents (1 = directly linked, 2 = linked from a linked doc, 3 = two links away)
- **relevance**: Why this linked concept is important to the query
- **key_insight**: Main takeaway from the linked document
- **doc_path**: Absolute path to the linked document

### cross_references
Additional exploration paths:
- **additional_documents**: More docs to read
- **related_services**: Other services involved
- **follow_up_topics**: Deeper dive opportunities

### link_traversal (v2.2.0+)
WikiLink traversal statistics:
- **total_links_found**: All WikiLinks discovered in primary documents
- **links_followed**: How many links were actually followed (based on relevance)
- **max_depth_reached**: Deepest level of DFS traversal (1-3)
- **traversal_strategy**: Approach used (selective-1hop / prioritized-2hop / comprehensive-dfs-3hop)
- **traversal_path**: Ordered list of documents visited with depths (for deep lookups)

### metadata
Information about the analysis:
- **documents_analyzed**: Total documents read (primary + linked)
- **primary_documents**: Documents identified from MOC/query
- **linked_documents**: Documents discovered via WikiLinks
- **analysis_depth**: quick/standard/deep
- **knowledge_bank_version**: Date of KB state
- **limitations**: What wasn't covered and why

## Usage Notes

1. **Always request absolute paths** for easy navigation
2. **Require "ONLY JSON" responses** to avoid extra commentary
3. **Include context** (user intent, focus areas) in subagent prompts
4. **Respect analysis depth** limits:
   - Quick: Lighter on recent_work and best_practices
   - Standard: Full structure
   - Deep: Add architectural_considerations and implementation_roadmap
5. **WikiLink Traversal** (v2.2.0+):
   - Quick: Follow 1-hop links selectively (2-3 additional docs max)
   - Standard: Follow 1-2 hop links prioritized by relevance (5-7 additional docs)
   - Deep: Comprehensive DFS up to 3 hops (up to 20 total docs)
   - Always track visited documents to prevent cycles
   - Prioritize links by keyword relevance to query
   - Include link_traversal metadata in all responses
