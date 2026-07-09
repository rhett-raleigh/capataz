---
name: goal-review
description: Weekly or monthly structured goals reflection — streaks, gaps, patterns, 2-3 coached questions, and promotion of durable insights to memory. Triggered by "goals review", "weekly goals reflection", "how did my month go".
requires: []
profiles: [personal]
---

# goal-review

## When to use
The user asks for a structured look back at their goals: "goals review", "how
did this week/month go", "monthly reflection on my goals". Heavier than
`goal-checkin` (which logs a single update); this reads the history and coaches.

## Inputs
- Scope: weekly (default) or monthly, or explicit date range.
- `data/goals/goals.md` — goals, targets, cadences.
- `data/goals/log/` — the current month's log, plus the previous month's when
  the window spans a month boundary or for streak context.

## Steps

### 0. Prepare
- Read `data/goals/goals.md`. If missing/empty, there's nothing to review —
  offer to set up goals instead.
- Read the tail of the relevant `data/goals/log/YYYY-MM.md` file(s). If no log
  entries exist in the window, say so plainly and ask whether the gap is a
  logging problem or a doing problem — then stop (that's the review).

### 1. Compute the picture (per active goal)
- **Streak**: consecutive periods (days or weeks, per the goal's cadence) with
  a ✅ or substantive entry. Count from the log; don't guess.
- **Cadence adherence**: entries in window vs. expected from cadence
  (e.g. "2 of 3 gym sessions").
- **Gaps**: no entry in > 2× cadence → flag explicitly.
- **Patterns**: anything visible across entries — misses cluster on certain
  days, quality trending up/down, finance numbers drifting toward the cap.
  Only report patterns actually supported by the entries.
- Paused goals: mention in one line, don't analyze.

### 2. Present the review
Short structured summary: one block per goal — streak, adherence, one-line
trend. Lead with what's working, be direct about what isn't. No filler praise.

### 3. Ask 2–3 targeted questions
Pick the highest-leverage ones from what the data shows, e.g.:
- A recurring miss: "Gym has dropped every Friday for three weeks — is Friday
  the wrong day, or is it the week catching up with you?"
- A drifting target: "You've been ~300 kcal over the target most days — is the
  target wrong or the eating?"
- A win worth understanding: "Reading streak is at 21 — what's making it stick?"
Wait for answers; incorporate them into the wrap-up.

### 4. Record
- Append a `### Review (weekly|monthly) — YYYY-MM-DD` block to the current
  month's log with the summary and the user's answers, so future reviews can
  read past ones.

### 5. Promote durable insights to memory
If the review surfaced something durable — a stable pattern, a decided target
change, a working strategy — add it to `memory/learned.md` under the
`## Goals` section (create the section if needed): one fact per bullet with a
short **why**, following the existing file's style. Deduplicate against what's
already there; update or delete stale facts rather than stacking new ones.
Session-specific noise does not get promoted.

## Output / report-back
A conversational review with streaks/gaps/patterns and 2–3 questions; a review
block appended to `data/goals/log/YYYY-MM.md`; zero or more curated entries in
`memory/learned.md` `## Goals`.

## Safety
- Write only to `data/goals/` and `memory/learned.md` (both gitignored).
- Streaks and stats come from the log, never from memory or vibes — if the log
  is ambiguous, say so rather than inventing a number.
- Coach, don't moralize: flag gaps as information, not failure.
