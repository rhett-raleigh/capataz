# Raycast Integration

A Raycast Script Command that lets you send a Slack link, ticket reference, or
plain instruction to the Capataz orchestrator from anywhere on your Mac.

## Setup

1. Open Raycast and go to **Extensions > Script Commands**.
2. Click **Add Script Directory** and select this `raycast/` folder.
3. Open `capataz.sh` and set `CAPATAZ_DIR` to the absolute path of your Capataz
   clone:

   ```bash
   CAPATAZ_DIR="$HOME/projects/capataz"   # <-- edit to your clone path
   ```

4. Make sure the script is executable:

   ```bash
   chmod +x raycast/capataz.sh
   ```

The command will appear in Raycast as **Capataz**. Type your input (a Slack
link, ticket ref, or instruction) and it will be passed to `bin/capataz`.
