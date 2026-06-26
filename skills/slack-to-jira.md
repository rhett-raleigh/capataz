---
name: slack-to-jira
description: Take a Slack message/thread link, understand it, find-or-create a Jira ticket, and (for engineering work) hand off to a coding agent for a PR — then reply in the thread.
requires: ["MCP:slack", "MCP:atlassian", "config:tracker", "config:repo-map"]
profiles: [work]
---

# slack-to-jira

## When to use
The input is a Slack message or thread link (or text pasted from Slack) describing
work that should live in Jira. The primary work-profile entrypoint.

## Inputs
- A Slack permalink (or channel + ts), or pasted Slack text.
- Implicitly: the active work `config/` (Jira project conventions, repo map).

## Steps
1. **Read the source.** Use the Slack MCP to fetch the full thread, not just the
   linked message — replies usually hold the real requirements. Capture the
   permalink for report-back.
2. **Classify** (see `capabilities/classify.md`): note / task / engineering.
   Record the lane + one-line reason.
3. **Find-or-create the Jira ticket** via the Atlassian MCP:
   - Search for an existing ticket referencing this thread or the same ask; if
     found, use it.
   - Otherwise create one in the project from `config/tracker.md`: clear summary,
     description restating the request + acceptance criteria, and the Slack
     permalink in the description for traceability.
4. **Confirm before code.** Post a short check in the thread: "Created/Found
   <TICKET>. I'll implement it in <repo> on branch <x> — 👍 to proceed." Wait,
   unless `memory/learned.md` marks this flow trusted.
5. **Hand off (engineering only).** Follow `capabilities/code-handoff.md`: resolve
   the repo from `config/repo-map.md` (allowlist enforced), branch, run the coding
   agent **headless in the background** so the trigger returns fast, open a PR.
6. **Report back.** Reply in the Slack thread with the Jira ticket link and, once
   ready, the PR link. Link the PR on the Jira ticket too. Append to `memory/log.md`.

## Output / report-back
A Slack thread reply containing the Jira ticket URL and (if applicable) the PR URL.

## Safety
- Only touch repos on the `config/repo-map.md` allowlist; never auto-merge.
- Confirm before the first code on any new flow.
- Never paste secrets or full internal thread contents outside Slack/Jira.
- If the thread is ambiguous, ask in-thread rather than guessing the ticket scope.
