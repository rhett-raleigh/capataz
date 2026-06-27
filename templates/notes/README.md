# Notes vault template

Quick-start scaffold for the notes system. Copy these files to set up your vault.

## Setup

1. Copy the config file and edit it:

   ```bash
   cp templates/notes/config/notes.example.yaml config/notes.yaml
   # Edit config/notes.yaml — set vault_path and optionally obsidian_vault
   ```

2. Bootstrap the vault directory:

   ```bash
   cp -r templates/notes/vault/ data/notes/
   ```

   Or, if you want to use an existing Obsidian vault, point `vault_path` in
   your config at it. The agent will create `ideas/`, `reflections/`, `goals/`
   subdirectories and an `index.md` inside it on first use.

3. Start using it:

   - "Log an idea: habit tracker app"
   - "I have an idea I want to think through"
   - "Add a goal: ship my side project by end of Q3"
   - "Let's do a weekly reflection"
   - "What ideas have I logged?"

## What's in this template

```
config/
  notes.example.yaml   ← copy to config/notes.yaml
vault/
  ideas/               ← idea notes go here
  reflections/         ← weekly reflections go here
  goals/               ← goal tracking notes go here
  index.md             ← auto-maintained table of contents
```
