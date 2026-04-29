# Always-resumable Claude Code on the Mac mini

Slot-based wrappers around Claude Code's native session persistence.
**No daemon, no tmux, no LaunchAgent.** Sessions live as on-disk JSONL
transcripts in `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl` and are
resumed on demand by stable UUID.

## Model

- A "slot" is a stable UUID registered in `~/.claude-code/slots.json`.
- Slot N → UUID is fixed forever; resuming slot N always picks up the same conversation.
- The actual conversation transcript lives at
  `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl` and persists indefinitely.
- `claude --resume <uuid>` re-attaches to a saved conversation.
- `claude --session-id <uuid>` starts a fresh conversation pinned to that UUID.
- The wrappers pick the right one for you (resume if transcript exists, else create).

## Commands (in `~/.local/bin/`, on PATH via dot_zshenv — works under non-interactive ssh)

```
claude-init [N]      # pre-populate N slots (default 4) — run once after install
claude-list          # show slots, transcript path, last-modified, line count
claude-attach <N>    # resume slot N (creates with that UUID if first time)
claude-new [name]    # next free slot index, generates UUID, registers, launches
claude-kill <N>      # remove from slot map (transcript preserved on disk)
```

## Remote attach

LAN, mosh-wrapped (resilient — preserves PTY across network drops, in-flight Claude responses keep streaming):

```
mosh ctr26@Craigs-Mac-mini.lan -- claude-attach 1
```

Plain SSH (no PTY persistence — drops can lose the tail of an in-flight response, though the saved transcript catches up to whatever was flushed):

```
ssh ctr26@Craigs-Mac-mini.lan -t claude-attach 1
```

Inside Claude: exit cleanly with `/quit` (or `Ctrl+D` on an empty prompt). Transcript is auto-flushed.

## Off-LAN (internet)

Tailscale is the recommended path — auth-by-identity, no port-forwarding. Not installed by this setup. When ready:

```
brew install --cask tailscale
```

then auth via `tailscale up` and use the magic-DNS hostname in place of `Craigs-Mac-mini.lan`.

## Why this layout

- **Native sessions persist on disk regardless** of any wrapper, so there's nothing for a LaunchAgent to keep alive. The earlier tmux+LaunchAgent design fought reality; this doesn't.
- **mosh** for SSH-drop resilience: it preserves the PTY at the network layer, so an in-flight Claude response keeps streaming even after a brief network blip. tmux is *also* a way to do this, but adds a multiplexer dependency for no extra benefit when sessions are already on disk.
- **Slot map is git-tracked via chezmoi.** The UUID *registry* survives a machine rebuild; the transcripts (`~/.claude/projects/...`) don't and shouldn't — they're per-machine state.

## Files (chezmoi-managed)

| Target | chezmoi source |
|---|---|
| `~/.local/bin/claude-{init,list,attach,new,kill}` | `dot_local/bin/executable_claude-*` |
| `~/.claude-code/README.md` | `dot_claude-code/README.md` |
| `~/.claude-code/slots.json` | NOT chezmoi-tracked (per-machine state) |

## Operations

Inspect or edit a slot's working dir / display name: edit `~/.claude-code/slots.json`. Schema:

```json
{
  "version": 1,
  "slots": {
    "1": {"uuid": "<uuid>", "name": "slot-1", "cwd": "/Users/ctr26"}
  }
}
```

Read a transcript without launching Claude:

```
jq -r '.message.content[0].text // .summary // empty' ~/.claude/projects/*/<uuid>.jsonl | less
```

Delete a transcript permanently:

```
claude-kill <N>                                              # remove slot
rm ~/.claude/projects/*/<uuid>.jsonl                         # remove transcript
```
