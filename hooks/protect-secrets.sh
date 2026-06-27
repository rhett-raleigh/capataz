#!/usr/bin/env bash
# PreToolUse hook — HARD-BLOCK any tool call that touches a secret file.
#
# Why this exists: Claude Code's settings.json `permissions.deny` rules for
# .env are documented as unreliable (the model has been observed reading denied
# files anyway). A PreToolUse hook actually fires before the tool runs, so this
# is the real gate. The deny rules + gitignore are backstops, not the defense.
#
# Contract: receives the tool call as JSON on stdin. Exit 2 = block (stderr is
# shown to the model). Exit 0 = allow.
set -euo pipefail

payload="$(cat)"

# Serialize the tool input so we catch the path whether it's a Read file_path,
# a Bash command, a Grep/Glob pattern, etc.
blob="$(printf '%s' "$payload" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(json.dumps(d.get("tool_input",{})))
except Exception:
    print("")' 2>/dev/null || echo "")"

# Protected patterns: .env / .env.* , secrets/ , .mcp.json , *.token , *.secret , credentials*
if printf '%s' "$blob" | grep -Eiq '\.env([^a-zA-Z0-9]|$)|\.env\.|/secrets/|(^|/)secrets/|\.token([^a-zA-Z0-9]|$)|\.secret([^a-zA-Z0-9]|$)|credentials'; then
  echo "BLOCKED by protect-secrets hook: reading secret files (.env, secrets/, *.token, *.secret, credentials*) is not permitted. These are not needed — credentials live with the MCP servers / OS keychain. See docs/secrets.md." >&2
  exit 2
fi

exit 0
