# Scheduling — proactive runs

Capataz becomes an assistant (rather than a tool you poke) when its recurring
skills run unattended. On macOS the native mechanism is **launchd**; the
templates in `templates/launchd/` schedule:

| Schedule | Skill | When |
|----------|-------|------|
| `com.capataz.morning-briefing` | `morning-briefing` | daily 07:00 |
| `com.capataz.consolidate-memory` | `consolidate-memory` | daily 21:30 |

Both go through `bin/capataz`, the single entrypoint (docs/invocation.md), so
scheduled runs behave identically to manual ones and land in
`data/sessions.log` and `memory/log.md` like any other run.

## Install

```bash
bin/install-schedules
```

The script substitutes this repo's absolute path into the templates, writes
them to `~/Library/LaunchAgents/`, and loads them. It is idempotent — re-run
it after moving the repo or editing a template.

## Verify

```bash
launchctl list | grep com.capataz     # both labels listed
ls data/launchd/                      # stdout/stderr of each run
```

## Change the cadence

Edit the `StartCalendarInterval` dict in the template (see `man launchd.plist`
for forms like weekday-only), then re-run `bin/install-schedules`.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.capataz.*.plist
rm ~/Library/LaunchAgents/com.capataz.*.plist
```

## Notes

- launchd runs jobs missed while the machine slept as soon as it wakes; a
  closed laptop at 07:00 still gets its briefing on wake.
- The installed plists live outside the repo and contain a machine-specific
  path — that's why the repo tracks only `__CAPATAZ_ROOT__` templates
  (privacy split, AGENTS.md §4).
