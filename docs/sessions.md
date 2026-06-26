# Sessions — seeing what the agent did

Because you're running on Claude Code, **every run is a session** with a full
transcript — including headless runs fired from Raycast. You can browse, resume,
and inspect them.

## Browse / resume

```bash
claude --resume            # interactive picker: summaries, timestamps, branch
claude -c                  # continue the most recent session
claude -r <session-id>     # resume a specific session
claude -r <session-id> -p "what did you change and why?"   # headless follow-up
```

## Where transcripts live

```
~/.claude/projects/<project>/<session-id>.jsonl
```

One JSON object per line (messages, tool calls, results). `/export` inside a
session copies or writes a readable transcript.

## Finding the session for a given trigger

`bin/capataz` captures the session id of each headless run and appends it to
a gitignored log:

```
data/sessions.log     # <timestamp>  <session-id>  <input>
```

So after a Raycast trigger you can do:

```bash
tail data/sessions.log              # find the id for what you just ran
claude --resume <that-id>           # open it in Claude to review/continue
```

The wrapper also prints `↳ session <id>` and the resume command in its output.

## Tip

For an at-a-glance view, the session log plus `claude --resume` is usually
enough. If you want richer history later, a small script can parse the JSONL
transcripts into a digest — but start with the built-ins.
