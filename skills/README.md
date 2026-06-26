# Skills

A **skill** is one Markdown file describing a single capability the orchestrator
can perform. Skills are public, generic, and reusable — they describe *how* to do
something, never *your* private data. Anything machine-specific (which tracker,
which repos, which tokens) is read from `config/` and `.env` at runtime, not
hardcoded here.

## Format

Each skill is a Markdown file with this frontmatter and shape:

```markdown
---
name: short-kebab-case-name
description: One line. When should the agent reach for this skill?
requires: [optional list, e.g. "MCP:slack", "MCP:atlassian", "env:LINEAR_API_KEY", "config:repo-map"]
profiles: [optional: personal, work — omit to mean "any"]
---

# <Skill name>

## When to use
A sentence or two so the agent can match an input to this skill from the index
in AGENTS.md without opening the file.

## Inputs
What the skill needs (e.g. a Slack URL, a ticket key, a free-text goal).

## Steps
1. Numbered, concrete steps the agent follows.
2. Reference MCP tools or config by their generic name; resolve specifics from
   config/ and .env.

## Output / report-back
What the skill produces and where it reports (e.g. reply in the Slack thread
with the created ticket + PR link).

## Safety
Any skill-specific guardrails on top of AGENTS.md §4.
```

## Adding a skill

1. Copy `_template.skill.md` to `skills/<name>.md` and fill it in.
2. Add a one-line entry to the **Skill index** in `AGENTS.md` §7.
3. Commit it as its own reviewable change.

Keep skills generic enough to share. If a skill only makes sense with your
private setup, the private part belongs in `config/`, not in the skill.
