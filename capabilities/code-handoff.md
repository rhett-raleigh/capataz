# Capability: code-handoff

How the orchestrator turns a tracked engineering task into a PR — **without**
bloating its own context or running unsupervised.

## Principle
The orchestrator does **not** write the code itself. It spins up an **isolated
coding agent** with its own clean checkout, its own permission scope, and its own
context, then collects the result. Isolation means a bad run is contained.

## Recommended mechanism
Run the coding agent **headless in a subprocess** (e.g. a `claude -p "…"` or
equivalent CLI invocation) pointed at the target repo, rather than coding inline.
Reasons: clean context, scoped permissions, and you can background it so the
trigger (Raycast/Slack) gets a fast response while the code runs.

> Graduate to a programmatic SDK sub-agent only if you later need tight control
> over the coding loop (custom tool gating, streamed progress). Start headless.

## Steps
1. **Resolve the repo.** Map the ticket (project/component/label) to a repo path
   via `config/repo-map.*`. If unmapped → stop and ask. Only repos on the
   allowlist are permitted (AGENTS.md §4).
2. **Confirm.** Post "I'll create branch X in repo Y to implement TICKET — go?"
   and wait, unless the user has marked this flow trusted.
3. **Branch.** `git checkout -b <ticket>-<slug>` in a fresh checkout.
4. **Hand off.** Invoke the coding agent headless with the ticket body + acceptance
   criteria as the prompt. Background it so the trigger returns immediately.
5. **Open a PR.** On success, push and open a PR (never auto-merge). Link the PR
   to the ticket.
6. **Report back.** Reply in the source thread with the ticket + PR links, and
   append the outcome to `memory/log.md`.

## Safety
- Allowlisted repos only; never auto-merge; confirm before first code on any new
  flow. Secrets come from `.env`/local config, never from tracked files.
