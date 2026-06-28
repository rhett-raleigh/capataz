# ADR-000: Use ADR format for decisions

**Date:** 2026-06-27
**Status:** Accepted

## Context

We need a lightweight way to record architectural and process decisions so
future contributors (human or agent) understand *why* things are the way they
are, not just *what* they are.

## Decision

Use numbered ADR (Architecture Decision Record) files in `notes/decisions/`.
Each file captures context, the decision, and consequences.

## Consequences

- Decisions are discoverable via `ls notes/decisions/`.
- Git history provides the changelog; no separate log needed.
- New decisions copy `_template.md` in the same directory.
