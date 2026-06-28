# Capability: classify

The first decision every run. Cheap to get right, expensive to get wrong, so be
explicit and ask when unsure.

## Goal
Sort an incoming input into one of three lanes:

| Lane | Looks like | Routes to |
|------|-----------|-----------|
| **note** | a personal goal, reflection, idea, "remember that…" | invoke `skills/notes.md` to capture, refine, or reflect |
| **project** | an idea/decision/plan about *this project* (capataz) | write to `project/` using its templates (see AGENTS.md §8) |
| **task** | actionable work to track, but not code to write now | find-or-create in the tracker (see skills) |
| **engineering** | a bug/feature that ends in a code change | ticket → `code-handoff` → PR |

## How to decide
1. Read the source fully (e.g. the whole Slack thread, not just the link text).
2. Ask: is this about *this project itself* — an idea for capataz, a decision
   to record, a plan to break down? If yes → project. Does resolving this end
   in a **code change to a known repo**? If yes → engineering. If it's
   actionable but not code → task. If it's personal (for *you* to reflect on
   or recall later) → note.
3. Consider the active **profile** (`config/`): a personal machine may have no
   engineering lane at all; a work machine may forbid the note lane.
4. **If genuinely ambiguous, ask.** One short clarifying question beats a wrong
   route that creates a stray ticket or PR.

## Output
A single lane label plus a one-sentence reason, recorded to `memory/log.md`.
Then invoke the matching skill/capability.
