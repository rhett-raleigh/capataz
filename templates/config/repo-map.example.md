# repo-map (LOCAL — copy to config/repo-map.md, never commit)

Maps tracker items to the repo the coding agent should work in, and defines the
allowlist. The orchestrator will only touch repos listed here.

## Allowlist
Only these repos may be modified:

| Repo path | Notes |
|-----------|-------|
| ~/code/example-service | example only — replace |

## Ticket → repo mapping
How to pick a repo from a ticket. Use whatever signal your tracker gives.

| Match (project / component / label) | Repo path |
|-------------------------------------|-----------|
| PROJ / api                          | ~/code/example-service |
| PROJ / web                          | ~/code/example-web |

If a ticket matches nothing here, the agent stops and asks.
