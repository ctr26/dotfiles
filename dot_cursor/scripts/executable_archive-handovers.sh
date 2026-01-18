#!/bin/bash
# Archive handover files older than N days
# Usage: archive-handovers.sh [days] [path]
# Defaults: 7 days, current directory

DAYS="${1:-7}"
TARGET="${2:-.}"

# Ensure archive directory exists
mkdir -p "$TARGET/CLAUDE/archive"

# Find and move old handover files
count=$(find "$TARGET/CLAUDE" -maxdepth 1 -name "HO-*.md" -mtime +"$DAYS" 2>/dev/null | wc -l | tr -d ' ')

if [ "$count" -gt 0 ]; then
    echo "Archiving $count handover files older than $DAYS days..."
    find "$TARGET/CLAUDE" -maxdepth 1 -name "HO-*.md" -mtime +"$DAYS" -exec mv {} "$TARGET/CLAUDE/archive/" \;
    echo "Done. Files moved to $TARGET/CLAUDE/archive/"
else
    echo "No handover files older than $DAYS days found."
fi

# Report archive size
if [ -d "$TARGET/CLAUDE/archive" ]; then
    archive_count=$(ls -1 "$TARGET/CLAUDE/archive/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "Archive contains $archive_count files."
fi

