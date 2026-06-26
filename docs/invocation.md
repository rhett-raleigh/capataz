# Invocation

There is **one entrypoint** and **many triggers**. Keep it that way.

## The single entrypoint

Every trigger funnels into one command that runs the agent headless with the
input as an argument:

```bash
# bin/capataz  — the only thing that actually runs the agent
cd /path/to/capataz
exec claude -p "Orchestrate this input: $*"
```

All the surfaces below just call `capataz "<input>"`. This keeps behavior
identical no matter how it's triggered, and means a new front-end is a few lines
of glue, never a new copy of the logic.

Triggers fall into two kinds: **push** (you start it) and **event** (something
else starts it).

---

## Push — you initiate

| Surface | How | Good for |
|--------|-----|----------|
| **Raycast Script Command** | hotkey + argument → `capataz "$1"` | fastest manual trigger; paste a link and go |
| **CLI / shell alias** | `capataz "..."` or a `function` in your shell | when you're already in a terminal |
| **macOS Shortcuts** | a Shortcut runs the script; bind a global hotkey, Siri, or menu-bar | hands-free / voice / cross-device (also iPhone) |
| **Share Sheet / Services** | macOS "Services" or a Shortcut in the share sheet → send the current URL/selection | "share this Slack message to the agent" from any app |
| **Alfred workflow** | keyword + argument, same as Raycast | if you use Alfred instead |
| **Clipboard watcher** | a tiny script that fires when you copy a Slack link | near-zero-friction, but easy to over-trigger — use sparingly |

## Event — something else initiates

| Surface | How | Good for |
|--------|-----|----------|
| **Slack message shortcut** | Slack app "message action" → webhook → `orchestrate` with the permalink | the most natural: right-click any message → "Send to orchestrator" |
| **Slack slash command** | `/orchestrate <text>` → webhook → `orchestrate` | quick asks from inside Slack |
| **Slack emoji reaction** | Events API watches for a 🤖 reaction → `orchestrate` on that message | triage by reacting; no typing |
| **Tracker webhook** | Jira/Linear fires when a ticket gets a label or is assigned to a bot user → `orchestrate` | "label it `agent` and walk away" |
| **Scheduled / cron** | a timer runs `capataz "scan #channel for action items"` each morning | proactive digests and sweeps |
| **Git/CI hook** | GitHub Action or webhook on an event → `orchestrate` | repo-driven automation |
| **Email forward** | forward to an address whose inbox a watcher polls → `orchestrate` | capture from anywhere, async |

---

## Choosing

- **Start with two:** a **Raycast** command (push) and the **Slack message
  shortcut** (event). Together they cover "I have a link in hand" and "I'm
  already in Slack" — which is 90% of your described flow.
- **Add scheduled** runs once you trust it, for proactive sweeps.
- **Webhook/event triggers need a reachable listener.** If `orchestrate` runs on
  your laptop, event triggers (Slack/Jira webhooks) need either a small always-on
  local listener with a tunnel, or a tiny hosted relay that calls back to your
  machine. Push triggers (Raycast/CLI/Shortcuts) have no such requirement — which
  is why they're the easy starting point.

## Sync vs async (applies to every trigger)

Coding a PR takes minutes; triggers want a fast ack. So `orchestrate` should
**reply immediately** ("started — TICKET-123") and **background** the coding
handoff, then post the PR link to the source thread when done. Never make the
trigger block on a full code run.
