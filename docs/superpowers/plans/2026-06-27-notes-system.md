# Notes System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a memory/recall system to capataz for capturing ideas, tracking goals, and doing structured reflections — stored as markdown in a configurable vault directory.

**Architecture:** Single `notes` skill as the user-facing entry point, backed by a `notes` capability for storage/retrieval/Obsidian integration. A template scaffold lets users bootstrap the vault. All files are Markdown — no application code.

**Tech Stack:** Markdown files, YAML frontmatter, shell commands (Obsidian URI scheme, `open`)

## Global Constraints

- No application code — this is a Markdown-driven system. Only `bin/` and `hooks/` contain shell scripts.
- Personal/private content never goes in tracked files. Skill and capability files are generic instructions only.
- Follow existing file conventions: skills use `_template.skill.md` format, capabilities match `classify.md` / `code-handoff.md` style.
- Templates go in `templates/notes/` and are meant to be copied, not used in-place.

---

### Task 1: Notes capability

**Files:**
- Create: `capabilities/notes.md`

**Interfaces:**
- Consumes: nothing (foundational building block)
- Produces: the reusable storage/retrieval/Obsidian interface that `skills/notes.md` (Task 2) references

- [ ] **Step 1: Write `capabilities/notes.md`**

```markdown
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

​```yaml
---
type: idea | reflection | goal
status: seed | refined | active | completed | archived
created: YYYY-MM-DD
tags: [tag1, tag2]
linked_goals: [goal-filename-slug]
---
​```

### Status values by type

- **Ideas:** `seed` → `refined` → `active` → `completed` | `archived`
- **Goals:** `active` → `completed` | `archived`
- **Reflections:** no status lifecycle (point-in-time snapshots)

## Directory layout

​```
<vault_path>/
├── ideas/
├── reflections/
├── goals/
└── index.md
​```

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

​```markdown
# Notes Index

## Goals
- [Ship side project](goals/2026-q3-ship-side-project.md) — active

## Ideas
- [Habit tracker app](ideas/2026-06-27-app-for-tracking-habits.md) — seed
- [Budget automation](ideas/2026-06-25-budget-automation.md) — refined

## Reflections
- [Week 26](reflections/2026-06-27-week-26.md)
- [Week 25](reflections/2026-06-20-week-25.md)
​```

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
```

- [ ] **Step 2: Verify the file parses correctly and follows capability conventions**

Run: review the file structure against `capabilities/classify.md` and
`capabilities/code-handoff.md` — confirm it has the same section pattern
(Goal/Purpose → How → Steps/Operations → Safety).

- [ ] **Step 3: Commit**

```bash
git add capabilities/notes.md
git commit -m "feat: add notes capability for vault storage and retrieval"
```

---

### Task 2: Notes skill

**Files:**
- Create: `skills/notes.md`

**Interfaces:**
- Consumes: `capabilities/notes.md` (Task 1) for all storage/retrieval operations
- Produces: the user-facing skill that AGENTS.md (Task 4) indexes

- [ ] **Step 1: Write `skills/notes.md`**

```markdown
---
name: notes
description: Capture ideas, track goals, and run structured reflections — stored as markdown in a configurable vault.
requires: ["config:notes"]
profiles: []
---

# notes

## When to use

The user wants to log an idea, think through a concept, set or review goals, do
a weekly reflection, browse their notes, or open a note in Obsidian. Anything
that is personal memory/recall content rather than a tracked task or engineering
work.

## Inputs

- Free text: an idea, a goal, a request to reflect, or a query about existing
  notes.
- Optional: explicit mode hint ("quick log", "let's think this through", "weekly
  reflection").

## Steps

### 1. Resolve configuration

Read `config/notes.yaml` (or `config/notes.md`) using `capabilities/notes.md`.
If missing, tell the user to copy the template from `templates/notes/` and stop.

### 2. Classify the intent

| Signal | Mode |
|--------|------|
| "log an idea", "quick note", "remember this", short imperative | **Quick-log** |
| "I have an idea I want to think through", "let's brainstorm", exploratory tone | **Guided refinement** |
| "weekly reflection", "let's reflect", "how did my week go" | **Coached reflection** |
| "add a goal", "new goal", "I want to accomplish" | **Goal creation** |
| "what ideas have I logged?", "show my goals", "open my notes" | **Recall** |
| "update goal X", "mark idea Y as active" | **Update** |

If ambiguous, ask one short clarifying question.

### 3a. Quick-log (fast capture)

1. Extract the core idea from the user's message.
2. Write a note via `capabilities/notes.md` with `type: idea`, `status: seed`,
   today's date, and any obvious tags.
3. Confirm: "Logged to `<filename>`. Want to open it in Obsidian?"
4. Append to `memory/log.md`.

### 3b. Guided refinement

1. Acknowledge the idea. Ask: **"What's the core idea?"** (if not already clear).
2. Ask one question at a time, waiting for each answer:
   - "What problem does this solve?"
   - "What would success look like?"
   - "Any constraints or dependencies?"
3. Summarize the refined idea back to the user for confirmation.
4. Write the note via `capabilities/notes.md` with `type: idea`,
   `status: refined`, and the full refined content.
5. Offer to open in Obsidian.
6. Append to `memory/log.md`.

### 3c. Coached reflection

1. Determine the reflection period (default: current week).
2. Load recent context via `capabilities/notes.md`:
   - Goals with `status: active`
   - Ideas created during the period
   - Previous reflection (if any) for continuity
3. Share what you found: "You have N active goals and logged M ideas this week.
   Let's reflect."
4. Walk through sections one at a time:
   - **What happened this week** — ask the user to share, follow up on
     interesting points.
   - **Strengths** — "What went well?" then "What made that a strength?"
   - **Areas of opportunity** — "What could improve?" then "What would you do
     differently?"
5. After each section, connect back to goals/ideas where relevant:
   - "That sounds like progress on [goal X]."
   - "Your idea from [date] about [topic] relates to this."
6. Summarize the full reflection, ask for confirmation.
7. Write via `capabilities/notes.md` with `type: reflection`, `linked_goals`
   for any referenced goals, and the structured content.
8. Offer to open in Obsidian.
9. Append to `memory/log.md`.

### 3d. Goal creation

1. Ask: **"What do you want to accomplish?"** (if not already clear).
2. Ask: **"By when?"** and **"How will you know you've succeeded?"**
3. Write via `capabilities/notes.md` with `type: goal`, `status: active`.
4. Offer to open in Obsidian.
5. Append to `memory/log.md`.

### 3e. Recall

1. Parse the query (type filter, date range, status, tag, specific note).
2. Use `capabilities/notes.md` to list/read matching notes.
3. Present a summary: title, status, date, tags for each match.
4. Offer to open any note in Obsidian.

### 3f. Update

1. Identify the target note (by name, slug, or description).
2. Confirm the change with the user.
3. Update via `capabilities/notes.md`.
4. Append to `memory/log.md`.

## Output / report-back

- For writes: the filename and an offer to open in Obsidian.
- For reads: a formatted summary of matching notes.
- All writes are logged to `memory/log.md`.

## Safety

- All note content goes to the configured `vault_path` (gitignored by default).
  Never write note content into tracked files.
- Don't delete notes without explicit confirmation.
- If config is missing, stop and direct to the template — don't guess paths.
- One question at a time during guided flows. Don't overwhelm.
```

- [ ] **Step 2: Verify the file follows skill conventions**

Run: review against `skills/_template.skill.md` — confirm frontmatter has
`name`, `description`, `requires`, `profiles`, and the body has `When to use`,
`Inputs`, `Steps`, `Output / report-back`, `Safety`.

- [ ] **Step 3: Commit**

```bash
git add skills/notes.md
git commit -m "feat: add notes skill for ideas, goals, and reflections"
```

---

### Task 3: Vault template scaffold

**Files:**
- Create: `templates/notes/README.md`
- Create: `templates/notes/config/notes.example.yaml`
- Create: `templates/notes/vault/ideas/.gitkeep`
- Create: `templates/notes/vault/reflections/.gitkeep`
- Create: `templates/notes/vault/goals/.gitkeep`
- Create: `templates/notes/vault/index.md`

**Interfaces:**
- Consumes: nothing
- Produces: the template scaffold that `capabilities/notes.md` (Task 1) directs users to copy

- [ ] **Step 1: Create `templates/notes/config/notes.example.yaml`**

```yaml
# Notes configuration (LOCAL — copy to config/notes.yaml, never commit)
#
# vault_path: where notes are stored. Absolute path or relative to repo root.
#   Default: data/notes
#   To use an existing Obsidian vault: /path/to/your/vault
#
# obsidian_vault: your Obsidian vault name (as shown in Obsidian's vault switcher).
#   When set, "open in Obsidian" uses the obsidian:// URI scheme.
#   When null, falls back to `open <file-path>`.
#
# default_tags: tags applied to every new note automatically.

vault_path: data/notes
obsidian_vault: null
default_tags: []
```

- [ ] **Step 2: Create `templates/notes/vault/index.md`**

```markdown
# Notes Index

<!-- Auto-maintained by the notes capability. Manual edits will be overwritten. -->

## Goals

_No goals yet. Try: "add a goal"_

## Ideas

_No ideas yet. Try: "log an idea"_

## Reflections

_No reflections yet. Try: "let's do a weekly reflection"_
```

- [ ] **Step 3: Create `.gitkeep` files for subdirectories**

```bash
mkdir -p templates/notes/vault/ideas templates/notes/vault/reflections templates/notes/vault/goals
touch templates/notes/vault/ideas/.gitkeep
touch templates/notes/vault/reflections/.gitkeep
touch templates/notes/vault/goals/.gitkeep
```

- [ ] **Step 4: Create `templates/notes/README.md`**

```markdown
# Notes vault template

Quick-start scaffold for the notes system. Copy these files to set up your vault.

## Setup

1. Copy the config file and edit it:

   ```bash
   cp templates/notes/config/notes.example.yaml config/notes.yaml
   # Edit config/notes.yaml — set vault_path and optionally obsidian_vault
   ```

2. Bootstrap the vault directory:

   ```bash
   cp -r templates/notes/vault/ data/notes/
   ```

   Or, if you want to use an existing Obsidian vault, point `vault_path` in
   your config at it. The agent will create `ideas/`, `reflections/`, `goals/`
   subdirectories and an `index.md` inside it on first use.

3. Start using it:

   - "Log an idea: habit tracker app"
   - "I have an idea I want to think through"
   - "Add a goal: ship my side project by end of Q3"
   - "Let's do a weekly reflection"
   - "What ideas have I logged?"

## What's in this template

```
config/
  notes.example.yaml   ← copy to config/notes.yaml
vault/
  ideas/               ← idea notes go here
  reflections/         ← weekly reflections go here
  goals/               ← goal tracking notes go here
  index.md             ← auto-maintained table of contents
```
```

- [ ] **Step 5: Commit**

```bash
git add templates/notes/
git commit -m "feat: add vault template scaffold for notes system"
```

---

### Task 4: Update AGENTS.md indexes

**Files:**
- Modify: `AGENTS.md` — §7 Skill index, §8 Capabilities index

**Interfaces:**
- Consumes: `skills/notes.md` (Task 2), `capabilities/notes.md` (Task 1)
- Produces: updated indexes so the agent discovers the new skill/capability at startup

- [ ] **Step 1: Add `notes` to the Skill index in AGENTS.md §7**

Add this line after the existing skill entries:

```markdown
- `notes` — capture ideas (quick or guided), track goals, run coached weekly
  reflections, browse and open notes in Obsidian. See `skills/notes.md`.
```

- [ ] **Step 2: Add `notes` to the Capabilities index in AGENTS.md §8**

Add this line after the existing capability entries:

```markdown
- `notes` — vault storage, retrieval, cross-linking, index maintenance, and
  Obsidian integration for the notes skill. See `capabilities/notes.md`.
```

- [ ] **Step 3: Verify indexes match filenames**

Run: confirm `skills/notes.md` and `capabilities/notes.md` exist and the index
entries reference them correctly.

- [ ] **Step 4: Commit**

```bash
git add AGENTS.md
git commit -m "feat: add notes skill and capability to AGENTS.md indexes"
```

---

### Task 5: Update classify capability

**Files:**
- Modify: `capabilities/classify.md`

**Interfaces:**
- Consumes: `skills/notes.md` (Task 2) as the routing destination
- Produces: updated classification so the `note` lane routes to the notes skill

- [ ] **Step 1: Update the `note` lane in `capabilities/classify.md`**

Change the `note` lane's "Routes to" column from the current generic
"record in `data/`, no tracker, no code" to:

```markdown
| **note** | a goal, reflection, idea, reference, "remember that…" | invoke `skills/notes.md` to capture, refine, or reflect |
```

- [ ] **Step 2: Verify the table still parses correctly**

Ensure the three lanes (note, task, engineering) are all present and the
Markdown table is well-formed.

- [ ] **Step 3: Commit**

```bash
git add capabilities/classify.md
git commit -m "feat: route note lane to notes skill in classify capability"
```
