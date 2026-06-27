# VOICE.md — Personalizing agent communication style

**Status:** Idea
**Inspired by:** Hermes AI agent

## Problem

Capataz currently has no mechanism for users to shape the orchestrator's tone,
vocabulary, or personality. Every user gets the same generic assistant voice.
A `VOICE.md` file would let users define how the agent communicates — making it
feel like *their* assistant rather than a stock AI.

## Concept

A `VOICE.md` file (or similar) that the orchestrator reads at startup alongside
`AGENTS.md`. It influences *how* the agent communicates without changing *what*
it does.

Possible contents:

- **Tone** — casual, professional, terse, warm, dry humor, etc.
- **Formality level** — contractions, slang, hedging vs. directness.
- **Vocabulary preferences** — domain jargon to use or avoid, preferred terms.
- **Personality traits** — encouraging, blunt, Socratic, collaborative.
- **Response length** — brief by default, detailed when asked, etc.
- **Examples** — sample responses that capture the desired voice.

## Open questions

- **Tracked or gitignored?** Voice preferences feel personal (gitignored), but
  a team might want a shared voice for a project (tracked). Maybe support both
  with a merge order.
- **Format** — free-form prose ("talk to me like a senior engineer who's had too
  much coffee") vs. structured fields vs. both?
- **Scope** — per-machine (`config/voice.md`), per-project (`VOICE.md` in
  repo root), or both with layering?
- **Boundaries** — the voice file should influence style, not override safety
  rules or capability constraints.

## Prior art

- **Hermes AI** — uses a voice/persona file to shape agent communication.
- **Claude's `CLAUDE.md`** — already supports tone hints but mixed in with
  technical instructions; a dedicated file separates concerns.
- **Custom GPTs** — OpenAI's system prompt customization serves a similar role.
