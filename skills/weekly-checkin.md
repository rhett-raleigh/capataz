---
name: weekly-checkin
description: Run a start-of-week or mid-week check-in against the quarter plan.
requires: []
profiles: [work]
---

# weekly-checkin

## When to use
At the start or middle of each week during an active quarter. Reviews progress
against the plan, updates state, and sets goals for the coming week via the
goal-setter specialist.

## Inputs
- Current quarter state (`data/quarters/<QTR>/state.md`).
- Work breakdown artifacts (`data/quarters/<QTR>/breakdown/*.md`).
- Previous week's goals (`data/quarters/<QTR>/weekly/week-<N>.md`), if any.

## Steps
1. **Load current state.** Read `state.md` and the most recent
   `weekly/week-<N>.md` from `data/quarters/<QTR>/`. Identify the current week
   number and phase.
2. **Review last week.** Walk through last week's goals with the user:
   - Which goals were completed?
   - Which are carrying over?
   - Any blockers or surprises?
   Record the answers.
3. **Update breakdown artifacts.** Mark completed stories/tasks in the relevant
   `breakdown/*.md` files. Update status fields (e.g. `planned` → `done`,
   `in-progress` → `blocked`).
4. **Compile goal-setter brief.** Prepare a structured brief for the goal-setter
   specialist:
   - Week number and date range
   - Remaining capacity (from state)
   - Breakdown status summary (how many stories done / remaining per initiative)
   - Blockers and carryover items
   - Any user-flagged focus areas
5. **Dispatch goal-setter.** Hand the brief to the goal-setter specialist agent.
   Receive proposed goals back.
6. **Present and adjust.** Show the proposed goals to the user. Adjust based on
   their feedback — add, remove, or reprioritize goals until they're satisfied.
7. **Write weekly doc.** Save the finalized goals to
   `data/quarters/<QTR>/weekly/week-<N+1>.md`.
8. **Update state.** Update `state.md` with current progress, phase, and any
   flag changes.

## Output / report-back
Weekly goals doc at `data/quarters/<QTR>/weekly/week-<N+1>.md` and an updated
`state.md`. Summary of progress and goals presented to the user.

## Safety
- All check-in data, goals, and progress notes stay in gitignored `data/`.
- Don't skip the user review step (step 6) — the user always approves weekly
  goals before they're written.
- If state files are missing or corrupted, stop and ask rather than guessing.
