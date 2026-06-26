#!/usr/bin/env bash
#
# Raycast Script Command — paste a Slack link / ticket / instruction and go.
# Install: Raycast → Extensions → Script Commands → add this folder.
# Then edit CAPATAZ_DIR below to your clone path.
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Capataz
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Slack link / ticket / instruction" }
# @raycast.packageName Capataz
#
# Documentation:
# @raycast.description Send an input to the orchestrator agent.
# @raycast.author you

CAPATAZ_DIR="$HOME/projects/capataz"   # <-- edit to your clone path

exec "$CAPATAZ_DIR/bin/capataz" "$1"
