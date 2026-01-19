---
title: [Practice Name]
aliases: [Alternative Name 1, Alternative Name 2]
tags: [{project}/best-practice, category, methodology]
type: best-practice
status: active
complexity: intermediate
applicability:
  - [scenario1]
  - [scenario2]
related-concepts: []
related-components: []
supersedes:
superseded-by:
last-reviewed: YYYY-MM-DD
created: YYYY-MM-DD
modified: YYYY-MM-DD
category: testing | refactoring | architecture | code-review | migration | debugging | performance
project: [ProjectName]
---

# [Practice Name]

> [!abstract] Overview
> [2-3 sentences describing what this practice is, what problems it solves, and why it's valuable]

> [!question] The Core Question
> **What problem does this practice solve?**
> [Detailed explanation of the problem this practice addresses]

> [!important] Principle Statement
> [Clear, concise statement of the core principle - ideally one sentence that captures the essence]

## When to Apply

✅ **[Situation 1]**: [Description and why the practice helps]
✅ **[Situation 2]**: [Description and why the practice helps]
✅ **[Situation 3]**: [Description and why the practice helps]

### Indicators This Practice is Needed

- [Signal 1 that suggests using this practice]
- [Signal 2 that suggests using this practice]
- [Signal 3 that suggests using this practice]

## When NOT to Apply

❌ **[Situation 1]**: [Description and why the practice doesn't help or creates problems]
❌ **[Situation 2]**: [Description and why alternatives are better]
❌ **[Situation 3]**: [Description and why it's overkill]

### Red Flags

- [Warning sign 1 that this practice is inappropriate]
- [Warning sign 2 that this practice is inappropriate]

## Decision Framework

### Step-by-Step Process

1. **Evaluate [Criterion 1]**
   - Question to ask: [What to consider]
   - If yes: [Next step]
   - If no: [Alternative path]

2. **Check [Criterion 2]**
   - Question to ask: [What to consider]
   - If yes: [Next step]
   - If no: [Alternative path]

3. **Decide Based on [Factors]**
   - [Decision rule 1]
   - [Decision rule 2]

### Decision Tree

```
Is [condition 1] true?
  YES → Apply this practice
  NO → Is [condition 2] true?
        YES → Consider modified approach
        NO → Use alternative practice [[Alternative Practice]]
```

## Implementation Guide

### How to Apply This Practice

#### Step 1: [First Step]
[Detailed instructions]

#### Step 2: [Second Step]
[Detailed instructions]

#### Step 3: [Third Step]
[Detailed instructions]

### Checklist

Before completing this practice, verify:
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

## Examples

### Good Example ✅

**Context**: [Situation where this practice was applied]
**Implementation**:

**File**: `/path/to/example.java` (lines X-Y)
```java
// Example of correct application
public class GoodExample {
    // Implementation following the practice
}
```

**Result**: [Positive outcome with metrics if available]
**Why It Worked**: [Explanation of why this application was successful]

### Bad Example ❌

**Context**: [Situation where practice was misapplied or violated]
**Implementation**:

```java
// Example of incorrect approach
public class BadExample {
    // Implementation violating the practice
}
```

**Problem**: [What went wrong - issues created, complexity added]
**Why It Failed**: [Explanation of why this didn't work]

### Before/After Comparison

**Before** (❌ Without Practice):
```java
// Code before applying the practice
// Complex, error-prone, hard to maintain
```

**After** (✅ With Practice):
```java
// Code after applying the practice
// Simpler, clearer, maintainable
```

**Impact**: [Measurable improvements - lines reduced, bugs prevented, time saved]

## Common Mistakes

> [!danger] Mistake 1: [Common Error]
> **Description**: [What people often get wrong]
> **Why It Happens**: [Root cause of the mistake]
> **How to Avoid**: [Specific guidance to prevent this mistake]
> **Correct Approach**: [What to do instead]

> [!danger] Mistake 2: [Common Error]
> **Description**: ...
> **How to Avoid**: ...

## Trade-offs and Limitations

### Benefits

- [Benefit 1 with metrics/evidence]
- [Benefit 2 with metrics/evidence]
- [Benefit 3 with metrics/evidence]

### Costs

- [Cost/overhead 1]
- [Cost/overhead 2]

### When Trade-offs are Worth It

[Criteria for when the benefits outweigh the costs]

### When Trade-offs are NOT Worth It

[Criteria for when the costs outweigh the benefits]

## Real-World Case Studies

### Case Study 1: [Title]

**Problem**: [Original problem or situation]
**Application**: [How this practice was applied step-by-step]
**Challenges**: [Difficulties encountered]
**Result**: [Measurable outcome - time saved, bugs prevented, code quality improved]
**Lessons**: [What was learned from this application]

**Reference**: [[YYYY-MM-DD Session Name]]

### Case Study 2: [Title]

...

## Metrics for Success

How to measure whether this practice is working:

- **[Metric 1]**: [How to measure] (Target: [target value])
- **[Metric 2]**: [How to measure] (Target: [target value])
- **[Metric 3]**: [How to measure] (Target: [target value])

## Cross-References

> [!info] Related Knowledge
> Populate the frontmatter `related-concepts`, `related-components` properties for graph navigation.

### Related Practices
- [[Related Practice 1#Decision Framework]] - [How they relate - complementary, alternative, prerequisite]
- [[Related Practice 2]] - [How they relate]
- [[Related Practice 3]] - [How they relate]

### Related Concepts
- [[Concept 1#Core Principle]] - [Connection]
- [[Concept 2]] - [Connection]

### Related Components
- [[Component 1]] - [Example of practice in action]
- [[Component 2]] - [Example of practice in action]

## Source Insight (if insight-derived)

> [!note] Insight Origin
> If this best practice was derived from an educational insight, include the original insight here.

> `★ Insight ─────────────────────────────────────`
> [Original insight that documented this methodology]
> `─────────────────────────────────────────────────`

**Session**: [[YYYY-MM-DD Session Name]]
**Why this insight became a best practice**: [Brief explanation of why this methodology warrants documentation]

## Further Reading

- **Origin Session**: [[YYYY-MM-DD Session]]
- **Related Documentation**: [[Related Doc]]
- **External Resources**: [Links if applicable]

## Revision History

> [!example] Recent Changes
> ### YYYY-MM-DD
> - [Change or refinement to the practice]
> - **Session**: [[YYYY-MM-DD Session Name]]

---

> [!note] Document Metadata
> - **Last Updated**: YYYY-MM-DD
> - **Status**: Recommended | Experimental | Evolving
> - **Complexity**: Simple | Intermediate | Advanced
> - **Applicability**: [project-a] Service | General | Specific Domain
