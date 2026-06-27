# Setup

Per machine (run once on each laptop):

1. **Clone** the public engine repo.

2. **Create local dirs from templates.**
   ```
   cp templates/config/repo-map.example.md   config/repo-map.md
   cp templates/config/tracker.example.md    config/tracker.md
   cp templates/memory/learned.example.md    memory/learned.md
   cp templates/memory/log.example.md        memory/log.md
   ```
   These land in gitignored paths — they will not be committed.

3. **Environment.**
   ```
   cp .env.example .env
   # fill in only what your skills need
   ```

4. **Wire MCPs locally** (don't commit them). With Claude Code, for example:
   ```
   claude mcp add slack ...
   claude mcp add atlassian ...
   ```
   The resulting `.mcp.json` is gitignored.

5. **Install the agent definition and secret protection:**
   ```
   mkdir -p ~/.claude/agents
   cp .claude/agents/capataz.md ~/.claude/agents/capataz.md
   chmod +x hooks/protect-secrets.sh bin/capataz bin/link-worktree-state
   ```
   This makes `capataz` available as a named agent (`claude --agent capataz`)
   and from dispatch/start_code_task invocations.
   Then verify: ask the agent to read `.env` and confirm the hook blocks it.
   See `docs/secrets.md`.

6. **Set the profile.** In `config/`, note whether this machine is `work` or
   `personal`, which tracker is active, and which repos are allowed.

7. **Run.** Either open the repo interactively, or use the single entrypoint:
   ```
   bin/capataz "https://yourworkspace.slack.com/archives/..."
   ```
   It reads `AGENTS.md`, discovers `skills/`, loads local memory/config, runs
   headless, logs the session id to `data/sessions.log`, and prints a resume
   command. See `docs/invocation.md` and `docs/sessions.md`.

## Wiring a trigger (e.g. Raycast)

Point a Raycast Script Command at a small wrapper that invokes your agent
headless with the pasted input as an argument, e.g.:

```bash
#!/bin/bash
# @raycast.title Capataz
# @raycast.mode compact
cd /path/to/capataz
claude -p "Orchestrate this input: $1"   # or your agent's headless invocation
```

Keep the trigger fire-and-forget: the orchestrator should background long work
(the coding handoff) and report results back to the source thread.
