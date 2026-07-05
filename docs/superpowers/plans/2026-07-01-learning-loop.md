# Learning Loop Activation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make capataz's designed-but-dormant learning loop actually run: mechanical logging to `memory/log.md`, a session-end hook, an explicit correction-capture convention, launchd scheduling templates for the recurring skills, and small doc-consistency fixes.

**Architecture:** Capataz is a Markdown-driven orchestrator with no application code — the only scripts live in `bin/` and `hooks/` (shell). Logging becomes mechanical via a shared `bin/capataz-log` helper called from the `bin/capataz` wrapper and a new `SessionEnd` hook, instead of relying on the model to remember to log. Scheduling ships as launchd *templates* plus an install script the user runs explicitly.

**Tech Stack:** Bash, launchd plists, Markdown. No test framework exists — verification is `bash -n`, `plutil -lint`, and running scripts against a temp checkout per CONTRIBUTING.md §6.

## Global Constraints

- **Privacy split (AGENTS.md §4):** never commit anything under `memory/`, `data/`, `config/`, `.env`, `.mcp.json`. Scripts may *write* to those paths at runtime; git must never track their contents.
- **Markdown-only engine (CONTRIBUTING.md §5/§7):** no Python/JS application code. Shell scripts are allowed only in `hooks/`, `bin/`, `raycast/`. (One-liner `python3 -c` JSON parsing inside a shell script is an established pattern — see `bin/capataz` — and is allowed.)
- **Commit format:** `<type>: <what changed>` with type ∈ {feat, fix, docs, chore, refactor}; one logical change per commit; end every commit message with `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- **Never load launchd agents during implementation.** Task 4 creates templates and an install script; running `bin/install-schedules` is the user's explicit action.
- **Log line format** (from `docs/memory-model.md`): `YYYY-MM-DD  <kind>  <detail>` — two-space separated, one line per entry, date in UTC.
- **`log.md` is append-only:** nothing in this plan may rewrite or delete existing `memory/log.md` content.
- **Stale-docs rule (docs/README.md):** when behavior changes, update the doc that describes it in the same task.

---

### Task 1: Mechanical run logging (`bin/capataz-log` + wrapper integration)

**Files:**
- Create: `bin/capataz-log`
- Modify: `bin/capataz` (async branch ~line 59, sync branch ~lines 61-74)
- Modify: `docs/memory-model.md` (the `memory/log.md` section)

**Interfaces:**
- Produces: `bin/capataz-log <kind> <detail...>` — appends one formatted line to `<repo>/memory/log.md`, creating the file with a header if missing; exits 0 on success, 1 on usage error. Task 2's hook calls this exact interface.

- [ ] **Step 1: Create `bin/capataz-log`**

```bash
#!/usr/bin/env bash
# capataz-log — append one line to memory/log.md, creating it if needed.
# Usage: capataz-log <kind> <detail...>
# Logging must be mechanical: wrappers and hooks call this so history exists
# even when the agent forgets to log. See docs/memory-model.md.
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
ROOT="$(cd "$(dirname "$SOURCE")/.." && pwd)"

KIND="${1:-}"
shift || true
DETAIL="${*:-}"
if [ -z "$KIND" ] || [ -z "$DETAIL" ]; then
  echo "usage: capataz-log <kind> <detail...>" >&2
  exit 1
fi

LOG="$ROOT/memory/log.md"
mkdir -p "$ROOT/memory"
if [ ! -f "$LOG" ]; then
  printf '# Log\n\nAppend-only history of runs and outcomes. See docs/memory-model.md.\n\n' > "$LOG"
fi

# Keep every entry on a single line.
DETAIL="$(printf '%s' "$DETAIL" | tr '\n\t' '  ')"
printf '%s  %s  %s\n' "$(date -u +%F)" "$KIND" "$DETAIL" >> "$LOG"
```

- [ ] **Step 2: Make it executable and syntax-check**

Run: `chmod +x bin/capataz-log && bash -n bin/capataz-log`
Expected: no output, exit 0.

- [ ] **Step 3: Functional test against the real repo memory dir**

`memory/log.md` does not exist yet on this machine, so exercise both the create and append paths, then restore state:

```bash
bin/capataz-log test "first entry — created file"
bin/capataz-log test "second entry — appended"
cat memory/log.md
bin/capataz-log test 2>&1 || echo "usage error exit=$?"
```

Expected: `memory/log.md` starts with the `# Log` header, then two lines matching `YYYY-MM-DD  test  ...`; the third call prints the usage message and `usage error exit=1`.

Then remove the test entries but **keep the file and header** (this seeds the real log):

```bash
grep -v '  test  ' memory/log.md > memory/log.md.tmp && mv memory/log.md.tmp memory/log.md
cat memory/log.md
```

Expected: only the header remains.

- [ ] **Step 4: Wire logging into `bin/capataz`**

In `bin/capataz`, replace the async branch body:

```bash
elif [ "$ASYNC" = true ]; then
  claude --bg -p "$PROMPT" --agent capataz --add-dir "$ROOT"
```

with:

```bash
elif [ "$ASYNC" = true ]; then
  claude --bg -p "$PROMPT" --agent capataz --add-dir "$ROOT"
  "$ROOT/bin/capataz-log" run-async "input: ${INPUT} (backgrounded)" || true
```

and in the sync branch, after the existing `printf ... >> data/sessions.log` line, add:

```bash
  SUMMARY="$(printf '%s' "${RES:-no result captured}" | head -c 200)"
  "$ROOT/bin/capataz-log" run "input: ${INPUT} | session: ${SID:-unknown} | result: ${SUMMARY}" || true
```

The `|| true` guards matter: logging must never fail a run.

- [ ] **Step 5: Syntax-check the wrapper**

Run: `bash -n bin/capataz`
Expected: no output, exit 0.

- [ ] **Step 6: Update `docs/memory-model.md`**

In the `### memory/log.md — append-only history` section, after the existing example block, add:

```markdown
Entries are written two ways: skills append their own outcome lines (per
their Output sections), and the machinery appends mechanically — `bin/capataz`
logs every `run` / `run-async`, and a `SessionEnd` hook logs every
`session-end` (see `hooks/log-session-end.sh`). Mechanical entries guarantee
history exists even when a session forgets to log. All writers go through
`bin/capataz-log`, which creates the file on first use.
```

- [ ] **Step 7: Commit**

```bash
git add bin/capataz-log bin/capataz docs/memory-model.md
git commit -m "feat: mechanical run logging to memory/log.md via bin/capataz-log"
```

---

### Task 2: SessionEnd hook

**Files:**
- Create: `hooks/log-session-end.sh`
- Modify: `.claude/settings.json` (add a `SessionEnd` entry to the existing `hooks` object)

**Interfaces:**
- Consumes: `bin/capataz-log <kind> <detail...>` from Task 1.
- Consumes (from Claude Code): SessionEnd hook stdin JSON with keys `session_id` and `reason`, and env var `CLAUDE_PROJECT_DIR`.

- [ ] **Step 1: Create `hooks/log-session-end.sh`**

```bash
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
```

- [ ] **Step 2: Make executable, syntax-check, functional test**

```bash
chmod +x hooks/log-session-end.sh && bash -n hooks/log-session-end.sh
echo '{"session_id":"test-hook-123","reason":"exit"}' | CLAUDE_PROJECT_DIR="$PWD" hooks/log-session-end.sh
tail -1 memory/log.md
echo 'not json' | CLAUDE_PROJECT_DIR="$PWD" hooks/log-session-end.sh; echo "malformed-input exit=$?"
```

Expected: tail shows `YYYY-MM-DD  session-end  session test-hook-123 (exit)`; the malformed-input call still exits 0 (logs `session unknown`). Then remove the two test lines (append-only applies to real entries, not test fixtures):

```bash
grep -v 'test-hook-123' memory/log.md | grep -v 'session unknown' > memory/log.md.tmp && mv memory/log.md.tmp memory/log.md
```

- [ ] **Step 3: Register the hook in `.claude/settings.json`**

Inside the existing `"hooks"` object (which currently has only `"PreToolUse"`), add a sibling key:

```json
"SessionEnd": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/hooks/log-session-end.sh"
      }
    ]
  }
]
```

Validate: `python3 -c 'import json;json.load(open(".claude/settings.json"))' && echo OK`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add hooks/log-session-end.sh .claude/settings.json
git commit -m "feat: SessionEnd hook logs every session to memory/log.md"
```

---

### Task 3: Correction-capture convention

**Files:**
- Modify: `AGENTS.md` (§5 Memory model)
- Modify: `docs/memory-model.md` (the `memory/log.md` section)
- Modify: `skills/consolidate-memory.md` (Procedure step 4, first bullet)

**Interfaces:**
- Produces: the log kind `correction` — a `memory/log.md` entry of the form `YYYY-MM-DD  correction  <what was wrong> → <what is right>`. Consolidation treats these as top-priority promotion candidates.

- [ ] **Step 1: Add the convention to `AGENTS.md` §5**

After the bullet ending "Not loaded whole.", add:

```markdown
- **Corrections are logged the moment they happen.** When the user corrects
  you — a wrong route, a wrong fact, a "no, do it this way" — immediately
  append a `correction` entry to `memory/log.md`:
  `YYYY-MM-DD  correction  <what was wrong> → <what is right>`.
  Don't wait for consolidation; a correction that isn't captured is a
  mistake you'll repeat.
```

- [ ] **Step 2: Add an example to `docs/memory-model.md`**

In the `### memory/log.md — append-only history` section, extend the existing fenced example block by adding this line inside it:

```
2026-06-26  correction   routed repo bug-report as task; user said engineering — prefer engineering when a repo is named
```

- [ ] **Step 3: Point consolidation at the marker**

In `skills/consolidate-memory.md`, Procedure step 4, change the first candidate bullet from:

```markdown
   - An explicit correction (the user told a session it was wrong about
     something)
```

to:

```markdown
   - An explicit correction — any `correction` entry (per AGENTS.md §5), or
     prose where the user told a session it was wrong about something
```

- [ ] **Step 4: Verify discovery consistency**

Run: `grep -n 'correction' AGENTS.md docs/memory-model.md skills/consolidate-memory.md`
Expected: hits in all three files, all describing the same `correction` kind and format.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md docs/memory-model.md skills/consolidate-memory.md
git commit -m "feat: correction-capture convention for memory/log.md"
```

---

### Task 4: Launchd scheduling templates + install script

**Files:**
- Create: `templates/launchd/com.capataz.morning-briefing.plist`
- Create: `templates/launchd/com.capataz.consolidate-memory.plist`
- Create: `bin/install-schedules`
- Create: `docs/scheduling.md`
- Modify: `docs/README.md` (Contents list)

**Interfaces:**
- Consumes: `bin/capataz "<instruction>"` (existing single entrypoint) — the plists invoke it directly.
- Produces: `bin/install-schedules` — substitutes `__CAPATAZ_ROOT__` in each template, writes to `~/Library/LaunchAgents/`, and loads via `launchctl`. **Not run during implementation.**

- [ ] **Step 1: Create `templates/launchd/com.capataz.morning-briefing.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.capataz.morning-briefing</string>
  <key>ProgramArguments</key>
  <array>
    <string>__CAPATAZ_ROOT__/bin/capataz</string>
    <string>Run the morning-briefing skill for today.</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>7</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>__CAPATAZ_ROOT__/data/launchd/morning-briefing.log</string>
  <key>StandardErrorPath</key>
  <string>__CAPATAZ_ROOT__/data/launchd/morning-briefing.err</string>
</dict>
</plist>
```

- [ ] **Step 2: Create `templates/launchd/com.capataz.consolidate-memory.plist`**

Identical structure with these differences: `Label` and filename use `com.capataz.consolidate-memory`; the instruction string is `Run the consolidate-memory skill.`; `Hour` is `21`, `Minute` is `30`; log paths use `consolidate-memory.log` / `consolidate-memory.err`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.capataz.consolidate-memory</string>
  <key>ProgramArguments</key>
  <array>
    <string>__CAPATAZ_ROOT__/bin/capataz</string>
    <string>Run the consolidate-memory skill.</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>21</integer>
    <key>Minute</key>
    <integer>30</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>__CAPATAZ_ROOT__/data/launchd/consolidate-memory.log</string>
  <key>StandardErrorPath</key>
  <string>__CAPATAZ_ROOT__/data/launchd/consolidate-memory.err</string>
</dict>
</plist>
```

- [ ] **Step 3: Lint both plists**

Run: `plutil -lint templates/launchd/*.plist`
Expected: `... OK` for both files.

- [ ] **Step 4: Create `bin/install-schedules`**

```bash
#!/usr/bin/env bash
# install-schedules — install capataz's launchd schedules for this machine.
# Copies templates/launchd/*.plist to ~/Library/LaunchAgents with this repo's
# absolute path substituted, then (re)loads them. Idempotent; run again after
# moving the repo or editing a template. Uninstall:
#   launchctl unload ~/Library/LaunchAgents/com.capataz.*.plist
#   rm ~/Library/LaunchAgents/com.capataz.*.plist
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
ROOT="$(cd "$(dirname "$SOURCE")/.." && pwd)"

mkdir -p "$HOME/Library/LaunchAgents" "$ROOT/data/launchd"

shopt -s nullglob
TEMPLATES=("$ROOT"/templates/launchd/*.plist)
if [ ${#TEMPLATES[@]} -eq 0 ]; then
  echo "install-schedules: no templates found in templates/launchd/" >&2
  exit 1
fi

for T in "${TEMPLATES[@]}"; do
  NAME="$(basename "$T")"
  DEST="$HOME/Library/LaunchAgents/$NAME"
  sed "s|__CAPATAZ_ROOT__|$ROOT|g" "$T" > "$DEST"
  plutil -lint "$DEST" >/dev/null
  launchctl unload "$DEST" 2>/dev/null || true
  launchctl load "$DEST"
  echo "installed + loaded $NAME"
done

echo ""
echo "Check status:  launchctl list | grep com.capataz"
echo "Run logs:      $ROOT/data/launchd/"
```

- [ ] **Step 5: Make executable and syntax-check ONLY (do not run)**

Run: `chmod +x bin/install-schedules && bash -n bin/install-schedules`
Expected: no output, exit 0. **Do not execute `bin/install-schedules` — loading schedules is the user's explicit action (global constraint).**

- [ ] **Step 6: Create `docs/scheduling.md`**

```markdown
# Scheduling — proactive runs

Capataz becomes an assistant (rather than a tool you poke) when its recurring
skills run unattended. On macOS the native mechanism is **launchd**; the
templates in `templates/launchd/` schedule:

| Schedule | Skill | When |
|----------|-------|------|
| `com.capataz.morning-briefing` | `morning-briefing` | daily 07:00 |
| `com.capataz.consolidate-memory` | `consolidate-memory` | daily 21:30 |

Both go through `bin/capataz`, the single entrypoint (docs/invocation.md), so
scheduled runs behave identically to manual ones and land in
`data/sessions.log` and `memory/log.md` like any other run.

## Install

```bash
bin/install-schedules
```

The script substitutes this repo's absolute path into the templates, writes
them to `~/Library/LaunchAgents/`, and loads them. It is idempotent — re-run
it after moving the repo or editing a template.

## Verify

```bash
launchctl list | grep com.capataz     # both labels listed
ls data/launchd/                      # stdout/stderr of each run
```

## Change the cadence

Edit the `StartCalendarInterval` dict in the template (see `man launchd.plist`
for forms like weekday-only), then re-run `bin/install-schedules`.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.capataz.*.plist
rm ~/Library/LaunchAgents/com.capataz.*.plist
```

## Notes

- launchd runs jobs missed while the machine slept as soon as it wakes; a
  closed laptop at 07:00 still gets its briefing on wake.
- The installed plists live outside the repo and contain a machine-specific
  path — that's why the repo tracks only `__CAPATAZ_ROOT__` templates
  (privacy split, AGENTS.md §4).
```

- [ ] **Step 7: Index the new doc**

In `docs/README.md` Contents list, after the `invocation.md` line, add:

```markdown
- `scheduling.md` — launchd setup for recurring skill runs
```

- [ ] **Step 8: Commit**

```bash
git add templates/launchd bin/install-schedules docs/scheduling.md docs/README.md
git commit -m "feat: launchd scheduling templates for morning-briefing and consolidate-memory"
```

---

### Task 5: Doc-consistency fixes (three independent one-line/one-block fixes, three commits)

**Files:**
- Modify: `capabilities/classify.md:8`
- Modify: `CONTRIBUTING.md` (Capabilities section, stale §8 reference)
- Modify: `skills/consolidate-memory.md` (add frontmatter per `skills/_template.skill.md`)

**Interfaces:** none — documentation only.

- [ ] **Step 1: Fix the lane count in `capabilities/classify.md`**

Change line 8 from:

```markdown
Sort an incoming input into one of three lanes:
```

to:

```markdown
Sort an incoming input into one of four lanes:
```

Commit:

```bash
git add capabilities/classify.md
git commit -m "fix: classify.md says four lanes, matching its own table"
```

- [ ] **Step 2: Fix the stale section reference in `CONTRIBUTING.md`**

In the Capabilities section, change:

```markdown
A capability is a reusable building block that skills compose (e.g. `classify`,
`code-handoff`). Same format conventions as skills but indexed in `AGENTS.md` §8.
```

to:

```markdown
A capability is a reusable building block that skills compose (e.g. `classify`,
`code-handoff`). Same format conventions as skills but indexed in `AGENTS.md` §9.
```

Commit:

```bash
git add CONTRIBUTING.md
git commit -m "docs: fix stale capability-index reference (AGENTS.md §8 → §9)"
```

- [ ] **Step 3: Normalize `skills/consolidate-memory.md` frontmatter**

First read `skills/_template.skill.md` to confirm the exact frontmatter field set. Then replace the top of `skills/consolidate-memory.md` — everything from line 1 through the `---` separator line that follows the "Skill index line" preamble (lines 1–8) — with:

```markdown
---
name: consolidate-memory
description: Promote durable signals from memory/log.md into memory/learned.md, then prune. Scheduled via launchd; safe to also run on demand. Degrades gracefully if log.md has nothing new since last run.
requires: []
profiles: []
---

# consolidate-memory
```

The `## Intent` section and everything after it stays unchanged. (The skill-index line already exists in `AGENTS.md` §7, so the preamble duplicating it is dropped.)

Verify: `head -12 skills/consolidate-memory.md` matches the block above, and `grep -c '^---$' skills/consolidate-memory.md` returns `2`.

Commit:

```bash
git add skills/consolidate-memory.md
git commit -m "docs: normalize consolidate-memory skill to template frontmatter"
```

---

## Out of scope (explicitly)

- The `--async` auth-conflict investigation (`data/tasks/*.err`) — needs debugging, not mechanical implementation.
- Slack/event triggers, self-review skill, open-loops sweep — future iterations.
- Pruning stale `.claude/worktrees/` — local state, handled outside the PR.
- Running `bin/install-schedules` — the user activates schedules explicitly.
