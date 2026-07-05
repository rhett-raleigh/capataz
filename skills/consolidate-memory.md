---
name: consolidate-memory
description: Promote durable signals from memory/log.md into memory/learned.md, then prune. Scheduled via launchd; safe to also run on demand. Degrades gracefully if log.md has nothing new since last run.
requires: []
profiles: []
---

# consolidate-memory

## Intent

Close the loop described in `AGENTS.md` §5 ("periodically consolidate...")
which currently has no trigger. This skill *is* the trigger. It reads recent
history, decides what's durable, writes it to `learned.md` in the required
curated/deduplicated/one-fact-with-a-why format, and prunes `log.md` so it
doesn't grow unbounded.

## Trigger

- **Scheduled:** cron / launchd, same pattern as INT-003 morning-briefing —
  invoke headless via `claude -p`:
  ```
  claude --agent capataz -p "Run the consolidate-memory skill." \
    --output-format json >> memory/.consolidation-runs.log
  ```
  Suggested cadence: daily or every few days — frequent enough that `log.md`
  doesn't outgrow the tail-load window mentioned in `AGENTS.md` §2, infrequent
  enough that there's enough signal per run to be worth reading.
- **On demand:** "run memory consolidation" / "consolidate capataz memory" in
  any capataz session.

## Procedure

1. **Checkpoint.** Read `memory/.consolidation-state` (new, gitignored — put
   it alongside `memory/`) for the timestamp or line offset of the last
   consolidation run. If it doesn't exist, treat the whole of `log.md` as
   unconsolidated.
2. **Read the unconsolidated tail of `log.md`.** Everything appended since
   the checkpoint.
3. **Read `memory/learned.md` in full** — you need the existing set to
   dedupe against and to know what's already curated.
4. **Identify candidates for promotion.** A log entry is a candidate if it
   is one of:
   - An explicit correction — any `correction` entry (per AGENTS.md §5), or
     prose where the user told a session it was wrong about something
   - A pattern repeated 2+ times across different sessions (same
     preference, same recurring task, same recurring mistake)
   - An explicit "remember this" / "note for next time" instruction that
     was never written to `learned.md` at the time
   - A stable fact about a person, project, tool, or workflow that's
     unlikely to change soon
   Not a candidate: one-off task outcomes, anything already covered by an
   existing `learned.md` entry, anything speculative or unconfirmed.
5. **Dedupe and merge.** If a candidate overlaps an existing `learned.md`
   entry, update that entry in place rather than adding a new one — keep
   `learned.md` at one fact per entry.
6. **Write promotions to `learned.md`.** Each new/updated entry gets a short
   **why** (why this is worth remembering), per the existing format.
7. **Flag contradictions, don't silently resolve them.** If a log entry
   conflicts with an existing `learned.md` entry, don't guess — surface it
   in the run's report (see Output) for the user to resolve, and leave the
   existing entry untouched.
8. **Prune `log.md`.** Move the now-consolidated span to
   `memory/log-archive/YYYY-MM.md` (gitignored, same tier as `log.md`)
   rather than deleting — append-only discipline still applies, it just
   moves to cold storage instead of staying in the hot tail.
9. **Advance the checkpoint** in `memory/.consolidation-state`.
10. **Write a changelog-style entry** to `memory/log.md` itself (a new,
    small entry) noting: run timestamp, how many entries promoted, how many
    flagged as contradictions, how many log lines archived. This keeps the
    consolidation runs themselves visible in history.

## Output (what the user sees, e.g. in the cron log or when run manually)

```
Memory consolidation — <date>
  Promoted: N facts to learned.md
  Updated: N existing entries
  Flagged (needs your input): N contradictions
  Archived: N log.md lines → log-archive/<month>.md
  [if contradictions] Details:
    - learned.md says X (from <date>); log.md <date> suggests Y — which is current?
```

## Safety notes

- Never delete from `log.md` — archive only (§4 "No silent code" spirit
  extended to memory, not just code).
- Never auto-resolve a contradiction between existing and new information —
  always surface it.
- This skill only ever writes to gitignored paths (`memory/`) — no tracked
  file touches, so it doesn't need the code-handoff/PR flow.
- If `learned.md` would exceed a reasonable size after promotion (rough
  guardrail: it should stay skimmable in one read), flag that in the output
  too rather than growing it silently — that's a signal `learned.md` itself
  needs a structure change (candidate for a small PROP if it becomes a
  pattern).

## Open items to decide before first run

- Exact cron cadence (daily vs every 2–3 days)
- Where `memory/.consolidation-state` and `memory/log-archive/` should live
  relative to your existing `memory/` layout — confirm against `config/`
  machine-profile switching if work/personal machines have separate memory
  dirs
- Whether contradiction-flagging should also ping you outside the log (e.g.
  a Slack DM via an existing skill) or just wait to be read at next
  session start
