---
name: quarter-retro
description: Guide a structured quarter retrospective — what shipped, what didn't, what to change.
requires: []
profiles: [work]
---

# quarter-retro

## When to use
Start of a new quarter when there's a previous quarter to reflect on. Typically
the first step before capacity planning — look back before planning forward.

## Inputs
- Previous quarter identifier (e.g. `2025-Q1`).
- Previous quarter's state file and artifacts in `data/quarters/<QTR>/`, if they
  exist. If nothing exists, run the retro from memory — ask the user to
  reconstruct.

## Steps
1. **Load prior quarter data.** Read `data/quarters/<QTR>/state.md` and any
   artifacts (`breakdown-*.md`, `weekly/` check-ins, `priorities.md`). Note what
   was planned, what reached "done," and what stalled.
2. **Summarize plan vs. reality.** Build a draft table: planned initiatives on
   the left, actual outcome on the right. Include anything that shipped but
   wasn't originally planned (scope creep or opportunistic wins).
3. **Ask the user four questions, one at a time:**
   - (a) What are you most proud of this quarter?
   - (b) What didn't ship that you expected to? Why?
   - (c) What surprised you — good or bad?
   - (d) What do you want to do differently next quarter?
4. **Synthesize.** Combine the data summary and user answers into a retro doc
   with four sections: **Shipped**, **Missed**, **Surprises**, **Changes**.
5. **Write the retro.** Save to `data/quarters/<QTR>/retro.md`.
6. **Report.** Present the retro summary to the user. Highlight any "Changes"
   items that should feed into the next quarter's planning.

## Output / report-back
A retro summary doc at `data/quarters/<QTR>/retro.md`. Key themes surfaced to
the user for input into capacity and priority planning.

## Safety
- Retro content is personal and team-specific — always write to gitignored
  `data/`. Never surface team member names, performance notes, or internal
  details in tracked files.
- Don't editorialize or judge the user's answers. Reflect what they said
  faithfully.
