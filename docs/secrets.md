# Secrets

Goal: the agent can **never** read your tokens, even by accident.

## The core principle: the agent doesn't need them

The orchestrator's job is to call MCP tools (Slack, Atlassian, Linear) and run
git. The **MCP servers** authenticate, not the agent. So credentials should live
*with the MCP servers / the OS keychain*, never in a file the orchestrator reads.
If the agent never needs a secret, the safest place for it is "not reachable."

`bin/capataz` deliberately does **not** load `.env` into the agent's
environment — that would let the agent `printenv` the tokens.

## Defense in depth (three layers)

1. **Keep secrets out of the agent's reach.**
   - Prefer the **macOS Keychain** or a secret manager over a `.env` file.
   - Configure each MCP server with its own credentials (e.g. `claude mcp add`
     with env), so the token lives in the server's config, not the project.
   - If you must use `.env`, it's gitignored and the hook below blocks reads.

2. **PreToolUse hook (the real gate).** `hooks/protect-secrets.sh` fires before
   every Read/Bash/Grep/Glob and hard-blocks any call referencing `.env`,
   `secrets/`, `.mcp.json`, `*.token`, `*.secret`, or `credentials*`. Unlike the
   deny rules, hooks are actually enforced.

3. **Deny rules + gitignore (backstops).** `permissions.deny` and `.gitignore`
   add belt-and-suspenders, but **do not rely on deny rules alone** — Claude Code
   has documented bugs where denied files were read anyway. They're a backstop to
   the hook, not the defense.

## Install (per machine)

```bash
mkdir -p .claude
cp setup/claude-settings.json .claude/settings.json
chmod +x hooks/protect-secrets.sh
```

Then test it (see docs/sessions.md note): ask the agent to read `.env` and
confirm it is blocked by the hook before you put any real secret on the machine.

## Why not just .claudeignore?

`.claudeignore` has the same reliability problem as deny rules — it's been shown
not to stop reads. Treat it as a hint, not a control.
