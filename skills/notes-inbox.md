---
name: notes-inbox
description: Drain the Obsidian inbox folder — parse, classify, detect effects, route notes to their destination, and notify. Triggered by schedule (2-3x/day) or "check my inbox" / "process my notes".
requires: []   # optional: ["MCP:obsidian"] for vault-aware read/write/search
profiles: [personal]
---

# notes-inbox

## When to use

A scheduled run (2–3x daily) or an explicit "check my inbox", "process my
notes", "anything in the inbox?". This skill drains `inbox/` in the Obsidian
vault, classifying and routing each note — its default outcome (empty inbox)
is silence.

## Inputs

- The inbox folder: `<vault>/inbox/` (resolve vault path from
  `config/notes.yaml` → `vault_path`).
- `data/goals/goals.md` — for effect detection against goal targets/cadences.
- `memory/learned.md` — for contradiction detection against known decisions.
- Copilot Money MCP (optional) — for finance-related effect detection.

## Steps

### 0. Scan inbox

List files in `<vault>/inbox/`. Ignore dotfiles, `.gitkeep`, and any
file named `README.md`. If the folder is empty or doesn't exist, stop
silently — no notification, no log entry.

### 1. Process each note

For each `.md` file in the inbox:

#### 1a. Parse

Read frontmatter + body. Expected frontmatter (only `kind` required):

```yaml
---
kind: meeting | idea | decision | goal | journal | task
# optional:
project: capataz | recikeeper | personal | ...
people: [name1, name2]
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```

If `kind` is missing, infer it from body content. If `date` is missing,
use the file's creation date or today.

#### 1b. Classify → determine destination

| Kind | Destination |
|------|-------------|
| idea | `<vault>/ideas/` (rename to `YYYY-MM-DD-<slug>.md`) |
| goal | `<vault>/goals/` (rename to `YYYY-QN-<slug>.md` or `YYYY-MM-DD-<slug>.md`) |
| reflection / journal | `<vault>/reflections/` (rename to `YYYY-MM-DD-<slug>.md`) |
| decision | `project/decisions/` if `project: capataz`, else `<vault>/ideas/` with a `decision` tag |
| meeting | `<vault>/ideas/` (with `meeting` tag — no dedicated meetings folder yet) |
| task | Do not move — flag for interactive confirmation (tasks need a tracker target) |

If classification confidence is low (no `kind` field AND body is ambiguous):
- Do NOT move the note
- Add it to the "needs confirmation" list for the notification
- Skip remaining steps for this note

#### 1c. Detect effects

Scan the note body for:

- **Dates/deadlines**: any date or relative time reference ("by Friday",
  "due July 20"). Cross-reference against goal cadences and known
  commitments in `memory/learned.md`.
- **Decisions**: statements of choice or direction ("we decided", "going
  with", "switching to"). Check `memory/learned.md` for contradictions
  with existing facts.
- **Finance mentions**: dollar amounts, spending, budget references. If
  Copilot MCP is available, check against current budget status.
- **Goal-related**: mentions of fitness, nutrition, habits, or tracked
  goals. Check alignment with targets in `data/goals/goals.md`.

Effects found → add to the notification message. No effects → note routes
silently.

#### 1d. Route

If classification is confident:
1. Move the file to its destination (use Obsidian MCP `patch_file` to
   move, or filesystem `mv` as fallback). Rename per the convention in
   the table above.
2. Add appropriate frontmatter if missing: `type`, `status: seed`,
   `created: <date>`, `tags`.
3. Update `<vault>/index.md` — add the new note under the appropriate
   section, following existing format.

#### 1e. Log

Append one line per processed note to `memory/log.md`:
```
YYYY-MM-DD | notes-inbox | <original-filename> → <destination> | effects: <summary or "none">
```

### 2. Notify

After processing all notes, compose ONE notification (same as goal-notify
pattern):

- If notes were routed: "Inbox: routed 3 notes (2 ideas, 1 reflection)"
- If effects were found: append them: "— conflict: 'July 20 deadline'
  vs gym 5x/week cadence"
- If notes need confirmation: "— 1 note needs your input (ambiguous kind)"
- If nothing interesting happened (all routed cleanly, no effects): still
  send a brief confirmation so you know it ran: "Inbox: routed 2 notes,
  no conflicts"

Send via:
```bash
osascript -e 'display notification "<message>" with title "Capataz inbox"'
```

Keep under ~110 chars. Respect quiet hours (22:00–08:00). If inbox was
empty, send nothing.

### 3. Handle "needs confirmation" notes (interactive only)

When run interactively ("check my inbox"), for each ambiguous note:
- Present the note title and a one-line summary
- State your best-guess classification and ask the user to confirm or
  correct
- On confirmation, route normally (step 1d)
- On correction, route with the user's classification

When run from a schedule, ambiguous notes stay in inbox and are flagged
in the notification — they'll be handled next interactive session.

## Output / report-back

- Notes moved from `inbox/` to their destinations
- `<vault>/index.md` updated
- `memory/log.md` appended
- At most one macOS notification per run
- Interactive: conversational confirmation for ambiguous notes

## Safety

- **Never modify note content** beyond adding/completing frontmatter
  fields during routing.
- **Never execute work** — no ticket creation, no coding handoffs, no
  memory/learned.md writes. Only log to `memory/log.md` and route files.
  Suggested actions (draft tickets, handoffs) are mentioned in the
  notification for the user to initiate.
- **Never route to tracked/committed capataz repo files** — only to
  gitignored paths (`memory/log.md`) and the vault (which is outside
  the repo).
- Exception: `project/decisions/` for `kind: decision, project: capataz`
  notes — these are meant to be committed and reviewed.
- Write only to: `<vault>/` (move/rename), `memory/log.md` (append),
  `<vault>/index.md` (update).
- `osascript` is used only for `display notification`.
- Copilot MCP usage is read-only.
- Quiet hours: same as goal-notify (22:00–08:00, from
  `data/goals/goals.md` notification settings).
