# Capability: notes

Handles storage, retrieval, cross-linking, and Obsidian integration for the
notes vault. Skills compose this capability — it is plumbing, not user-facing.

## Configuration

Read `config/notes.yaml` (or `config/notes.md`) to resolve:

| Key | Default | Purpose |
|-----|---------|---------|
| `vault_path` | `data/notes` | Root directory for all notes (absolute or relative to repo root) |
| `obsidian_vault` | `null` | Obsidian vault name; when set, enables `obsidian://` URIs |
| `default_tags` | `[]` | Tags applied to every new note |

If the config file does not exist, stop and tell the user to copy the template
from `templates/notes/`.

## Note format

Every note is a Markdown file with YAML frontmatter:

```yaml
---
type: idea | reflection | goal
status: seed | refined | active | completed | archived
created: YYYY-MM-DD
tags: [tag1, tag2]
linked_goals: [goal-filename-slug]
---
```

### Status values by type

- **Ideas:** `seed` → `refined` → `active` → `completed` | `archived`
- **Goals:** `active` → `completed` | `archived`
- **Reflections:** no status lifecycle (point-in-time snapshots)

## Directory layout

```
<vault_path>/
├── ideas/
├── reflections/
├── goals/
└── index.md
```

## Operations

### Write a note

1. Resolve `vault_path` from config.
2. Determine subdirectory from `type` (`ideas/`, `reflections/`, `goals/`).
3. Generate filename: `YYYY-MM-DD-<slugified-title>.md` for ideas/reflections,
   `YYYY-QN-<slugified-title>.md` for goals (or `YYYY-MM-DD-` if no quarter
   context).
4. Write the file with frontmatter + body content.
5. Update `index.md` (see below).
6. Append to `memory/log.md`: date, `note`, type, filename.

### Read / list notes

- List all notes of a type: scan the subdirectory, parse frontmatter, return
  sorted by date.
- Filter by status, tag, or date range.
- Read a specific note by filename or slug match.

### Update a note

- Modify frontmatter fields (status, tags, linked_goals) or body content.
- Update `index.md` after any change.

### Cross-linking

- `linked_goals` in frontmatter contains filename slugs (without extension) of
  goal files.
- To find all notes linked to a goal: scan ideas and reflections for matching
  `linked_goals` entries.
- To find related notes: match by shared tags.

### Period queries

- "This week's ideas" → filter ideas where `created` falls in the current
  ISO week.
- "Goals created in Q3" → filter goals where `created` falls in Jul–Sep.
- "Last week's reflection" → find the most recent reflection with `created`
  in the prior ISO week.

### Index maintenance

`index.md` is regenerated on each write/update. Format:

```markdown
# Notes Index

## Goals
- [Ship side project](goals/2026-q3-ship-side-project.md) — active

## Ideas
- [Habit tracker app](ideas/2026-06-27-app-for-tracking-habits.md) — seed
- [Budget automation](ideas/2026-06-25-budget-automation.md) — refined

## Reflections
- [Week 26](reflections/2026-06-27-week-26.md)
- [Week 25](reflections/2026-06-20-week-25.md)
```

### Open in Obsidian

1. If `obsidian_vault` is set in config, open via:
   `open "obsidian://open?vault=<vault_name>&file=<relative_path>"`
2. Otherwise, fall back to: `open <absolute_path_to_file>`
3. Always offer to open after creating or retrieving a note.

## Safety

- Never write personal content into this capability file — it contains only
  generic instructions.
- If `vault_path` does not exist, stop and ask rather than creating it silently.
- If config is missing, direct the user to the template.
