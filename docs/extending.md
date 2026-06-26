# Extending the agent

The engine is designed so that **adding a capability is adding a Markdown file**
— no code change. This is the "self-aware, grows with me" property.

## Add a skill (by you, or by the agent)

1. Copy `skills/_template.skill.md` to `skills/<name>.md` and fill it in. Keep it
   generic: resolve anything machine-specific from `config/`, not hardcoded.
2. Add a one-line entry to the **Skill index** in `AGENTS.md` §7 so the agent
   discovers it without opening the file.
3. Commit it as its own reviewable change.

You can also just **ask the agent** to add a capability ("you should also be able
to file Confluence docs"). It can draft the new skill file and the index line
itself — then you review the git diff and merge. That's the self-extending loop.

## Guardrails on self-modification

A self-editing agent is powerful and can drift. Two rules keep it safe:

- **Everything tracked is in git.** Every self-edit is a commit you can read and
  revert. If behavior changes mysteriously, `git log` tells you why.
- **Private content never enters tracked files.** Skills and capabilities are
  public machinery; your data stays in `memory/`, `data/`, `config/`. AGENTS.md
  §4 makes this a hard rule for the agent.

## Promote a learning into a skill

If `memory/learned.md` keeps recording the same manual workaround, that's a
signal to encode it as a skill so it becomes automatic and shareable across your
machines. Generalize it (strip the private specifics into `config/`) before
committing.
