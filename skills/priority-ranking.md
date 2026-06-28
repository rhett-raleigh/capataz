---
name: priority-ranking
description: Collaboratively rank quarter initiatives by impact and effort.
requires: []
profiles: [work]
---

# priority-ranking

## When to use
During the priority setting phase of a quarter, after capacity is known. Takes
candidate initiatives and produces a ranked, sized list that fits within the
team's available capacity.

## Inputs
- Candidate initiatives (from the user — may come from leadership, PM, tech
  debt backlogs, or carryover from last quarter).
- Available capacity from the capacity plan (`data/quarters/<QTR>/capacity-plan.md`
  or the capacity-analyzer output).

## Steps
1. **Leadership / PM priorities.** Ask: What are the top priorities from
   leadership, product, or stakeholders? List them.
2. **Carryover.** Ask: What carries over from last quarter that's still
   important? Check `data/quarters/<PREV>/priorities.md` if it exists and
   surface unfinished items.
3. **Team wishlist.** Ask: What's on the team's own wishlist — tech debt, DX
   improvements, experiments, things that never get prioritized?
4. **Compile the full candidate list.** Combine all inputs into a single
   numbered list, noting the source of each item (leadership, carryover, team).
5. **Size each candidate.** For each item, ask the user to estimate:
   - **Impact:** High / Medium / Low
   - **Effort:** S / M / L / XL
   Accept the user's judgment — don't second-guess domain expertise.
6. **Rank by impact-to-effort ratio.** Sort the list: High-impact/Small-effort
   first, Low-impact/XL-effort last. Present the ranked list.
7. **User adjustment.** Ask the user to review and adjust: move things up or
   down, cut items that don't fit capacity, bundle related items. Iterate until
   the user is satisfied.
8. **Write the final list.** Save to `data/quarters/<QTR>/priorities.md` with
   each item showing: rank, name, impact, effort, source, and status (planned /
   cut / stretch).

## Output / report-back
A prioritized initiative list at `data/quarters/<QTR>/priorities.md` with
T-shirt sizes and cut line. Ready for the breakdown phase.

## Safety
- Priority and strategy data stays in gitignored `data/`. Never expose internal
  prioritization decisions, initiative names, or leadership directives in
  tracked files.
- The user owns the final ranking. Present analysis, but never override their
  judgment on what matters.
