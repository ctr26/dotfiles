#!/usr/bin/env sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
session_name=$(echo "$input" | jq -r '.session_name // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
worktree=$(echo "$input" | jq -r '.worktree.path // empty')

# Directory relative to home
dir=$(echo "${cwd:-$(pwd)}" | sed "s|^$HOME|~|")

# Git branch
branch=$(git -C "${cwd:-$(pwd)}" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

# Elapsed time (h:mm:ss format)
elapsed=""
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
  total_s=$((duration_ms / 1000))
  h=$((total_s / 3600))
  m=$(( (total_s % 3600) / 60 ))
  s=$((total_s % 60))
  if [ "$h" -gt 0 ]; then
    elapsed=$(printf "%d:%02d:%02d" "$h" "$m" "$s")
  else
    elapsed=$(printf "%d:%02d" "$m" "$s")
  fi
fi

# Context bar (10 chars wide)
bar=""
if [ "$used" -gt 0 ] 2>/dev/null; then
  filled=$((used / 10))
  empty=$((10 - filled))
  bar_fill=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar_empty=$(printf '%*s' "$empty" '' | tr ' ' '░')
  bar="${bar_fill}${bar_empty}"
fi

# Catppuccin Mocha palette
MAUVE='\033[38;2;203;166;247m'
BLUE='\033[38;2;137;180;250m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
SUBTEXT='\033[38;2;166;173;200m'
OVERLAY='\033[38;2;108;112;134m'
RESET='\033[0m'

# Single line: dir branch elapsed worktree │ model bar %
out="${SUBTEXT}${dir}${RESET}"
[ -n "$branch" ] && out="${out} ${BLUE}${branch}${RESET}"
[ -n "$elapsed" ] && out="${out} ${YELLOW}${elapsed}${RESET}"
[ -n "$worktree" ] && out="${out} ${MAUVE}wt:$(basename "$worktree")${RESET}"
out="${out} ${OVERLAY}│${RESET}"
[ -n "$model" ] && out="${out} ${OVERLAY}${model}${RESET}"
[ -n "$bar" ] && out="${out} ${SUBTEXT}${bar}${RESET} ${OVERLAY}${used}%%${RESET}"

# Update tmux window name
if [ -n "$TMUX" ]; then
  if [ -n "$session_name" ]; then
    tmux rename-window "${session_name}" 2>/dev/null
  else
    tmux rename-window "$(basename "${cwd:-$(pwd)}")" 2>/dev/null
  fi
fi

printf "${out}\n"
