# Context Efficiency Techniques

Techniques for maximizing context efficiency when performing knowledge bank lookups.

## MOC-First Navigation

Always instruct subagents to start with the Map of Content (MOC) for efficient document discovery:

**Without MOC**:
- Reading all 81 [project-a] documents: ~24,300 lines
- High context consumption
- Inefficient exploration

**With MOC-First**:
- Read MOC: 304 lines
- Read 3 targeted docs: ~900 lines
- Total: 1,204 lines
- **Reduction: 94%**

### Implementation

Always structure subagent prompts to start with MOC:

```
Workflow:
1. Read the MOC: /knowledge-bank/_index/{service_upper} MOC.md
2. Identify 2-3 (quick) or 5-7 (standard) relevant documents
3. Read identified documents
4. Synthesize findings
```

## Smart Cross-Reference Pruning

WikiLinks can create exponential explosion. Instruct subagents to prune based on depth:

- **Quick Lookup**: Only directly mentioned concepts
- **Standard Lookup**: Include 1-hop related concepts
- **Deep Lookup**: Include 2-hop but return as "additional reading" in cross_references field

### Example

Document mentions [[Parallel Execution]] → links to [[Test Isolation]] → links to [[Build Pipeline]]

- Quick: Only read Parallel Execution
- Standard: Read Parallel Execution + Test Isolation
- Deep: Read Parallel Execution + Test Isolation, mention Build Pipeline in cross_references

## Batch Request Optimization

When multiple related lookups are needed, combine them into a single subagent call:

```python
Task({
  description: "Batch lookup: [project-a] filters, tests, metrics",
  subagent_type: "explore",
  prompt: f"""
You are performing a batch lookup for three related topics:
1. [project-a] filter implementation
2. Test patterns for filters
3. Metrics best practices

Instructions:
- Read MOC once
- Identify documents relevant to ANY of the three topics
- When a document applies to multiple topics, mention it in each relevant section
- Deduplicate shared patterns in a "Shared Patterns" section

[Include batch-friendly JSON format]
"""
})
```

**Context Savings**: 29% reduction vs. three separate lookups

### When to Batch

- Multiple aspects of same component
- Implementation + Testing + Metrics
- Cross-cutting concerns across related features
- Follow-up questions on same topic

## Progressive Refinement

For follow-up queries, reference previous lookup context so subagent can reuse its cached data:

```python
Task({
  description: "Follow-up lookup",
  subagent_type: "explore",
  prompt: f"""
Previous Lookup Context:
- Documents already analyzed: {previous_metadata.documents_analyzed}
- User is implementing {context}

Current Question: {refined_question}

You can reuse your cached MOC and concept summaries.
Focus on: {specific_focus}
"""
})
```

**Benefits**:
- Subagent context preserved
- No need to re-read MOC
- Faster follow-up responses
- Main agent context stays clean

## Depth Selection

Choose appropriate lookup depth based on query complexity:

| Depth | Use For | Context Budget | Documents |
|-------|---------|----------------|-----------|
| Quick | Service mention, simple reference | ~900 lines | 2-3 docs |
| Standard | Investigation, implementation planning | ~1950 lines | 5-7 docs |
| Deep | Ultrathink, architectural decisions | ~7300 lines | 10+ docs |

### Anti-Patterns

- ❌ Using Deep lookup for "What's the pattern for X?"
- ❌ Using Quick lookup for "Design comprehensive system"
- ❌ Not respecting context budgets

### Best Practices

- ✅ Start with Quick, escalate if needed
- ✅ Match depth to complexity
- ✅ Consider follow-up questions vs. initial deep dive
