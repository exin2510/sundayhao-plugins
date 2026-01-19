# Session Recap Templates

Quick reference for all document templates used by the session-recap skill.

---

## Template Index

| Document Type | Template File | Cross-Refs Required |
|---------------|--------------|-------------------|
| Daily Log | [daily-log-template.md](daily-log-template.md) | 10-15 |
| Concept | [concept-template.md](concept-template.md) | 10-15 |
| Component | [component-template.md](component-template.md) | 10-15 |
| Best Practice | [best-practice-template.md](best-practice-template.md) | 10-15 |
| Process Reflection | [process-reflection-template.md](process-reflection-template.md) | 5-8 |
| Distilled Concept | [distilled-concept-template.md](distilled-concept-template.md) | 10-15 |

---

## File Locations

| Document Type | Path Pattern |
|---------------|-------------|
| Daily Log | `{KB}/daily-log/YYYY-MM-DD [Topic].md` |
| Concept | `{KB}/projects/{project}/concepts/[Name].md` |
| Component | `{KB}/projects/{project}/components/[Name].md` |
| Best Practice | `{KB}/projects/{project}/best-practices/[Name].md` |
| Reflection | `{KB}/reflections/{category}/[name-kebab-case].md` |

---

## YAML Frontmatter (Required for All)

```yaml
---
title: Document Title
aliases: [Alternative Name 1, Alternative Name 2]
tags: [category, topic, type]
type: concept|component|best-practice|daily-log|reflection
created: YYYY-MM-DD
modified: YYYY-MM-DD
project: [project-a-service]|[project-b-server]|Claude Code|[project-c]
---
```

---

## Reflection Categories

| Category | Folder | Triggers |
|----------|--------|----------|
| Architecture Patterns | `architecture-patterns/` | Threading, state management, design patterns |
| Development Workflow | `development-workflow/` | Utility discovery, test-first, dependency navigation |
| Anti-Patterns | `anti-patterns/` | Wrong approaches, naming confusion, misunderstandings |
| DX Improvements | `dx-improvements/` | Search strategies, missing docs, tool gaps |

> **Note**: These are example categories. Create custom categories by adding subdirectories to `{KB}/reflections/`. The system discovers categories dynamically.

---

## Quick Template Summaries

### Daily Log Structure
1. Session Overview (metrics)
2. Key Discoveries
3. Problems Solved
4. Work Completed
5. Technical Decisions
6. Lessons Learned
7. Knowledge Created (links to docs)
8. Process Reflections (links to reflections)

### Concept Structure
1. Overview
2. Core Principle
3. Usage Patterns (when to use, when NOT)
4. Examples with code
5. Anti-Patterns
6. Cross-References

### Component Structure
1. Overview (purpose, package)
2. Architecture (hierarchy)
3. Key Methods
4. Usage Examples
5. Testing Patterns
6. Cross-References

### Best Practice Structure
1. Overview
2. When to Apply
3. Decision Framework
4. Examples
5. Common Mistakes
6. Case Studies
7. Cross-References

### Reflection Structure
1. Context (what happened)
2. Pattern (what was learned)
3. Impact (why it matters)
4. Prevention/Application (how to use)
5. Related Links
