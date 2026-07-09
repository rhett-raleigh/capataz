---
name: habit-import
description: Import a Habit Grid CSV export (date,habit_name,completed) into the goals log. Triggered by "import my habits" plus a CSV path.
requires: []
profiles: [personal]
---

# habit-import

## When to use
The user exported habit data as CSV (from Habit Grid or anything matching the
format) and wants it logged: "import my habits from ~/Downloads/habits.csv".

## Inputs
- Path to a CSV in the format documented in `data/goals/habit-import-format.md`:
  `date,habit_name,completed`, one row per habit per day.
- `data/goals/goals.md` — to map habit names to goals under `## Habits`.

## Steps

### 0. Validate
- Read the CSV. Tolerate a missing header row and the `completed` variants
  listed in `habit-import-format.md` (`true/false`, `1/0`, `yes/no`, `✅/❌`).
- Rows with unparseable dates or missing fields: skip and report them at the
  end — don't abort the whole import for one bad row.

### 1. Map habits to goals
Match `habit_name` case-insensitively/fuzzily against goals under `## Habits`
in `goals.md`. Unmatched habits still get imported under their CSV name; list
them in the report as candidates for a new goal entry.

### 2. Write to the goals log
For each date in the CSV, append/update in the right `data/goals/log/YYYY-MM.md`
under that day's `## YYYY-MM-DD` heading:

```markdown
- **Habits** (imported): Reading ✅, Meditation ❌
```

One bundled habits line per day. **Dedupe:** if an imported habits line already
exists for that day, merge into it (new habit → append; same habit → the CSV
value wins). Never touch manually logged bullets. Keep day headings in
chronological order.

### 3. Report
Summarize: date range, habits seen, per-habit completion rate for the imported
window, current streaks where computable, unmatched habit names, and skipped
rows if any.

## Output / report-back
Per-day habit entries in `data/goals/log/YYYY-MM.md` files and a short import
report.

## Safety
- Write only to `data/goals/` (gitignored).
- Read-only with respect to the CSV; never modify or delete the user's export.
- Re-imports are idempotent — merging, never duplicating.
