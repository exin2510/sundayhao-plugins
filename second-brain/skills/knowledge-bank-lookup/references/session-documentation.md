# Session Documentation Process

Guidelines for documenting work sessions in the knowledge bank.

## When to Document

Trigger documentation at the end of significant work sessions when:
- 3+ files modified
- Complex problems solved
- New patterns discovered
- User says "recap the session"

## Documentation Process

### Step 1: Read the Session Documentation Rule

```bash
cat {KB_PATH}/rules/session-documentation-and-knowledge-extraction.md
```

(Replace `{KB_PATH}` with your knowledge bank path - see Configuration section in SKILL.md)

This rule contains the official guidelines for documentation structure and requirements.

### Step 2: Required Documentation Types

Create documentation in the appropriate project directory:

- **Daily Session Log**: `/daily-log/YYYY-MM-DD [Topic].md` (for tracking only, NOT included in lookups)
- **Concept Docs** (if new patterns): `/knowledge-bank/projects/{service}/concepts/[Name].md`
- **Component Docs** (if new components): `/knowledge-bank/projects/{service}/components/[Name].md`
- **Best Practices** (if reusable): `/knowledge-bank/projects/{service}/best-practices/[Name].md`
- **Reflections** (process insights): `/knowledge-bank/reflections/YYYY-MM-DD [Topic].md`

### Step 3: Cross-Reference Requirements

Use `[[WikiLink]]` syntax for Obsidian compatibility:
- Link to related concepts, components, best practices
- Update relevant MOCs in `_index/`
- Target: 10-15 cross-references per technical document (concepts/components/best-practices)
- Target: 5-8 cross-references per reflection document

### Step 4: Pre-Documentation Discovery

Before writing documentation, use knowledge bank lookup to discover existing related documentation for proper cross-referencing.

This ensures:
- No duplicate documentation
- Proper connections to existing knowledge
- Consistent terminology
- Complete cross-reference network

### Step 5: Create Documentation in Correct Project

Route documentation to the appropriate service:

- **[project-a] work** → `projects/[project-a]/` (concepts, components, best-practices)
- **[project-b] work** → `projects/[project-b]/` (concepts, components, best-practices)
- **CC work** → `projects/cc/` (concepts, components, best-practices)
- **[project-c] work** → `projects/[project-c]/` (concepts, components, best-practices)
- **Migration patterns** → Reference Migration MOC in cross-references
- **Daily logs** → `/daily-log/` (for tracking only, excluded from lookups)
- **Process reflections** → `/reflections/` (workflow insights, DX lessons)

## Document Structure

### Concepts
Architectural patterns and design principles:
- Problem statement
- Solution approach
- When to apply
- Trade-offs
- Related concepts (10-15 cross-references)
- Examples

### Components
Specific implementations:
- Purpose and responsibilities
- Architecture overview
- Usage examples
- Configuration
- Testing approach
- Related components (10-15 cross-references)

### Best Practices
Reusable methodologies:
- Context (when to apply)
- The practice itself
- Key principles
- Examples
- Anti-patterns to avoid
- Related practices (10-15 cross-references)

### Reflections
Process insights (new in v2.1.0):
- What worked well?
- What didn't work well?
- What failed?
- What could be improved?
- What would make it seamless?
- Related sessions (5-8 cross-references)

## Documentation Quality Guidelines

1. **Be Specific**: Avoid vague descriptions, include concrete examples
2. **Show Code**: Include relevant snippets when applicable
3. **Explain Why**: Document rationale, not just what
4. **Cross-Reference Heavily**: 10-15 links for technical docs, 5-8 for reflections
5. **Update MOCs**: Keep Maps of Content current
6. **Use Consistent Naming**: Follow existing patterns
7. **Include Metadata**: Date, author, related work
