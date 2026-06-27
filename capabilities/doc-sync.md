# Capability: doc-sync

Generic interface for reading from and writing to external document stores
(Confluence, Google Docs, Notion) — without hardcoding any provider.

## Goal

Let the orchestrator pull external documents as Markdown context and push local
Markdown artifacts back to the doc store, using whichever provider the current
machine is configured for.

## Interface

| Operation | Signature | Description |
|-----------|-----------|-------------|
| **read**  | `read(source) → Markdown` | Pull a document (by URL or ID) and return it as local Markdown. |
| **write** | `write(artifact_path, destination) → link` | Push a local Markdown artifact to the doc store. Returns the published URL. |

## How it works

1. **Resolve the provider.** Read `config/integrations.md` to find the active
   document store (e.g. `confluence`, `notion`, `google-docs`).
2. **Load the adapter.** Look for `skills/sync-<provider>.md`. If no adapter
   exists for the configured provider, **stop and tell the user** — don't fall
   back to another provider or guess.
3. **Load sync instructions.** If `config/sync-instructions/<provider>.md`
   exists, load it. These contain team-specific conventions: space keys, parent
   page IDs, formatting rules, label conventions, template references. If no
   sync instructions exist, ask the user for the minimum required info (e.g.
   which Confluence space to publish to) and suggest they save it to
   `config/sync-instructions/<provider>.md` for next time.
4. **Execute.** Run the adapter's read or write steps with the sync instructions
   applied.

## Draft-first rule

The artifact **must exist locally** (in `data/` or a working directory) before
any write to the external store. The user explicitly requests the sync — it
never happens automatically.

## Safety

- Respects the privacy boundary: local drafts live in gitignored paths; only
  generic, non-secret content is pushed to external stores.
- No automatic syncing — the user triggers every write.
- Provider resolution is explicit; no silent fallback between providers.
