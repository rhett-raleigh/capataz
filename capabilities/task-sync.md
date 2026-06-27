# Capability: task-sync

Generic interface for reading from and writing to external task trackers
(Jira, Linear) — without hardcoding any provider.

## Goal

Let the orchestrator query existing tasks for context and push local breakdowns
(epics, stories) to the configured tracker, using whichever provider the current
machine is set up for.

## Interface

| Operation | Signature | Description |
|-----------|-----------|-------------|
| **read**  | `read(query) → structured list` | Pull tasks or epics matching a query for reference. |
| **write** | `write(breakdown_path, destination) → links` | Push a local epic/story breakdown to the tracker. Returns created ticket URLs. |

## How it works

1. **Resolve the provider.** Read `config/integrations.md` to find the active
   task tracker (e.g. `jira`, `linear`).
2. **Load the adapter.** Look for `skills/sync-<provider>.md`. If no adapter
   exists for the configured provider, **stop and tell the user** — don't fall
   back to another provider or guess.
3. **Load sync instructions.** If `config/sync-instructions/<provider>.md`
   exists, load it. These contain team-specific conventions: project key, board
   ID, epic link field, story point scale, component mappings, team IDs. If no
   sync instructions exist, ask the user for the minimum required info (e.g.
   which Jira project key to use) and suggest they save it to
   `config/sync-instructions/<provider>.md` for next time.
4. **Execute.** Run the adapter's read or write steps with the sync instructions
   applied.

## Draft-first rule

The breakdown **must exist locally** (in `data/` or a working directory) before
any write to the external tracker. The user explicitly requests the sync — it
never happens automatically.

## Safety

- Respects the privacy boundary: local breakdowns live in gitignored paths; only
  generic, non-secret content is pushed to external trackers.
- No automatic syncing — the user triggers every write.
- Provider resolution is explicit; no silent fallback between providers.
