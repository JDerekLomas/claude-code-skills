---
name: cmux-conductor
description: Orchestrate cmux from Claude Code — lay out a standard workspace board and supervise long-running panes (OCR/translation batches, deploys, PR babysitting) so a tab rings + you get pinged when a job finishes, errors, or needs input. Use when asked to set up a cmux layout, watch/babysit a cmux pane or job, or "let me drive cmux."
---

# cmux-conductor

Drives the **cmux** terminal's control CLI (`cmux`, over `/tmp/cmux.sock`) to
solve the "~10 sessions I can't tell apart + I forget to check on long jobs"
problem. Two pieces: a board **bootstrapper** and a pane **supervisor**.

## Prerequisite: socket access

The `cmux` CLI needs to be allowed to talk to the socket. Two ways:

1. **Ancestry (default, no setup)** — run from a shell/Claude *inside a cmux
   pane*. It's auto-authed because it's a child of cmux. This is the preferred
   long-term pattern: run the conductor from a cmux pane and nothing needs
   opening.
2. **External access** — to drive cmux from an *outside* shell (e.g. a Claude
   Code session in Ghostty), open the socket to your macOS user. Do it in one
   command (no Settings trip, no relaunch — **verified** to apply live in ~3s):

       ~/.claude/skills/cmux-conductor/socket-mode.sh automation   # open to your user
       ~/.claude/skills/cmux-conductor/socket-mode.sh descendants  # lock back down
       ~/.claude/skills/cmux-conductor/socket-mode.sh status       # show current mode

   (Equivalent to Settings ⌘, → Advanced → Automation socket. The mode is just
   the `com.cmuxterm.app` UserDefaults key `socketControlMode`; values
   `automation` / `password` / `open` / `disabled`, or delete-key = the secure
   `descendants` default. Avoid `open` — world-readable.) So the conductor can
   open the socket, do its work, and close it again, all programmatically.

Check it's live: `cmux ping` should print `PONG`.

## Bootstrap a board — `rig.sh`

    ~/.claude/skills/cmux-conductor/rig.sh          # create any missing workspaces
    ~/.claude/skills/cmux-conductor/rig.sh --list   # show current board, create nothing

Idempotent by workspace title — re-running only fills gaps, never duplicates.
Two arrays at the top of `rig.sh`:
- `SPECS` — work workspaces (title | shell command | optional browser URL).
  Default: sourcelibrary, pipeline, ops, and a `web` workspace with a browser
  pane on the admin system-map.
- `AGENTS` — one workspace per CLI agent (title | cli | launch cmd | hint).
  Default: claude, opencode, hermes, makemode. Each pane launches the agent if
  its CLI is on PATH, else drops to a shell with the install hint — so agents
  you install later (hermes, makemode) light up on the next run with no edits.
  cmux is agent-agnostic, so `watch.sh` supervises any of these panes the same.

## Supervise a pane — `watch.sh`

    ~/.claude/skills/cmux-conductor/watch.sh --surface surface:3 --label "OCR batch"

Reads the pane's screen on an interval and emits ONE stdout line per state
change: `ACTIVE`, `DONE` (returned to a shell prompt), `NEEDS-INPUT` (waiting
on a y/n or permission prompt), `ERROR`. Each transition also rings the cmux
tab and pops a macOS notification.

Flags: `--surface` (required; find with `cmux --json list-pane-surfaces`),
`--workspace`, `--label`, `--interval` (default 5s), `--idle-ticks` (default 2).

**Compose with the Monitor tool** so transitions become chat events an
orchestrating Claude can act on — e.g. PushNotification the user on
`NEEDS-INPUT` / `ERROR`:

    Monitor(command: "~/.claude/skills/cmux-conductor/watch.sh --surface surface:3 --label 'OCR batch'",
            description: "cmux OCR pane state", persistent: true)

## CLI cheat-sheet / gotchas

- `cmux help` lists everything. Handy: `list-workspaces`, `list-pane-surfaces`,
  `new-workspace`, `new-split left|right|up|down`,
  `new-pane --type terminal|browser --url ...`, `send`, `send-key`,
  `read-screen`, `notify`, `close-workspace`.
- **Only `list-*` commands honor `--json`.** Write commands return plain
  `OK <refs>` (e.g. `OK surface:4 pane:4`). Pattern: fire the write, parse the
  refs from the reply (`lib.sh` has `ref_of` / `uuid_of` helpers).
- macOS ships **bash 3.2** — these scripts avoid bash-4 features. `timeout(1)`
  is absent; `lib.sh`'s `rc()` uses a perl `alarm` wrapper so a hung `cmux`
  call can't stall the loop.
- Also turn on cmux → Settings → **Claude Code Hooks** so every CC session's
  tab rings natively on stop/needs-input — complements the supervisor.

## Files

- `lib.sh` — shared helpers (`rc` timeout wrapper, `ref_of`, `uuid_of`, `notify`)
- `rig.sh` — board bootstrapper (edit `SPECS`)
- `watch.sh` — pane supervisor
- `socket-mode.sh` — open/close the control socket via UserDefaults (live, no relaunch)
