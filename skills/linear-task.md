---
name: linear-task
description: Turn a free-text idea, goal, or request into a Linear issue on a personal project, and optionally kick off a coding agent on it.
requires: ["config:tracker", "MCP:linear"]
profiles: [personal]
---

# linear-task

## When to use
The input is a personal idea, feature, chore, or goal you want tracked in Linear
— e.g. "add dark mode to my budget app", "write a blog post on X", "refactor the
auth in side-project". Use for the personal profile where Linear is the tracker.

## Inputs
- Free text describing the work. May include a project hint ("budget app").
- Optional source link to attach.

## Steps
1. Read `config/tracker.md` to confirm Linear is active and get the default
   team/project. Read `config/repo-map.md` if a code handoff might follow.
2. **Resolve the project.** Match any hint in the input to a Linear team/project.
   If none is obvious and several exist, ask which one (one short question).
3. **Dedupe.** Search Linear for an open issue with a similar title; if a close
   match exists, surface it instead of creating a duplicate.
4. **Create the issue** via the Linear MCP: concise imperative title, a body that
   restates the request + acceptance criteria, the source link, and a sensible
   priority/label if the input implies one.
5. **Decide on code.** If this is engineering work on a mapped personal repo and
   you want to start now, follow `capabilities/code-handoff.md` (branch → headless
   coding agent → PR). Otherwise stop at the issue. Confirm before any code.
6. Append the outcome to `memory/log.md` (date, `task` or `engineering`, issue URL).

## Output / report-back
The Linear issue URL. If a PR was opened, link it on the issue and report both.

## Safety
- Create issues; don't close/delete without confirmation.
- Code handoff only on allowlisted repos in `config/repo-map.md`, never auto-merge.
- If Linear isn't reachable, stop and report — don't silently fall back to another
  tracker.
