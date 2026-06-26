---
name: example-create-task
description: Find or create a task in the configured tracker, then report back. Example skill — copy it to build real ones.
requires: ["config:tracker"]
profiles: []
---

# Example: create a task

> This is a worked example so you can see the format end to end. It uses a
> generic "tracker" resolved from `config/` rather than a specific tool, so it
> works whether your tracker is Jira, Linear, GitHub Issues, or an Obsidian
> vault. Copy this file to build real, specific skills.

## When to use
The input is actionable work that should be tracked, but is not (yet) code to
write. Use this to make sure a task exists before doing anything else.

## Inputs
- A short description of the work (from a Slack thread, a request, or your own
  classification step).
- Optional: source link to attach for context.

## Steps
1. Read `config/tracker.*` to learn which tracker is active on this machine and
   how to address it (MCP name or API base).
2. Search the tracker for an existing matching task (avoid duplicates).
3. If none exists, create one with a clear title, the source link, and a short
   body summarizing the request.
4. Note the task ID/URL in `memory/log.md` (append-only).

## Output / report-back
The task URL. If the request came from a chat thread, reply there with the link.

## Safety
- Create, never delete or close tasks without explicit confirmation.
- If the tracker isn't configured in `config/`, stop and ask rather than guessing.
