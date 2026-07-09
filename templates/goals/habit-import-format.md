# Habit Grid CSV import format

The `habit-import` skill reads a CSV you export from Habit Grid (or produce by
hand / any other habit app). Expected format:

```csv
date,habit_name,completed
2026-07-01,Reading,true
2026-07-01,Meditation,false
2026-07-02,Reading,true
```

**Rules:**
- One row per habit per day.
- `date` — ISO format `YYYY-MM-DD`.
- `habit_name` — free text; ideally matches a goal name under `## Habits` in
  `goals.md` so streaks line up (matching is case-insensitive and fuzzy).
- `completed` — `true`/`false` (also accepted: `1`/`0`, `yes`/`no`, `✅`/`❌`).
- A header row is expected but the import tolerates its absence.
- Days with no row for a habit are treated as "no data", not as a miss.

Save the file anywhere and tell capataz: *"import my habits from ~/Downloads/habits.csv"*.
Re-importing the same date range is safe — existing imported entries for a
date+habit are updated, not duplicated.
