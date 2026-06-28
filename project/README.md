# Project knowledge

Living record of where this project has been, where it is, and where it's going.
This is the place for decisions, ideas, and work breakdowns about capataz itself.

For reference documentation on how the system works, see `docs/`.

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

## Portable template

To apply this pattern to another repo, copy `templates/project/` into it.
