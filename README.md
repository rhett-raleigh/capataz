# capataz

A small, tool-agnostic **engine** for a self-aware orchestrator agent that you
extend over time. You point it at a Slack message, a ticket, or a plain request;
it figures out what kind of work it is, records or creates the task, and — for
engineering work — hands off to a coding agent to open a PR.

The engine is public. **Your memory, data, and tool configuration are not** —
they live in gitignored local directories and never get committed.

## What's in the repo (public)

```
AGENTS.md           Canonical agent instructions (the standard format)
CLAUDE.md           One-line pointer to AGENTS.md (Claude-native)
.claude/agents/     Claude Code subagent definition (copy to ~/.claude/agents/)
.claude/settings.json  Permissions allowlist for autonomous operation
skills/             Reusable capabilities, one Markdown file each
capabilities/       Core behaviors: classify work, hand off to a coding agent
docs/               Generalized setup + extension guides
templates/          Empty shapes for the private files you create locally
bin/                Entrypoints: capataz (CLI), link-worktree-state (worktree shim)
```

## What you create locally (never committed)

```
memory/          What the agent has learned and done
data/            Your notes, goals, reflections, exports
config/          repo maps, machine-specific settings
.env / .mcp.json Tokens and MCP wiring
```

`.gitignore` enforces this split, and `AGENTS.md` instructs the agent to write
private content **only** into those ignored paths.

## Why AGENTS.md (not just CLAUDE.md)

[AGENTS.md](https://agents.md/) is an open, cross-tool standard for agent
instructions, stewarded under the Linux Foundation and read by most coding
agents (Codex, Cursor, Copilot, Gemini) — and by Claude Code. We keep all the
real content in `AGENTS.md` and make `CLAUDE.md` a one-line `@AGENTS.md` pointer,
so the engine is portable but behaves natively in Claude.

## Quick start

1. `cp .env.example .env` and fill in what your skills need.
2. Copy the files under `templates/` into `config/`, `memory/`, `data/`.
3. Install the agent definition:
   ```
   cp .claude/agents/capataz.md ~/.claude/agents/capataz.md
   ```
4. Wire your MCPs locally (e.g. `claude mcp add ...`) — never commit `.mcp.json`.
5. Run the orchestrator:
   ```
   bin/capataz "https://yourworkspace.slack.com/archives/..."
   # or
   claude --agent capataz "Orchestrate this input: ..."
   ```

See `docs/setup.md` to get running and `docs/extending.md` to add a capability.
