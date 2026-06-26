# CLAUDE.md

This project uses the open **AGENTS.md** standard as the single source of truth
so the engine stays portable across agent tools. All instructions live there.

@AGENTS.md
@CONTRIBUTING.md

---

Claude-specific notes (optional, safe to keep minimal):

- Treat `AGENTS.md` §4 "Safety rules" as hard constraints.
- Prefer sub-agents for the coding handoff so the orchestrator's context stays
  small (see `capabilities/code-handoff.md`).
- When working **on** this repo (not as the orchestrator), follow `CONTRIBUTING.md`.
