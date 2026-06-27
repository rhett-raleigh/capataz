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
