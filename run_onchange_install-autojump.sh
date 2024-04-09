#!/bin/sh

AUTOJUMP_DIR="$HOME/.local/share/autojump"

if [ ! -d "$AUTOJUMP_DIR" ]; then
  git clone https://github.com/wting/autojump.git "$AUTOJUMP_DIR"
else
  echo "Autojump already cloned."
fi

cd "$AUTOJUMP_DIR"
./install.py
