# Project knowledge

Living record of where this project has been, where it is, and where it's going.
This is the place for decisions, ideas, and work breakdowns.

```
project/
  decisions/   ← ADRs: why we chose X over Y (numbered, e.g. 000-…, 001-…)
  ideas/       ← rough captures, not yet committed to (descriptive filenames)
  projects/    ← work breakdowns for larger efforts (descriptive filenames)
```

Each folder has a `_template.md`. Copy it to start a new entry.

## Conventions

- **Decisions** are numbered (`000-…`, `001-…`). Use the next available number.
- **Ideas** and **projects** use descriptive filenames (`voice-md.md`).
- Statuses are freeform but each template suggests a set.
- Git history is the changelog — no need to maintain one separately.

## For agents

When the user shares an idea, decision, or plan about this project, write it
here using the appropriate template:

| Input signals | Target |
|---------------|--------|
| "I have an idea for…", "what if we…", rough concept | `ideas/` — copy `ideas/_template.md` |
| "Let's decide…", "we should use X because…", trade-off resolved | `decisions/` — next numbered file from `decisions/_template.md` |
| "Let's plan out…", "break down the work for…", multi-step effort | `projects/` — copy `projects/_template.md` |
