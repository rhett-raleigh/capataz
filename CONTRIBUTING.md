# Contributing to Capataz

Instructions for coding agents (and humans) working **on** this system. This is
distinct from `AGENTS.md`, which instructs the orchestrator agent that **runs**
the system.

---

## 1. Architecture at a glance

Capataz is a Markdown-driven orchestrator. There is no application code to
compile — the "engine" is a set of Markdown files that any AGENTS.md-aware agent
reads and follows.

```
AGENTS.md              ← runtime instructions for the orchestrator
CLAUDE.md              ← Claude-specific pointer to AGENTS.md
CONTRIBUTING.md        ← you are here (dev instructions)

skills/                ← pluggable behaviors (one .md per skill)
capabilities/          ← reusable building blocks skills compose
docs/                  ← design docs, specs, guides
templates/             ← starter files for new installs
hooks/                 ← shell hooks (e.g. secret protection)
bin/                   ← entry points (CLI wrappers)
raycast/               ← Raycast integration scripts
setup/                 ← setup config (Claude settings, etc.)

memory/  data/  config/   ← local-only, gitignored, never touch in PRs
```

## 2. The privacy boundary

The single most important rule: **tracked files are public, local files are
private.**

| Path | Tracked | Contains |
|------|---------|----------|
| `skills/`, `capabilities/`, `docs/`, `templates/` | Yes | Generic, shareable engine logic |
| `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md` | Yes | Instructions |
| `memory/`, `data/`, `config/`, `.env`, `.mcp.json` | **No** | Personal data, secrets, machine config |

Never write personal content, secrets, API keys, employer-specific details, or
user data into tracked files. If your change references something
machine-specific, resolve it from `config/` or `.env` at runtime.

## 3. What you can change and how

### Skills (`skills/`)

A skill is one Markdown file following the template in `skills/_template.skill.md`.

To add a skill:
1. Copy `skills/_template.skill.md` → `skills/<name>.md`.
2. Fill in the frontmatter (`name`, `description`, `requires`, `profiles`).
3. Write the `When to use`, `Inputs`, `Steps`, `Output`, and `Safety` sections.
4. Add a one-line entry to the **Skill index** in `AGENTS.md` §7.
5. Commit as a single, reviewable change.

Keep skills generic. Anything machine-specific belongs in `config/`, not the
skill file.

### Capabilities (`capabilities/`)

A capability is a reusable building block that skills compose (e.g. `classify`,
`code-handoff`). Same format conventions as skills but indexed in `AGENTS.md` §8.

### Docs (`docs/`)

Design documents, specs, and guides. Update when the behavior they describe
changes — stale docs are worse than no docs.

### Templates (`templates/`)

Starter files users copy into their local `config/` and `memory/` on first
setup. Keep them minimal and well-commented.

### Core files (`AGENTS.md`, `CLAUDE.md`)

Changes to these affect every user on every machine. Treat them with extra care:
- Keep changes small and isolated.
- Explain the *why* in the commit message.
- Never remove safety rules (§4) without explicit owner approval.

### Hooks and scripts (`hooks/`, `bin/`, `raycast/`, `setup/`)

Shell scripts and integration glue. These are the only "code" in the repo. Test
them on your machine before committing.

## 4. Commit conventions

- One logical change per commit.
- Commit message format: `<type>: <what changed>` where type is one of `feat`,
  `fix`, `docs`, `chore`, `refactor`.
- Self-edits by the agent (new skills, capability updates) must be isolated
  commits so the owner can review and revert individually.

## 5. What NOT to do

- Don't add application code, build systems, or package managers. The engine is
  Markdown files read by external agents — keep it that way.
- Don't hardcode repo paths, API endpoints, tracker URLs, or anything
  machine-specific into tracked files.
- Don't modify `.gitignore` to expose `memory/`, `data/`, or `config/`.
- Don't auto-merge PRs. Open them; a human merges.
- Don't create files outside the established directory structure without
  discussing it first.

## 6. Testing your changes

There is no test suite — the "tests" are:
1. **Syntax**: the Markdown parses correctly and follows the expected structure.
2. **Discovery**: the orchestrator can find and load your change (index entries
   match filenames, frontmatter is valid).
3. **Isolation**: your change doesn't leak private content into tracked files.
4. **Dry run**: invoke the orchestrator and verify it picks up the new
   skill/capability correctly.

## 7. For AI coding agents specifically

You were likely invoked via the code-handoff capability to work on this repo.
Keep these in mind:

- **Read `AGENTS.md` §4 first.** The safety rules are non-negotiable.
- **You are editing the orchestrator's brain.** A bad skill file can cause the
  orchestrator to misroute work. Be precise in your `When to use` descriptions.
- **Scope your changes.** If asked to add a skill, add the skill — don't
  reorganize the repo or "improve" unrelated files.
- **Respect the Markdown-only constraint.** If you find yourself wanting to write
  Python/JS/etc to solve something, stop and reconsider. The only scripts live in
  `hooks/`, `bin/`, and `raycast/` — and those are shell scripts.
- **Commit messages matter.** The owner reviews every change in git. Make your
  intent clear.
