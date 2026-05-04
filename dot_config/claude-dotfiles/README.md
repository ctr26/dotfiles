# claude-dotfiles

The "specific manager for Claude stuff" — a `justfile` that owns
`~/.claude/settings.json` and lets you switch Claude profiles per persona.

## Quick start

```sh
cd ~/.config/claude-dotfiles
just                    # list recipes + show active profile
just init               # one-time: seed _base.json from your current settings
just preview professional   # show the merged settings without writing
just profile personal       # switch active profile (writes ~/.claude/settings.json)
just doctor             # validate
```

## Profile model

- `profiles/_base.json` — common defaults (everyone gets these)
- `profiles/<name>.json` — persona overrides (deep-merged onto base via `jq -s '.[0] * .[1]'`)

`just profile <name>` writes the merged result to `~/.claude/settings.json`.
A backup of the previous file lands at `~/.claude/settings.json.pre-claudejust`
(only created once, so subsequent switches don't clobber it).

## Migration from chezmoi

Today `~/.claude/settings.json` is also written by chezmoi (`dot_claude/settings.json`).
Run `just migrate` to see the manual steps for handing ownership over.

## Wired into persona switching

The `persona <name>` shell function (defined in Home Manager's
`modules/persona-loader.nix`) calls `just profile <name>` automatically
whenever you switch personas. So `persona personal` ⇒ Claude profile
also flips to personal.
