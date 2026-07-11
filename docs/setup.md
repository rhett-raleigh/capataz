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

## Scheduled tasks

Several skills are designed to run unattended. The engine doesn't schedule
anything itself — wire these up with whatever scheduler your agent tool
provides (Claude Code scheduled tasks, cron, launchd). Recommended set:

| Task | Skill | Suggested schedule | What it does |
|------|-------|--------------------|--------------|
| `capataz-consolidate-memory` | `consolidate-memory` | daily, off-hours | Promote durable signals from `memory/log.md` into `memory/learned.md`, then prune. |
| `capataz-goal-notify` | `goal-notify` | 1–3x daily, waking hours | Rule-gated goal nudges via macOS notification. Silent by default; skips if goals aren't set up. |
| `capataz-weekly-goal-review-reminder` | (reminder for `goal-review`) | weekly, e.g. Sunday evening | One notification prompting an interactive goals review. The review itself is a conversation — never run it headless. |
| `morning-briefing` | `morning-briefing` | optional: weekday mornings | Daily briefing to `data/briefings/`. Also fine to run on demand. |

Each scheduled prompt should instruct the agent to work in this repo and follow
the corresponding skill file exactly — the skill files carry the safety rules
(quiet hours, notification caps, write boundaries).

## Optional: keep goals data in your Obsidian vault

`data/goals/` can be a symlink into your vault so goals and check-in logs are
visible in Obsidian (and on mobile via vault sync) while every skill keeps
reading the same `data/goals/...` paths:

```bash
mv data/goals "<vault>/goals"
ln -s "<vault>/goals" data/goals
```

If you also use the `notes` skill's quarterly goal notes (`<vault>/goals/YYYY-QN-<slug>.md`
with `type: goal` frontmatter), they'll live in the same vault folder as
`goals.md`/`log/`/`notifications.log`. That's fine — the notes capability
scans by frontmatter, so it ignores files that don't match — but keep it in
mind if you'd rather keep the two systems visually separate (in which case
symlink to a subfolder like `<vault>/goals/capataz` instead).

The symlink lives in gitignored `data/`, so nothing personal leaks into the
repo either way.

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
