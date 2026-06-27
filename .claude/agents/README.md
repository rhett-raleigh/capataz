# Agent definitions

Claude Code custom subagent definitions for the capataz orchestrator.

## Install

The agent definition at `.claude/agents/capataz.md` is automatically
discovered when running Claude Code in this project directory. To make it
available globally (all projects, dispatch, any session), copy it:

```bash
cp .claude/agents/capataz.md ~/.claude/agents/capataz.md
```

You can then invoke it with:

```bash
claude --agent capataz "Orchestrate this input: <your request>"
```

Or let Claude delegate to it automatically when a task matches the
agent's description.

## What's here

- `capataz.md` — the main orchestrator agent. Routes Slack links,
  tickets, and instructions through the core loop in AGENTS.md.
