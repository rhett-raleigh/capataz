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

## Connecting to Obsidian

The notes system works best with the **Obsidian MCP**, which gives the agent
vault-aware read/write/search without filesystem permission prompts.

### Setup (recommended)

1. In Obsidian, install the **Local REST API** community plugin and enable it.
   Copy the API key from its settings.
2. Add the key to your `.env`:
   ```
   OBSIDIAN_API_KEY=your-api-key-here
   ```
3. Register the MCP server:
   ```
   claude mcp add obsidian -- npx -y mcp-obsidian
   ```
4. Allowlist the tools in `.claude/settings.json`:
   ```jsonc
   { "permissions": { "allow": ["mcp__obsidian__*"] } }
   ```

The agent will automatically prefer MCP over direct file writes when available.

### Fallback: direct file access

If you prefer not to run the MCP (or Obsidian isn't open), the agent falls back
to direct file I/O. To reduce permission prompts, allowlist your vault path in
`.claude/settings.local.json` (gitignored — keeps personal paths out of the
shared config):

```jsonc
{
  "permissions": {
    "allow": [
      "Read(~/Library/Mobile Documents/iCloud~md~obsidian/Documents/your-vault/**)",
      "Write(~/Library/Mobile Documents/iCloud~md~obsidian/Documents/your-vault/**)",
      "Edit(~/Library/Mobile Documents/iCloud~md~obsidian/Documents/your-vault/**)",
      "Bash(open \"obsidian://*)"
    ]
  }
}
```

See `docs/setup.md` to get running and `docs/extending.md` to add a capability.
