# Overview

`capataz` is a self-aware, self-extending orchestrator engine. You invoke it
(e.g. from a Raycast hotkey) with a Slack link, a ticket reference, or a plain
request. It reads the source, classifies the work, records or creates the task,
and — for engineering work — hands off to an isolated coding agent that opens a
PR, then reports back where the request came from.

## The two halves

**Engine (this repo, public).** The machinery: `AGENTS.md`, `skills/`,
`capabilities/`, `docs/`, `templates/`. Generic and shareable. Improvements flow
back as PRs and benefit every machine that pulls the repo.

**Data (local, private, never committed).** `memory/`, `data/`, `config/`,
`.env`, `.mcp.json`. Your notes, learnings, repo maps, tokens, and the work-vs-
personal split. Enforced by `.gitignore` and by AGENTS.md §4.

This split is the whole design: capabilities co-evolve in the open; nothing
personal or confidential ever leaves the machine.

## Portability

Instructions live in `AGENTS.md`, the open cross-tool standard. `CLAUDE.md` is a
one-line pointer to it, so the engine runs on any AGENTS.md-aware agent while
behaving natively in Claude.

## One engine, many profiles

The same engine runs on each machine. What differs is the local `config/`:
which MCPs/tracker are wired, which repos are allowed, and the active profile
(`work` / `personal`). A skill written once works across profiles because the
specifics are resolved from `config/` at runtime.
