# Chezmoi Diff

Show what `chezmoi apply` would do to your local files. Assess the risk before applying.

---

## Key Question

> "If I apply chezmoi now, what local work would I lose?"

**Direction:** Chezmoi source → Local (what chezmoi would overwrite)

---

## Gather

```bash
echo "=== Chezmoi Apply Impact ==="

# Full diff output
echo -e "\n--- Raw Diff ---"
chezmoi diff 2>&1 | head -100

# Count changes by type
echo -e "\n--- Summary ---"
DIFF_OUTPUT=$(chezmoi diff 2>&1)

# Files that would be modified
MODIFIED=$(echo "$DIFF_OUTPUT" | grep "^diff --git" | wc -l | tr -d ' ')
echo "Files with changes: $MODIFIED"

# Additions vs deletions
ADDITIONS=$(echo "$DIFF_OUTPUT" | grep "^+" | grep -v "^+++" | wc -l | tr -d ' ')
DELETIONS=$(echo "$DIFF_OUTPUT" | grep "^-" | grep -v "^---" | wc -l | tr -d ' ')
echo "Line changes: +$ADDITIONS -$DELETIONS"

# Check for files that would be created (in chezmoi but not local)
echo -e "\n--- Would Create ---"
chezmoi managed | while read f; do
  [ ! -e "$HOME/$f" ] && echo "  + $f"
done | head -10

# Check chezmoi source for any remove_ prefixed files (would delete)
echo -e "\n--- Would Delete ---"
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
find "$CHEZMOI_DIR" -name "remove_*" 2>/dev/null | while read f; do
  target=$(echo "$f" | sed "s|$CHEZMOI_DIR/||" | sed 's/remove_//' | sed 's/dot_/./g')
  echo "  - ~/$target"
done
```

---

## Output Format

```markdown
## Chezmoi Apply Impact

### Risk Assessment
| Risk | Count | Action |
|------|-------|--------|
| 🔴 HIGH (overwrites local edits) | 2 | Review before apply |
| 🟡 MEDIUM (additions to existing) | 3 | Usually safe |
| 🟢 LOW (new files) | 1 | Safe to apply |

### Would Overwrite (LOCAL CHANGES AT RISK)
| Local File | Changes | Risk |
|------------|---------|------|
| ~/.cursor/rules/etiquette.md | +45 -12 | 🔴 HIGH |
| ~/.zshrc | +3 -0 | 🟡 MEDIUM |

### Would Create (safe)
- ~/.cursor/rules/new-rule.md
- ~/.cursor/commands/new-cmd.md

### Would Delete (DANGER)
- ~/.old-config (remove_ in chezmoi)

### Summary
- **2 files** would be overwritten
- **1 file** would be created  
- **0 files** would be deleted
- Net line changes: +48 -12
```

---

## Risk Levels

| Risk | Meaning | Criteria |
|------|---------|----------|
| 🔴 HIGH | Local work would be lost | Deletions in existing files |
| 🟡 MEDIUM | Changes to existing files | Additions only, or mixed |
| 🟢 LOW | New files only | File doesn't exist locally |
| ⚫ DANGER | File deletion | `remove_` prefix in chezmoi |

---

## Detailed Diff

To see exact changes for a specific file:

```bash
# Full diff for one file
chezmoi diff ~/.cursor/rules/etiquette.md

# Side-by-side comparison
chezmoi diff ~/.zshrc | delta  # if delta installed

# What chezmoi source has vs local
diff ~/.cursor/rules/etiquette.md ~/.local/share/chezmoi/dot_cursor/rules/etiquette.md
```

---

## Safe Apply Options

```bash
# Dry run (show what would happen)
chezmoi apply --dry-run --verbose

# Apply only specific file
chezmoi apply ~/.cursor/rules/new-rule.md

# Apply with confirmation
chezmoi apply --interactive

# Force apply (DANGER - overwrites local)
chezmoi apply --force
```

---

## Before Apply Checklist

- [ ] Reviewed files with 🔴 HIGH risk
- [ ] Backed up or committed local changes
- [ ] Understood what would be deleted
- [ ] Ready to lose local edits in listed files

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| High risk files found | "Want to see the detailed diff for these?" |
| Only low risk | "Safe to apply. Proceed?" |
| Would delete files | "Review deletions before applying?" |
| No diff | "Chezmoi is in sync. Nothing to apply." |

---

## Related Commands

| Need | Command |
|------|---------|
| See local edits to capture | → `/chezmoi/edits` |
| Capture local changes first | → `/chezmoi/commit` |
| Full sync diagnostics | → `/sync/chezmoi` |

