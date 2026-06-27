---
name: capacity-calc
description: Walk through team capacity inputs — roster, PTO, oncall, maintenance — for a quarter.
requires: []
profiles: [work]
---

# capacity-calc

## When to use
During the capacity planning phase of a quarter — after the retro (if any) and
before priority ranking. The output feeds directly into the capacity-analyzer
specialist agent.

## Inputs
- Quarter date range (e.g. 2025-Q2, April 1 – June 30).
- Team roster, or last quarter's roster as a starting point.

## Steps
1. **Roster.** Ask for the team roster (names and roles). If a previous
   quarter's data exists in `data/quarters/`, suggest reusing that roster and
   ask what changed (joins, departures, role shifts).
2. **PTO.** For each person, ask about known PTO during the quarter (weeks off,
   parental leave, sabbatical, etc.). Record dates or week counts.
3. **Oncall rotation.** Ask who rotates through oncall and what the expected
   capacity tax is. Suggest **20%** as a default if the user isn't sure. Record
   the rotation cadence (e.g. 1 week in 4).
4. **Maintenance / interrupt tax.** Ask about the expected overhead for
   unplanned work, bug fixes, and operational interrupts. Suggest **15%** as a
   default. This applies to the whole team.
5. **Special circumstances.** Ask about anything else that reduces capacity:
   ramping new hires, part-time allocation to other projects, conference travel,
   hack weeks, etc.
6. **Compile the capacity brief.** Produce a structured Markdown block that the
   capacity-analyzer specialist expects:
   - Quarter date range
   - Per-person: name, role, available weeks, PTO weeks, oncall weeks, notes
   - Team-level: maintenance tax %, oncall tax %, special adjustments
   - Gross and net capacity summary

## Output / report-back
A capacity brief written to `data/quarters/<QTR>/capacity-brief.md`, ready to
hand to the capacity-analyzer specialist for detailed analysis.

## Safety
- Team roster, PTO, and capacity data is personal — always write to gitignored
  `data/`. Never include names or PTO details in tracked files.
- Use the user's numbers. Don't override their estimates — the defaults (20%
  oncall, 15% maintenance) are suggestions, not mandates.
