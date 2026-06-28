# Idea: VOICE.md — Personalizing agent communication style

**Date:** 2026-06-28
**Status:** Captured
**Inspired by:** Hermes AI agent

## What

A `VOICE.md` file that the orchestrator reads at startup alongside `AGENTS.md`.
It influences *how* the agent communicates without changing *what* it does —
letting users define tone, vocabulary, formality, personality traits, and
response style so the agent feels like *their* assistant rather than a stock AI.

Possible contents:

- **Tone** — casual, professional, terse, warm, dry humor, etc.
- **Formality level** — contractions, slang, hedging vs. directness.
- **Vocabulary preferences** — domain jargon to use or avoid, preferred terms.
- **Personality traits** — encouraging, blunt, Socratic, collaborative.
- **Response length** — brief by default, detailed when asked, etc.
- **Examples** — sample responses that capture the desired voice.

## Why it matters

Capataz currently has no mechanism for users to shape the orchestrator's tone or
personality. Every user gets the same generic assistant voice. Separating voice
from capabilities (AGENTS.md) and tool config (CLAUDE.md) keeps concerns clean.

## Open questions

- Tracked or gitignored? Personal preference suggests gitignored, but teams
  might want a shared voice. Maybe support both with a merge order.
- Format — free-form prose vs. structured fields vs. both?
- Scope — per-machine (`config/voice.md`), per-project (repo root), or layered?
- Boundaries — voice should influence style, not override safety rules.

## Prior art

- **Hermes AI** — uses a voice/persona file to shape agent communication.
- **Claude's `CLAUDE.md`** — supports tone hints but mixed with technical instructions.
- **Custom GPTs** — OpenAI's system prompt customization serves a similar role.
