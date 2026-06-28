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
- `quarter-coach.md` — the Quarter Coach. Guides a small team through
  quarter planning and execution (retro → capacity → specs → breakdown →
  weekly goals).
- `capacity-analyzer.md` — specialist: produces capacity plans from a
  structured brief.
- `spec-drafter.md` — specialist: drafts functional specs from a scoping
  brief.
- `work-breaker.md` — specialist: breaks specs into epics and stories
  with estimates.
- `goal-setter.md` — specialist: proposes weekly goals from breakdown
  and progress data.
