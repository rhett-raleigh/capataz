#!/usr/bin/env bash
# SessionEnd hook — append a session-end line to memory/log.md so every
# session in this project (interactive or headless) leaves a trace that
# consolidate-memory can read. Must never block or fail session shutdown.
set -euo pipefail

PAYLOAD="$(cat)"
SID="$(printf '%s' "$PAYLOAD" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("session_id",""))' 2>/dev/null || true)"
REASON="$(printf '%s' "$PAYLOAD" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("reason",""))' 2>/dev/null || true)"

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
"$ROOT/bin/capataz-log" session-end "session ${SID:-unknown}${REASON:+ (${REASON})}" || true
exit 0
