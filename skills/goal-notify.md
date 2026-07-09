---
name: goal-notify
description: Evaluate goal nudge rules (quiet hours, dedupe, pause, triggers) and send at most one bundled macOS notification per goal per day. Meant for a scheduled run; also on demand via "check my goal nudges".
requires: ["Bash:osascript"]   # optional: ["MCP:copilot"] for finance triggers
profiles: [personal]
---

# goal-notify

## When to use
A scheduled run (cron) or an explicit "check my goal nudges" / "should I be
nudged about anything". This skill decides *whether* to interrupt the user —
its default outcome is silence.

## Inputs
- `data/goals/goals.md` — goals, cadences, statuses, notification settings.
- `data/goals/log/` — recent entries (current month; previous month if we're
  early in a month).
- `data/goals/notifications.log` — what's already been sent.

## Steps

### 0. Rule stack — evaluate in order, stop at the first block
1. **Quiet hours.** Current time inside the quiet-hours window from `goals.md`
   (default 22:00–08:00) → stop. Send nothing, log nothing.
2. **Briefing imminent.** If the morning briefing is scheduled to run within
   the next hour (or hasn't run yet this morning and usually runs soon), skip —
   the briefing's Goals section will carry the nudge without a second ping.
3. **Per-goal dedupe.** Read `notifications.log`; any goal already notified
   today is excluded from the rest of this run.
4. **Paused goals.** Any goal with `Status: paused` in `goals.md` is excluded.

If no goals remain, stop silently.

### 1. Check triggers (per remaining goal)
- **Overdue check-in**: no log entry in > 2× the goal's cadence interval.
- **Off-track frequency**: the period's remaining time can't meet the target
  (e.g. 3x/week goal, 0 sessions by Friday). For finance goals, if the Copilot
  MCP is available, check real month-to-date spend against the target; if not,
  fall back to logged entries only.
- **Streak milestone**: today's log entry completed a milestone from
  `goals.md` (default 7, 14, 30, 60, 100). Positive nudges count too.
- **Back on track**: first ✅ after a flagged gap — worth reinforcing.

No trigger fires → stop silently. That's the normal case.

### 2. Bundle and send
- Compose **one** notification covering every triggered goal — never send
  multiple notifications in a run. Tone: informative and brief, not nagging.
  Lean on each goal's **why** for phrasing when it helps.
- Send via:
  ```bash
  osascript -e 'display notification "No gym log in 4 days — 3x/week needs 2 by Sunday" with title "Capataz goals"'
  ```
  Escape quotes in the message. Keep it under ~110 chars so macOS doesn't
  truncate the substance.

### 3. Record
Append one line to `data/goals/notifications.log` in its documented format
(`YYYY-MM-DD HH:MM | goal(s) | trigger(s) | message`). This is what enforces
the 1-per-goal-per-day cap on future runs.

## Output / report-back
Usually nothing (no trigger, or blocked by a rule). At most one macOS
notification plus one line in `notifications.log`. When run interactively,
also state what fired or why nothing did.

## Safety
- Bias to silence: when a trigger is ambiguous (log unclear, cadence math
  borderline), don't notify. A missed nudge is cheap; a nagging system gets
  turned off.
- Hard cap: 1 notification per goal per day, enforced via `notifications.log`.
- `osascript` is used only for `display notification` — never for controlling
  apps or executing anything else.
- Copilot MCP usage is read-only.
- Write only to `data/goals/notifications.log`.
