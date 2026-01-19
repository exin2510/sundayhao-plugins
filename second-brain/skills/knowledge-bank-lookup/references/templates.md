# Skill Workflow Templates

This document describes the internal workflows that the knowledge-bank-lookup skill executes when invoked. With `context: fork` and `agent: Explore` configured in the skill's YAML frontmatter, these workflows run automatically in an isolated Explore subagent.

**Note**: The knowledge bank path is dynamically resolved at runtime using common utilities. The skill internally resolves `{KB_PATH}` via `~/.claude/skills/common/get_kb_path.sh`.

---

<a id="quick-lookup-template"></a>
## Quick Lookup Workflow

**This workflow activates when**: Service mentions, simple component references

**Context Budget**: ~900 lines analyzed → 300 lines returned

```
You are a knowledge bank exploration agent. Your task is to quickly lookup information about {service} related to {topic}.

Knowledge Bank Location: {KB_PATH}

Workflow:
0. Check reflections first: List recent reflections (ls -t {KB_PATH}/reflections/ | head -5) and read any matching {topic} or {service} for workflow insights
1. Read the MOC: {KB_PATH}/_index/{service_upper} MOC.md
2. Identify 2-3 most relevant documents based on keywords: {keywords}
3. Read those documents (concepts or components only, not daily logs)
4. **Follow WikiLinks (DFS - 1 hop)**:
   - Source WikiLink utilities: source ~/.claude/skills/knowledge-bank-lookup/scripts/wikilink-utils.sh
   - Initialize: reset_visited
   - For each document read, extract WikiLinks: extract_wikilinks "doc.md"
   - Follow 1-hop links (max 2-3 additional docs): resolve_wikilink "Link Name" "{KB_PATH}"
   - Read resolved documents and capture key insights
   - Track visited to prevent cycles
5. Synthesize findings including insights from linked documents with reflection lessons

Output Format (JSON):
{
  "executive_summary": {
    "key_findings": ["finding 1", "finding 2", "finding 3"],
    "confidence_level": "high/medium/low",
    "recommended_action": "specific action to take"
  },
  "reflection_insights": {
    "past_mistakes": ["failures to avoid from reflections"],
    "proven_approaches": ["what worked well before"],
    "workflow_gotchas": ["friction points to watch for"]
  },
  "relevant_patterns": [
    {
      "pattern_name": "...",
      "source_document": "absolute path",
      "applicability": "why relevant",
      "code_snippet": "...",
      "gotchas": ["gotcha 1", "gotcha 2"]
    }
  ],
  "related_concepts": [
    {
      "concept_name": "...",
      "relationship": "prerequisite/alternative/related",
      "brief_description": "1-2 sentences",
      "doc_path": "absolute path"
    }
  ],
  "linked_concepts": [
    {
      "concept_name": "...",
      "link_source": "document where link was found",
      "depth": 1,
      "relevance": "why this is relevant",
      "key_insight": "main takeaway from linked doc",
      "doc_path": "absolute path"
    }
  ],
  "cross_references": {
    "additional_documents": [],
    "follow_up_topics": []
  },
  "link_traversal": {
    "total_links_found": 0,
    "links_followed": 0,
    "max_depth_reached": 1,
    "traversal_strategy": "selective-1hop"
  },
  "metadata": {
    "documents_analyzed": 0,
    "primary_documents": 0,
    "linked_documents": 0,
    "analysis_depth": "quick",
    "limitations": []
  }
}

Context:
User Intent: {user_intent}
Keywords: {keywords}

IMPORTANT: Return ONLY the JSON response, no additional commentary.

Begin your exploration now.
```

<a id="standard-lookup-template"></a>
## Standard Lookup Workflow

**This workflow activates when**: Investigation mode, implementation planning, best practice queries

**Context Budget**: ~1950 lines analyzed → 600 lines returned

```
You are a knowledge bank investigation agent. Your task is to perform a thorough lookup about {service} related to {topics}.

Knowledge Bank Location: {KB_PATH}

Workflow:
0. Check reflections first: Search reflections for {topic} or {service} (grep -l "{topic}" {KB_PATH}/reflections/*.md) and extract workflow lessons
1. Read the MOC: {KB_PATH}/_index/{service_upper} MOC.md
2. Identify 5-7 relevant documents (concepts, components, best practices)
3. Read identified documents
4. **Follow WikiLinks (DFS - 1-2 hops)**:
   - Source WikiLink utilities: source ~/.claude/skills/knowledge-bank-lookup/scripts/wikilink-utils.sh
   - Initialize: reset_visited
   - Extract all WikiLinks from primary documents: extract_wikilinks "doc.md"
   - Prioritize by relevance: prioritize_wikilinks "$links" "{keywords}"
   - Follow top 5-7 links using DFS (max depth 2): dfs_traverse "start_doc.md" 0 2 "{KB_PATH}" 10 "{keywords}"
   - For each linked doc, extract key insights and relationships
   - Track traversal path and document depths
5. Synthesize findings with practical recommendations and reflection insights, including linked concept discoveries

Output Format (JSON):
{
  "executive_summary": {
    "key_findings": ["finding 1", "finding 2", "finding 3", "finding 4"],
    "confidence_level": "high/medium/low",
    "recommended_action": "detailed next step"
  },
  "reflection_insights": {
    "past_mistakes": ["documented failures to avoid"],
    "proven_approaches": ["what worked well in similar situations"],
    "workflow_gotchas": ["process friction points"],
    "tool_gaps": ["missing tools that would help"]
  },
  "relevant_patterns": [
    {
      "pattern_name": "...",
      "source_document": "absolute path",
      "applicability": "detailed explanation",
      "code_snippet": "...",
      "gotchas": ["gotcha 1", "gotcha 2", "gotcha 3"]
    }
  ],
  "related_concepts": [
    {
      "concept_name": "...",
      "relationship": "prerequisite/alternative/related",
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
      "link_source": "document where link was found",
      "depth": 1,
      "relevance": "why this is relevant",
      "key_insight": "main takeaway from linked doc",
      "doc_path": "absolute path"
    }
  ],
  "cross_references": {
    "additional_documents": [],
    "related_services": [],
    "follow_up_topics": []
  },
  "link_traversal": {
    "total_links_found": 0,
    "links_followed": 0,
    "max_depth_reached": 2,
    "traversal_strategy": "prioritized-2hop",
    "traversal_path": [
      {"doc": "Document.md", "depth": 0},
      {"doc": "Linked Doc.md", "depth": 1}
    ]
  },
  "metadata": {
    "documents_analyzed": 0,
    "primary_documents": 0,
    "linked_documents": 0,
    "analysis_depth": "standard",
    "knowledge_bank_version": "YYYY-MM-DD",
    "limitations": []
  }
}

Context:
User Intent: {user_intent}
Focus Areas: {focus_areas}
Current Working Files: {working_files}

Additional Requirements:
- Include code snippets where applicable
- Mention gotchas and known issues
- Reference recent work if relevant
- Suggest follow-up topics for deeper investigation

IMPORTANT: Return ONLY the JSON response, no additional commentary.

Begin your investigation now.
```

<a id="deep-lookup-template"></a>
## Deep Lookup Workflow

**This workflow activates when**: "ultrathink" requests, major refactoring, architectural decisions, cross-service analysis

**Context Budget**: ~7300 lines analyzed → 1500 lines returned

```
You are a senior knowledge bank analyst. Your task is to perform comprehensive analysis about {service} for {purpose}.

Knowledge Bank Location: {KB_PATH}

Workflow:
0. Comprehensive reflection analysis: Read ALL reflections related to {topic} or {service} ({KB_PATH}/reflections/*.md), identify recurring patterns and meta-insights about process evolution
1. Read ALL relevant MOCs: {KB_PATH}/_index/*.md
2. Identify 10+ relevant documents across:
   - Concepts (architectural patterns)
   - Components (implementation details)
   - Best practices (methodologies)
3. **Follow WikiLinks (Full DFS - 2-3 hops)**:
   - Source WikiLink utilities: source ~/.claude/skills/knowledge-bank-lookup/scripts/wikilink-utils.sh
   - Initialize: reset_visited
   - Perform comprehensive DFS from each primary document:
     * dfs_traverse "start_doc.md" 0 3 "{KB_PATH}" 20 "{keywords}"
   - Build complete link graph showing all traversed documents
   - Categorize linked docs by type (concepts/components/best-practices)
   - Extract key insights from each depth level
   - Identify cross-cutting patterns across linked documents
4. Analyze cross-service patterns if applicable
5. Synthesize comprehensive report with deep reflection insights and link graph insights

Output Format (JSON):
{
  "executive_summary": {
    "key_findings": ["finding 1", "finding 2", "finding 3", "finding 4", "finding 5"],
    "confidence_level": "high/medium/low",
    "recommended_action": "implementation roadmap"
  },
  "reflection_insights": {
    "past_mistakes": ["documented failures across sessions"],
    "proven_approaches": ["what worked consistently well"],
    "workflow_gotchas": ["recurring friction points"],
    "tool_gaps": ["missing tools that would help"],
    "meta_insights": ["patterns across multiple sessions", "process evolution insights"]
  },
  "relevant_patterns": [
    {
      "pattern_name": "...",
      "source_document": "absolute path",
      "applicability": "comprehensive explanation",
      "code_snippet": "...",
      "gotchas": ["gotcha 1", "gotcha 2", "gotcha 3"]
    }
  ],
  "related_concepts": [
    {
      "concept_name": "...",
      "relationship": "prerequisite/alternative/related",
      "brief_description": "detailed explanation",
      "doc_path": "absolute path"
    }
  ],
  "recent_work": [
    {
      "date": "YYYY-MM-DD",
      "session_title": "...",
      "relevance": "detailed relevance analysis",
      "lessons_learned": ["lesson 1", "lesson 2", "lesson 3"],
      "doc_path": "absolute path"
    }
  ],
  "best_practices": [
    {
      "practice_name": "...",
      "when_to_apply": "...",
      "key_principles": ["principle 1", "principle 2", "principle 3"],
      "doc_path": "absolute path"
    }
  ],
  "architectural_considerations": [
    {
      "consideration": "...",
      "trade_offs": "...",
      "recommendation": "..."
    }
  ],
  "implementation_roadmap": {
    "phases": [
      {
        "phase_name": "...",
        "objectives": ["..."],
        "risks": ["..."],
        "checkpoints": ["..."]
      }
    ]
  },
  "linked_concepts": [
    {
      "concept_name": "...",
      "link_source": "document where link was found",
      "depth": 1,
      "relevance": "why this is relevant",
      "key_insight": "main takeaway from linked doc",
      "doc_path": "absolute path"
    }
  ],
  "link_graph": {
    "nodes": [
      {"doc": "Document.md", "type": "concept/component/best-practice"}
    ],
    "edges": [
      {"from": "Doc A.md", "to": "Doc B.md", "depth": 1}
    ],
    "depth_statistics": {
      "depth_0": 10,
      "depth_1": 5,
      "depth_2": 3,
      "depth_3": 1
    }
  },
  "cross_references": {
    "additional_documents": [],
    "related_services": [],
    "follow_up_topics": []
  },
  "link_traversal": {
    "total_links_found": 0,
    "links_followed": 0,
    "max_depth_reached": 3,
    "traversal_strategy": "comprehensive-dfs-3hop",
    "traversal_path": [
      {"doc": "Document.md", "depth": 0},
      {"doc": "Linked Doc.md", "depth": 1},
      {"doc": "Second Level Doc.md", "depth": 2}
    ]
  },
  "metadata": {
    "documents_analyzed": 0,
    "primary_documents": 0,
    "linked_documents": 0,
    "analysis_depth": "deep",
    "knowledge_bank_version": "YYYY-MM-DD",
    "limitations": []
  }
}

Context:
User Intent: {user_intent}
Architectural Context: {architectural_context}
Constraints: {constraints}

Additional Requirements:
- Include implementation roadmap with phases
- Identify risks and mitigation strategies
- Reference multiple precedents
- Provide decision framework
- Suggest checkpoints and validation steps

IMPORTANT: Return ONLY the JSON response, no additional commentary.

Begin your comprehensive analysis now.
```
