# Memory model

Two distinct jobs, kept separate on purpose.

## Self-description vs. accumulated memory

- **Self-description** (what the agent *is*): `AGENTS.md`, `skills/`,
  `capabilities/`. Tracked, public, changes only when you add functionality.
- **Accumulated memory** (what the agent *has learned/done*): `memory/`.
  Gitignored, private, grows over time.

Don't mix them. The first is committed machinery; the second never leaves the
machine.

## The two memory files

### `memory/learned.md` — curated, always loaded
Durable facts and corrections the agent should always know. One fact per entry,
each with a short **why**. Keep it small and deduplicated — it loads every run,
so bloat here degrades performance.

```
- Frontend tickets always get a QA reviewer assigned.
  Why: team policy; PRs without it get bounced.
```

### `memory/log.md` — append-only history
A running record of tasks handled and outcomes. **Not** loaded whole — the agent
reads only the relevant tail. This is the audit trail, not working memory.

```
2026-06-25  engineering  PROJ-412 → repo api-gateway → PR #88 (merged by human)
2026-06-25  note         logged quarterly goal to data/goals.md
2026-06-26  correction   routed repo bug-report as task; user said engineering — prefer engineering when a repo is named
```

Entries are written two ways: skills append their own outcome lines (per
their Output sections), and the machinery appends mechanically — `bin/capataz`
logs every `run` / `run-async`, and a `SessionEnd` hook logs every
`session-end` (see `hooks/log-session-end.sh`). Mechanical entries guarantee
history exists even when a session forgets to log. All writers go through
`bin/capataz-log`, which creates the file on first use.

## Consolidation

Periodically (a cheap recurring task): scan `log.md` for durable signals,
promote them into `learned.md` with a why, then prune. Delete facts that turn out
wrong rather than letting them rot. Smaller, truer `learned.md` beats a big one.

The trigger for this is `skills/consolidate-memory.md` — runnable on a cron
schedule or on demand. See that file for the full procedure, checkpoint
mechanics, and contradiction-handling rules.

## Why not one big memory file
A single growing blob gets loaded in full every run, costs context, and mixes
"who I am" with "what happened." Splitting keeps each part small and purpose-fit.
