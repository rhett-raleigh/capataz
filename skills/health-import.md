---
name: health-import
description: Parse an Apple Health XML export (from the iOS Health app) — nutrition, workouts, weight — and write daily summaries to the goals log. Triggered by "import my health data" plus a file path.
requires: []
profiles: [personal]
---

# health-import

## When to use
The user exported their data from the iOS Health app (Health → profile →
"Export All Health Data") and wants it in the goals log: "import my health
data", "here's my health export: ~/Downloads/export.zip". MacroFactor
nutrition data arrives through this same path (MacroFactor syncs to Apple
Health).

## Inputs
- Path to the export: `export.xml`, or `export.zip` / an `apple_health_export/`
  directory containing it.
- Optional date range. Default: since the last import (see step 3), else the
  last 30 days.
- `data/goals/goals.md` — to know which metrics map to which goals.

## Steps

### 0. Locate and size up the file
- If given a zip, unzip to a scratch directory; the target is `export.xml`
  inside `apple_health_export/`.
- **The XML is often hundreds of MB. Never read it whole into context.**
  Extract with streaming shell tools (`grep`/`awk`/`sed` over the relevant
  record lines) and only look at aggregated results.

### 1. Extract the relevant records
Each record is a single `<Record .../>` or `<Workout .../>` element with
`startDate` and `value` attributes. Pull only:

| Data | XML type attribute |
|------|--------------------|
| Calories eaten | `HKQuantityTypeIdentifierDietaryEnergyConsumed` |
| Protein (g) | `HKQuantityTypeIdentifierDietaryProtein` |
| Carbs (g) | `HKQuantityTypeIdentifierDietaryCarbohydrates` |
| Fat (g) | `HKQuantityTypeIdentifierDietaryFatTotal` |
| Workouts | `<Workout workoutActivityType="..." duration="...">` |
| Weight | `HKQuantityTypeIdentifierBodyMass` |

Filter to the requested date range early to keep the working set small.

### 2. Aggregate per day
- Nutrition: sum each metric per calendar day (entries are per-meal/per-item).
- Workouts: one line per workout — type (humanized: `HKWorkoutActivityType
  TraditionalStrengthTraining` → "Strength training"), duration in minutes.
- Weight: last reading of the day.
- Round sensibly (whole kcal/grams/minutes, one decimal for weight).

### 3. Write to the goals log
For each day with data, append/update in the right `data/goals/log/YYYY-MM.md`
under that day's `## YYYY-MM-DD` heading, marked as imported:

```markdown
- **Nutrition** (imported from Apple Health): 2,150 kcal, 162g protein, 210g carbs, 71g fat
- **Fitness / workout** (imported from Apple Health): Strength training, 48 min
- **Weight** (imported from Apple Health): 176.2 lb
```

**Dedupe:** if an "(imported from Apple Health)" line of the same kind already
exists for that day, replace it (re-exports overlap). Never touch manually
logged bullets. Keep day headings in chronological order.

### 4. Report
Summarize: date range covered, days with nutrition data, workout count, weight
entries, and anything notably aligned or misaligned with the targets in
`goals.md` (one or two lines, not a full review — point to `goal-review` for
that). Note the last imported date so the next run can default its range.
Clean up any scratch extraction.

## Output / report-back
Daily summary entries in `data/goals/log/YYYY-MM.md` files and a short import
report.

## Safety
- Health data is sensitive: write only to `data/goals/` (gitignored); never
  quote it into tracked files, commits, or external services.
- Delete scratch copies of the export after import.
- Read-only with respect to the export file itself.
