# Idea: Notes inbox — tagged Obsidian notes as an async input channel

**Date:** 2026-07-11
**Status:** Captured

## What

Use a folder in the Obsidian vault as an asynchronous inbox for capataz. The
user drops in notes tagged with metadata — kind (meeting, ideation session,
journal), date, people, project — and a scheduled automation periodically:

1. **Parses** new/changed notes in the inbox folder (frontmatter + body).
2. **Evaluates effects** — does this note's content collide with or affect
   known state? Examples: a meeting note sets a deadline that conflicts with
   the quarter plan or another commitment (timeline collision), a decision
   contradicts an earlier one, a mentioned person/date intersects an existing
   task.
3. **Alerts** the user when an effect is found (notification and/or a line in
   the morning briefing), instead of silently absorbing it.
4. **Routes and logs** the content to the proper place — vault notes structure,
   `memory/log.md`, `memory/learned.md`, `project/` for capataz-related ideas —
   using the existing classify capability.
5. **Optionally starts work** it can pick up: draft a tracker ticket, prepare a
   coding-agent handoff, queue a follow-up — surfaced for confirmation rather
   than executed silently.

Effectively: today capataz is pull-based (user invokes a skill); this makes it
push-based — the vault becomes a queue and capataz drains it on a schedule.

## Why it matters

Capture is cheapest at the moment of thought — in Obsidian, mid-meeting, on
mobile — not when sitting in a terminal. Right now anything captured in the
vault is inert until the user remembers to act on it. This closes that loop:
notes become inputs, and cross-referencing against calendar/plans/memory
catches conflicts (timeline collisions, contradicting decisions) that a human
skimming their own notes reliably misses. It composes almost entirely from
existing pieces: Obsidian MCP + notes capability (read/write), classify
(routing), morning-briefing (surfacing), consolidate-memory (scheduled-run
pattern), memory model (logging).

## Open questions

- **Safety boundary for "start on tasks."** AGENTS.md §4 forbids silent code
  and requires confirmation on ambiguity. Likely model: the scheduled run may
  *prepare* work (draft tickets, staged handoffs) but everything lands in a
  pending-confirmation state the user approves via notification/briefing.
  Which actions, if any, are ever trusted to run unattended?
- **Processed-state tracking.** How does a run know what's new? Options:
  marker in note frontmatter (`capataz-processed: <date>`), a state file in
  `data/`, or moving notes out of the inbox folder after processing.
- **Effect detection scope.** Collision against what, concretely — calendar
  (MCP), quarter plan state, goals, tracker tickets, prior decisions in
  memory? Start narrow (dates/deadlines) and widen?
- **Tag schema.** Frontmatter keys the user commits to at capture time —
  `kind`, `date`, `people`, `project`? How much can be inferred vs. required?
- **Alert channel.** macOS notification (goal-notify pattern), morning-briefing
  section, both? Same quiet-hours/dedupe rule stack as goal-notify?
- **Profiles.** Personal vault only, or also a work inbox with different
  routing (Jira vs. Linear, work memory boundaries)?
- **Cadence.** Continuous-ish (every 15 min) vs. a few times a day vs. bundled
  into the morning briefing run.
