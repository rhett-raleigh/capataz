---
name: goal-checkin
description: Conversational goal check-in — log workouts, meals, spending, habits, or any goal progress to the monthly goals log. Triggered by "log my workout", "goals check-in", "gym: ✅", or any "log <fitness/nutrition/finance/habit thing>".
requires: []        # optional: ["MCP:copilot"] for real spending data
profiles: [personal]
---

# goal-checkin

## When to use
The input logs progress (or a miss) against a personal goal: "log my workout",
"goals check-in", "gym: ✅", "I skipped the gym today", "log dinner: 800 kcal",
"how am I doing on spending — log it". Both quick one-liners and detailed
narrative updates. For structured weekly/monthly reflection use `goal-review`
instead; for bulk data use `health-import` / `habit-import`.

## Inputs
- The user's update — quick (`gym: ✅`) or detailed (free text).
- `data/goals/goals.md` — read for context: which goals exist, targets, cadence.
- Optionally: a date if the update is for a past day (defaults to today).

## Steps

### 0. Prepare
- Read `data/goals/goals.md`. If it doesn't exist or is still all template
  placeholders, say so and offer to fill it in together before logging.
- Set `DATE` to today (or the date the user names — "yesterday's run" → yesterday).
- The log file is `data/goals/log/YYYY-MM.md` for `DATE`'s month. Create it with
  a `# Goals Log — YYYY-MM` header if it doesn't exist.

### 1. Interpret the update
- Match the update to a goal in `goals.md` (fuzzy: "gym", "lifted", "workout"
  all → the Fitness/Gym goal). If it doesn't match any goal, log it anyway
  under the closest category and note it might deserve its own goal entry.
- Quick format (`gym: ✅`, `reading: ❌`): log as-is, no interrogation.
- Detailed format: capture the substance in one or two lines — what, how much,
  how it felt. Don't pad.
- Misses are logged too (`❌` with optional reason) — gaps are data.

### 2. Finance updates — pull real data if possible
If the update concerns a Finance goal and the Copilot Money MCP is available
(`mcp__copilot__*` tools), query it for actual figures (month-to-date spending
in the relevant category, budget status) instead of relying on the user's
recollection, and log the real numbers. If the MCP is unavailable, log what the
user reports and note: "(self-reported — Copilot MCP not configured)".

### 3. Append to the log
Append under a `## YYYY-MM-DD` heading (create it if today has no entries yet;
keep day headings in chronological order):

```markdown
## 2026-07-08

- **Fitness / Gym**: ✅ Upper body, 50 min. Bench felt heavy but finished all sets.
- **Finance / Spending**: Dining out $184 of $300 for July (via Copilot).
```

One bullet per update, `**Category / Goal**:` prefix, human-readable — someone
opening the file cold should understand it.

### 4. Confirm with context
Reply with a one-line confirmation plus light context when it's cheap to
compute from the current month's log: current streak, or how this update sits
against the goal's cadence ("that's 3 gym sessions this week — target met").
Don't lecture; one line.

## Output / report-back
An appended entry in `data/goals/log/YYYY-MM.md` and a short conversational
confirmation with streak/cadence context.

## Safety
- Write only to `data/goals/` (gitignored). Never copy goal content into
  tracked files.
- Copilot MCP usage is read-only — never move money, pay bills, or modify
  transactions/budgets.
- Never invent numbers: if data isn't available, say so and log what the user
  gave you.
