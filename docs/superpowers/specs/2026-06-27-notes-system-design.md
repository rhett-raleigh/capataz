# Notes System Design

A memory and recall system for capataz that lets users capture ideas, track
goals, and do structured reflections — all stored as markdown files in a
configurable vault directory.

---

## Architecture: Approach C — Orchestrating skill + capability layer

One `notes` skill is the user-facing entry point. It classifies intent (idea vs.
reflection vs. goal) and runs the appropriate conversational flow. A `notes`
capability handles storage, retrieval, cross-linking, and Obsidian integration.

This mirrors capataz's existing pattern: classify routes, skills handle flows,
capabilities do the plumbing.

---

## Vault structure

```
notes/                            ← default: data/notes/, configurable
├── ideas/
│   └── 2026-06-27-app-for-tracking-habits.md
├── reflections/
│   └── 2026-06-27-week-26.md
├── goals/
│   └── 2026-q3-ship-side-project.md
└── index.md                      ← auto-maintained table of contents
```

Each note uses YAML frontmatter:

```yaml
---
type: idea | reflection | goal
status: seed | refined | active | completed | archived
created: 2026-06-27
tags: [productivity, side-project]
linked_goals: [2026-q3-ship-side-project]
---
```

### Status values by type

- **Ideas:** `seed` → `refined` → `active` (being pursued) → `completed` | `archived`
- **Goals:** `active` → `completed` | `archived`
- **Reflections:** no status lifecycle (they're snapshots in time)

---

## Configuration

Lives in `config/notes.yaml`:

```yaml
vault_path: data/notes           # absolute or relative to repo root
obsidian_vault: null              # Obsidian vault name; enables obsidian:// URIs
default_tags: []                  # tags applied to all new notes
```

A template at `templates/notes/` provides a ready-to-copy scaffold:
- Directory structure (`ideas/`, `reflections/`, `goals/`)
- Starter `config/notes.yaml`
- Empty `index.md`

---

## Skill: `notes` (user-facing)

File: `skills/notes.md`

### Triggers

- "log an idea", "I had a thought about..."
- "let's do a reflection", "weekly reflection"
- "add a goal", "update my goals"
- "what ideas have I logged?", "show me my goals"
- "open my notes", "open my reflection from last week"

### Three modes

#### Quick-log (fast capture)

- User says "log an idea: habit tracker app"
- Agent writes the file immediately with `status: seed`
- Confirms and offers to open in Obsidian

#### Guided refinement (push thinking)

- User says "I have an idea I want to think through"
- Agent asks questions one at a time:
  - What's the idea?
  - What problem does it solve?
  - What would success look like?
  - Any constraints or dependencies?
- Writes the refined note with `status: refined`

#### Coached reflection (structured weekly review)

- User says "let's do a weekly reflection"
- Agent loads goals and ideas from the current period
- Walks through sections one at a time:
  1. **What happened this week** — key events, accomplishments, surprises
  2. **Strengths** — what went well, with follow-ups ("what made that a strength?")
  3. **Areas of opportunity** — what could improve, with follow-ups ("what would you do differently?")
- Connects observations back to goals and ideas:
  - "You made progress on goal X"
  - "This idea from Tuesday relates to goal Y"
- Writes the reflection file with `linked_goals` references

### Recall & organization

- "What ideas have I logged?" → scan vault, summarize by status/tag
- "Show me my goals" → list goals with status
- "Open my reflection from last week" → open in Obsidian

---

## Capability: `notes` (plumbing)

File: `capabilities/notes.md`

### Responsibilities

- **Storage** — read/write/list notes in the configured vault path, manage
  frontmatter, auto-update `index.md`
- **Cross-linking** — resolve `linked_goals` references, find related notes by
  tag or date
- **Obsidian integration** — open notes via `obsidian://open?vault=...&file=...`
  when vault name is configured, fall back to `open <path>`
- **Period queries** — date-range filtering on frontmatter for "this week's
  ideas", "goals created in Q3", etc.

### Index maintenance

`index.md` is auto-updated when notes are created or modified. It groups entries
by type and shows status, date, and title. This makes the vault browsable in
Obsidian's file explorer without needing plugins.

---

## Templates

`templates/notes/` contains:

```
templates/notes/
├── config/
│   └── notes.yaml               ← starter config, copy to config/
├── vault/
│   ├── ideas/
│   │   └── .gitkeep
│   ├── reflections/
│   │   └── .gitkeep
│   ├── goals/
│   │   └── .gitkeep
│   └── index.md                  ← empty starter index
└── README.md                     ← setup instructions
```

Users copy the scaffold to get started. If they already have an Obsidian vault,
they point `vault_path` at it and the agent writes into the existing structure.

---

## Integration with existing systems

- **Classify capability** — the `note` lane in `classify.md` already routes to
  `data/`. This system gives that lane a proper destination and structured flows.
- **Memory model** — this is distinct from `memory/learned.md` and
  `memory/log.md`. Those are agent self-knowledge. This is user-facing content.
- **AGENTS.md** — add `notes` to the skill index (§7) and capability index (§8).

---

## Privacy

All note content lives in the configured vault path. If the default
(`data/notes/`) is used, it's already gitignored. If pointed at an external
directory, the user controls its visibility. The skill and capability files
(tracked) contain no personal content — only generic instructions.
