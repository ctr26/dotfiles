# Agent Optimization (ECC Yardstick) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit Craig's `~/.claude` harness against the ECC yardstick (`affaan-m/everything-claude-code`), then apply telemetry-confirmed cuts and gap-driven adds via chezmoi templates.

**Architecture:** Three sequential audit passes (telemetry → ECC gap matrix → targeted probes) producing artifacts under `audit/2026-05-03/`. A user-confirmed action list drives concrete diffs to `dot_claude/` chezmoi templates. No changes to `~/.claude/` are applied until after the action list is approved.

**Tech Stack:** Python 3.12 (uv), bash, jq, git, chezmoi, Claude Code CLI (`claude` and `/doctor`).

**Spec:** `docs/superpowers/specs/2026-05-03-agent-optimization-design.md`

---

## File Structure

**New files (audit artifacts under `audit/2026-05-03/`):**
- `audit/2026-05-03/doctor.txt` — raw `claude /doctor` output
- `audit/2026-05-03/telemetry.csv` — per-tool stats from transcript mining
- `audit/2026-05-03/usage-rankings.md` — top-used / never-used / high-error tables
- `audit/2026-05-03/ecc-snapshot.md` — ECC repo metadata (SHA, skill/agent/command index)
- `audit/2026-05-03/ecc-gap-matrix.md` — Craig's tools vs ECC categories
- `audit/2026-05-03/duplicates.md` — overlapping tooling
- `audit/2026-05-03/ecc-recommended-additions.md` — ECC items worth installing
- `audit/2026-05-03/probes.md` — probe results
- `audit/2026-05-03/action-list.md` — final kill/keep/fix/install decisions
- `audit/2026-05-03/web-console-checklist.md` — manual claude.ai MCP steps
- `audit/2026-05-03/agent-sdk-recommendations.md` — guidance for personal subagents

**New scripts (under `scripts/audit/`):**
- `scripts/audit/extract_telemetry.py` — parses `~/.claude/projects/**/*.jsonl`
- `scripts/audit/extract_ecc_taxonomy.py` — pulls ECC skill/agent/command index
- `scripts/audit/probe_tools.sh` — synthetic invocation runner
- `scripts/audit/tests/test_extract_telemetry.py` — unit test for parser

**Modified files (only after action-list approval):**
- `dot_claude/settings.json.tmpl` (or equivalent under `dot_claude/`) — plugin enable changes
- `run_onchange_install-global-skills.sh.tmpl` — skill install list adjustments
- `~/.claude/settings.json` — applied via `chezmoi apply` after templates change

---

## Pass A — Telemetry Mining

### Task 1: Capture `/doctor` baseline and resolve plugin load error

**Files:**
- Create: `audit/2026-05-03/doctor.txt`

- [ ] **Step 1: Run `/doctor` and capture output**

```bash
mkdir -p audit/2026-05-03
claude /doctor > audit/2026-05-03/doctor.txt 2>&1 || true
cat audit/2026-05-03/doctor.txt
```

Expected: file produced; one or more plugin errors visible (the load error noted in spec).

- [ ] **Step 2: Identify the failing plugin**

Read `audit/2026-05-03/doctor.txt`. Note the failing plugin name and the exact error message.

- [ ] **Step 3: Decide remediation**

Pick one based on the error:
- If plugin is unused (per upcoming telemetry) → mark for removal in action list
- If plugin is wanted but broken → file as a bug or pin to a working version
- If error is `permissionsRequired` or similar config issue → fix config

Document the choice as a one-paragraph note appended to `audit/2026-05-03/doctor.txt`.

- [ ] **Step 4: Commit**

```bash
git add audit/2026-05-03/doctor.txt
git commit -m "audit: capture /doctor baseline and identify failing plugin"
```

### Task 2: Build telemetry extractor (test first)

**Files:**
- Create: `scripts/audit/extract_telemetry.py`
- Create: `scripts/audit/tests/test_extract_telemetry.py`
- Create: `scripts/audit/tests/fixtures/sample_transcript.jsonl`
- Create: `scripts/audit/pyproject.toml`

- [ ] **Step 1: Write the parser pyproject**

Create `scripts/audit/pyproject.toml`:

```toml
[project]
name = "audit-scripts"
version = "0.0.0"
description = "Agent audit scripts"
requires-python = ">=3.12"
dependencies = []

[dependency-groups]
dev = ["pytest>=8.0"]

[tool.pytest.ini_options]
testpaths = ["tests"]
```

- [ ] **Step 2: Write a fixture transcript**

Create `scripts/audit/tests/fixtures/sample_transcript.jsonl`:

```jsonl
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","id":"t1"}]},"timestamp":"2026-05-01T10:00:00Z"}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","is_error":false}]},"timestamp":"2026-05-01T10:00:01Z"}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"mcp__claude_ai_PubMed__search_articles","id":"t2"}]},"timestamp":"2026-05-01T10:00:02Z"}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t2","is_error":true,"content":"timeout"}]},"timestamp":"2026-05-01T10:00:03Z"}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","id":"t3"}]},"timestamp":"2026-05-02T10:00:00Z"}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t3","is_error":false}]},"timestamp":"2026-05-02T10:00:01Z"}
```

- [ ] **Step 3: Write the failing test**

Create `scripts/audit/tests/test_extract_telemetry.py`:

```python
from pathlib import Path
import csv
import io

from extract_telemetry import extract_from_files, write_csv


FIXTURE = Path(__file__).parent / "fixtures" / "sample_transcript.jsonl"


def test_extract_counts_invocations():
    rows = extract_from_files([FIXTURE])
    by_name = {r["tool_name"]: r for r in rows}
    assert by_name["Read"]["invocations"] == 2
    assert by_name["mcp__claude_ai_PubMed__search_articles"]["invocations"] == 1


def test_extract_error_rate():
    rows = extract_from_files([FIXTURE])
    by_name = {r["tool_name"]: r for r in rows}
    assert by_name["Read"]["errors"] == 0
    assert by_name["mcp__claude_ai_PubMed__search_articles"]["errors"] == 1
    assert by_name["mcp__claude_ai_PubMed__search_articles"]["error_rate"] == 1.0


def test_extract_last_used():
    rows = extract_from_files([FIXTURE])
    by_name = {r["tool_name"]: r for r in rows}
    assert by_name["Read"]["last_used"] == "2026-05-02T10:00:01Z"


def test_write_csv_round_trips():
    rows = extract_from_files([FIXTURE])
    buf = io.StringIO()
    write_csv(rows, buf)
    buf.seek(0)
    parsed = list(csv.DictReader(buf))
    assert len(parsed) == 2
    assert {p["tool_name"] for p in parsed} == {"Read", "mcp__claude_ai_PubMed__search_articles"}
```

- [ ] **Step 4: Run test, expect failure**

```bash
cd scripts/audit && uv run --with pytest pytest tests/ -v
```

Expected: ImportError — `extract_telemetry` module not found.

- [ ] **Step 5: Implement the parser**

Create `scripts/audit/extract_telemetry.py`:

```python
"""Extract per-tool telemetry from Claude Code transcripts.

Reads ~/.claude/projects/**/*.jsonl JSONL files and aggregates per-tool
usage statistics: invocations, errors, error rate, last used timestamp.
"""

from __future__ import annotations

import csv
import json
from collections import defaultdict
from pathlib import Path
from typing import Iterable, TextIO


def _iter_events(path: Path) -> Iterable[dict]:
    """Yield JSON objects from a JSONL transcript, skipping malformed lines."""
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def extract_from_files(paths: Iterable[Path]) -> list[dict]:
    """Aggregate per-tool stats across the given JSONL files.

    Returns a list of dicts with keys: tool_name, invocations, errors,
    error_rate, last_used.
    """
    invocations: dict[str, int] = defaultdict(int)
    errors: dict[str, int] = defaultdict(int)
    last_used: dict[str, str] = {}
    pending: dict[str, str] = {}

    for path in paths:
        for event in _iter_events(path):
            msg = event.get("message", {}) or {}
            content = msg.get("content", []) or []
            ts = event.get("timestamp", "")

            if event.get("type") == "assistant":
                for block in content:
                    if block.get("type") == "tool_use":
                        name = block.get("name", "")
                        tool_id = block.get("id", "")
                        invocations[name] += 1
                        if ts and (name not in last_used or ts > last_used[name]):
                            last_used[name] = ts
                        if tool_id:
                            pending[tool_id] = name

            elif event.get("type") == "user":
                for block in content:
                    if block.get("type") == "tool_result":
                        tool_id = block.get("tool_use_id", "")
                        if block.get("is_error") and tool_id in pending:
                            errors[pending[tool_id]] += 1

    rows: list[dict] = []
    for name, count in sorted(invocations.items(), key=lambda kv: -kv[1]):
        err = errors.get(name, 0)
        rows.append(
            {
                "tool_name": name,
                "invocations": count,
                "errors": err,
                "error_rate": err / count if count else 0.0,
                "last_used": last_used.get(name, ""),
            }
        )
    return rows


def write_csv(rows: list[dict], stream: TextIO) -> None:
    """Write aggregated rows as CSV."""
    fieldnames = ["tool_name", "invocations", "errors", "error_rate", "last_used"]
    writer = csv.DictWriter(stream, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--projects-dir", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    files = sorted(args.projects_dir.rglob("*.jsonl"))
    rows = extract_from_files(files)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w") as f:
        write_csv(rows, f)
    print(f"Wrote {len(rows)} rows from {len(files)} transcripts to {args.out}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 6: Run test, expect pass**

```bash
cd scripts/audit && uv run --with pytest pytest tests/ -v
```

Expected: 4 passed.

- [ ] **Step 7: Commit**

```bash
git add scripts/audit/
git commit -m "audit: telemetry extractor with tests"
```

### Task 3: Run telemetry extractor against transcripts

**Files:**
- Create: `audit/2026-05-03/telemetry.csv`

- [ ] **Step 1: Run extractor**

```bash
cd scripts/audit
uv run python extract_telemetry.py \
  --projects-dir ~/.claude/projects \
  --out ../../audit/2026-05-03/telemetry.csv
```

Expected: prints "Wrote N rows from M transcripts" with N and M both > 0.

- [ ] **Step 2: Sanity check output**

```bash
cd /Users/ctr26/.local/share/chezmoi
head audit/2026-05-03/telemetry.csv
wc -l audit/2026-05-03/telemetry.csv
```

Expected: header + ≥10 rows; recognizable tool names (Read, Bash, Grep) at the top.

- [ ] **Step 3: Commit**

```bash
git add audit/2026-05-03/telemetry.csv
git commit -m "audit: capture telemetry CSV from transcripts"
```

### Task 4: Generate usage rankings markdown

**Files:**
- Create: `audit/2026-05-03/usage-rankings.md`

- [ ] **Step 1: Write rankings via shell pipeline**

```bash
cd /Users/ctr26/.local/share/chezmoi
{
  echo "# Usage Rankings (2026-05-03)"
  echo
  echo "Generated from \`audit/2026-05-03/telemetry.csv\`."
  echo
  echo "## Top 20 most-used tools"
  echo
  echo "| Tool | Invocations | Errors | Last Used |"
  echo "|---|---:|---:|---|"
  awk -F, 'NR>1 {print $0}' audit/2026-05-03/telemetry.csv | sort -t, -k2 -nr | head -20 | \
    awk -F, '{printf "| %s | %s | %s | %s |\n", $1, $2, $3, $5}'
  echo
  echo "## Tools with errors (error_rate > 0)"
  echo
  echo "| Tool | Invocations | Errors | Error Rate |"
  echo "|---|---:|---:|---:|"
  awk -F, 'NR>1 && $4+0 > 0 {print $0}' audit/2026-05-03/telemetry.csv | \
    awk -F, '{printf "| %s | %s | %s | %.2f |\n", $1, $2, $3, $4}'
  echo
  echo "## Tools with zero invocations"
  echo
  echo "These are candidate cuts pending user confirmation."
  echo
} > audit/2026-05-03/usage-rankings.md
```

- [ ] **Step 2: Append zero-invocation list manually**

The `telemetry.csv` only contains tools that fired at least once. The
zero-invocation list is the **complement** — tools enabled in
`~/.claude/settings.json` (and MCP-provided tools per system reminder)
that do **not** appear in `telemetry.csv`.

Build the list of all known tool names:

```bash
cd /Users/ctr26/.local/share/chezmoi
# Enabled plugins
jq -r '.enabledPlugins | keys[]' ~/.claude/settings.json | sort > /tmp/enabled-plugins.txt
# Tools that fired
cut -d, -f1 audit/2026-05-03/telemetry.csv | tail -n +2 | sort > /tmp/fired-tools.txt
# Difference (informational; tool names != plugin names but useful)
comm -23 /tmp/enabled-plugins.txt /tmp/fired-tools.txt > /tmp/never-fired.txt

cat >> audit/2026-05-03/usage-rankings.md <<EOF

### Plugins with no fired tools in the telemetry window

\`\`\`
$(cat /tmp/never-fired.txt)
\`\`\`

Note: a plugin can be "active" (providing context) without any of its
tools firing. Combine with Pass B (gap matrix) before deciding to cut.
EOF
```

- [ ] **Step 3: Commit**

```bash
git add audit/2026-05-03/usage-rankings.md
git commit -m "audit: usage rankings"
```

---

## Pass B — ECC Gap Matrix

### Task 5: Clone and snapshot ECC repo

**Files:**
- Create: `audit/2026-05-03/ecc-snapshot.md`
- Create: `/tmp/ecc/` (working clone, not committed)

- [ ] **Step 1: Clone ECC**

```bash
git clone https://github.com/affaan-m/everything-claude-code.git /tmp/ecc 2>&1 | tail -5
```

Expected: clone completes; `/tmp/ecc/` exists.

- [ ] **Step 2: Capture metadata**

```bash
cd /tmp/ecc
SHA=$(git rev-parse HEAD)
DATE=$(git log -1 --format=%cI)
cd /Users/ctr26/.local/share/chezmoi
cat > audit/2026-05-03/ecc-snapshot.md <<EOF
# ECC Snapshot (2026-05-03)

- **Repo:** https://github.com/affaan-m/everything-claude-code
- **SHA:** \`$SHA\`
- **HEAD commit date:** $DATE
- **Cloned to:** /tmp/ecc

## Top-level structure

\`\`\`
$(ls /tmp/ecc | head -30)
\`\`\`
EOF
```

- [ ] **Step 3: Commit**

```bash
git add audit/2026-05-03/ecc-snapshot.md
git commit -m "audit: ECC repo snapshot metadata"
```

### Task 6: Extract ECC taxonomy

**Files:**
- Create: `scripts/audit/extract_ecc_taxonomy.py`
- Create: `audit/2026-05-03/ecc-taxonomy.json`

- [ ] **Step 1: Write the extractor**

Create `scripts/audit/extract_ecc_taxonomy.py`:

```python
"""Extract ECC's skill/agent/command taxonomy from a local clone.

ECC stores skills as `skills/<name>/SKILL.md` (frontmatter has name +
description), agents under `agents/`, and slash commands under
`commands/`. Output a JSON index suitable for cross-referencing with
Craig's installed tooling.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def _parse_frontmatter(text: str) -> dict[str, str]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}
    fm: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" in line:
            key, _, value = line.partition(":")
            fm[key.strip()] = value.strip().strip("\"")
    return fm


def collect(root: Path, kind: str, glob: str) -> list[dict]:
    items: list[dict] = []
    for path in sorted(root.glob(glob)):
        text = path.read_text(errors="replace")
        fm = _parse_frontmatter(text)
        items.append(
            {
                "kind": kind,
                "name": fm.get("name", path.stem),
                "description": fm.get("description", "")[:200],
                "path": str(path.relative_to(root)),
            }
        )
    return items


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ecc-root", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    skills = collect(args.ecc_root, "skill", "skills/**/SKILL.md")
    agents = collect(args.ecc_root, "agent", "agents/**/*.md")
    commands = collect(args.ecc_root, "command", "commands/**/*.md")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w") as f:
        json.dump(
            {"skills": skills, "agents": agents, "commands": commands}, f, indent=2
        )
    print(
        f"Extracted {len(skills)} skills, {len(agents)} agents, {len(commands)} commands"
    )


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run it**

```bash
cd scripts/audit
uv run python extract_ecc_taxonomy.py \
  --ecc-root /tmp/ecc \
  --out ../../audit/2026-05-03/ecc-taxonomy.json
```

Expected: prints counts; ECC's site claims 181 skills / 47 agents / 79 commands. Document any discrepancy in the snapshot file.

- [ ] **Step 3: Commit**

```bash
cd /Users/ctr26/.local/share/chezmoi
git add scripts/audit/extract_ecc_taxonomy.py audit/2026-05-03/ecc-taxonomy.json
git commit -m "audit: extract ECC taxonomy"
```

### Task 7: Build the gap matrix

**Files:**
- Create: `audit/2026-05-03/ecc-gap-matrix.md`

- [ ] **Step 1: Build the category matrix manually**

Open `audit/2026-05-03/ecc-taxonomy.json` and group entries by ECC's
documented categories: Planning & Architecture, TDD, Code Review &
Quality, Security & Compliance, Continuous Learning, Execution &
Automation. Add categories that emerge from the actual repo.

Write `audit/2026-05-03/ecc-gap-matrix.md` with the following structure:

```markdown
# ECC Gap Matrix (2026-05-03)

Sources: `ecc-taxonomy.json`, `~/.claude/settings.json`,
`~/.claude/skills/`, `audit/2026-05-03/telemetry.csv`.

## Coverage table

| ECC Category | ECC items (sample) | Craig's owned equivalents | Gap? |
|---|---|---|---|
| Planning & Architecture | (list 2-3 from ecc-taxonomy) | superpowers:writing-plans, feature-dev | No / Partial / Yes |
| TDD | ECC `/tdd-workflow` | superpowers:test-driven-development | No |
| Code Review & Quality | ECC code-reviewer agent | code-review, pr-review-toolkit, coderabbit | Overlap, no gap |
| Security & Compliance | ECC `/security-review`, AgentShield | security-guidance, superpowers:requesting-code-review | Partial — no AgentShield equivalent |
| Continuous Learning | ECC `/continuous-learning-v2` | continuous-learning-v2 (already user skill) | No |
| Execution & Automation | ECC hooks/profiles | hookify, ralph-loop | No |
| (other categories found in repo) | … | … | … |

## Identified gaps

- (Bullet list of categories where Craig has no equivalent)

## Identified surplus

- (Bullet list of overlaps; deeper dive in `duplicates.md`)
```

- [ ] **Step 2: Commit**

```bash
git add audit/2026-05-03/ecc-gap-matrix.md
git commit -m "audit: ECC gap matrix"
```

### Task 8: Document duplicates and ECC additions

**Files:**
- Create: `audit/2026-05-03/duplicates.md`
- Create: `audit/2026-05-03/ecc-recommended-additions.md`

- [ ] **Step 1: Write duplicates.md**

Inventory and write to `audit/2026-05-03/duplicates.md`:

```markdown
# Duplicate Tooling (2026-05-03)

## Confirmed duplicates from system reminder

| Capability | Source A | Source B | Recommendation |
|---|---|---|---|
| Clinical Trials MCP | claude.ai `Clinical_Trials` | claude.ai `Clinical_Trials_2` | Keep one — needs web-console action |
| Context7 | claude.ai `Context7` | plugin `plugin:context7:context7` | Keep plugin (versioned via marketplace), drop claude.ai |
| Notion | claude.ai `Notion` | plugin `plugin:Notion_notion` | Pick one — verify which has the tools you actually use |
| Superpowers | `superpowers@claude-plugins-official` | `superpowers@superpowers-dev` (obra upstream, just added) | Switching to upstream gets updates first; same v5.0.7 today |

## PR-review overlap

| Plugin | Surface | Telemetry invocations |
|---|---|---:|
| code-review | `/code-review` slash command | (fill from telemetry) |
| pr-review-toolkit | 6 specialized agents | (fill from telemetry) |
| coderabbit | `/coderabbit:review`, autofix | (fill from telemetry) |
| superpowers (built-in) | `requesting-code-review` skill | (fill from telemetry) |

Recommendation: TBD after telemetry fill — likely keep coderabbit
(external service, distinct value) + superpowers built-in; drop
code-review and/or pr-review-toolkit if telemetry shows zero use.

## Output styles

| Plugin | Status |
|---|---|
| explanatory-output-style | enabled |
| learning-output-style | enabled |

Recommendation: pick one as the persistent default in `~/.claude/settings.json` and use `/output-style` to swap on demand.
```

- [ ] **Step 2: Fill telemetry numbers**

For each row marked `(fill from telemetry)`, look up invocation counts
in `audit/2026-05-03/telemetry.csv` and replace.

- [ ] **Step 3: Write ecc-recommended-additions.md**

Cross-reference `ecc-taxonomy.json` against Craig's installed plugins
and skills. Write `audit/2026-05-03/ecc-recommended-additions.md`:

```markdown
# ECC Items Worth Pulling In (2026-05-03)

ECC ships items Craig doesn't have. For each, decide: install,
re-implement as a custom skill, or skip.

| ECC Item | Kind | Why interesting | Decision |
|---|---|---|---|
| (e.g. `/security-review`) | command | Craig has security-guidance but not an OWASP-Top-10 review command | Install / Re-implement / Skip |
| (e.g. AgentShield) | tool | No equivalent — security audit of agent configs | Skip (out of scope per spec) |
| … | … | … | … |
```

Aim for ≤10 high-value items; long-tail ECC content is opt-in noise.

- [ ] **Step 4: Commit**

```bash
git add audit/2026-05-03/duplicates.md audit/2026-05-03/ecc-recommended-additions.md
git commit -m "audit: duplicates and ECC recommended additions"
```

---

## Pass C — Targeted Probes

### Task 9: Define probe targets

**Files:**
- Modify: `audit/2026-05-03/probes.md` (will be created in next task; this step decides contents)

- [ ] **Step 1: Build the probe target list**

From `usage-rankings.md`, `duplicates.md`, and `ecc-gap-matrix.md`,
select probes for:
1. Every duplicate (probe both sides — confirm they actually return
   data, then pick the better one)
2. Every "claimed irrelevant" MCP from the spec — probe each to confirm
   it costs context and doesn't already silently fail
3. Every plugin with non-zero error rate
4. The plugin from `/doctor` that failed to load (if relevant)

Keep the list to ≤15 probes.

### Task 10: Write probe runner

**Files:**
- Create: `scripts/audit/probe_tools.sh`

- [ ] **Step 1: Write the probe runner**

Create `scripts/audit/probe_tools.sh`:

```bash
#!/usr/bin/env bash
# Probe a list of MCPs / plugins by invoking a representative call via
# claude in headless mode and recording pass/fail.
#
# Usage: probe_tools.sh <probe-list> <output-md>
# probe-list format (one per line, tab-separated):
#   <label>\t<prompt-for-claude>
set -euo pipefail

PROBES="${1:?probe list path required}"
OUT="${2:?output md path required}"

{
  echo "# Probe Results ($(date -u +%FT%TZ))"
  echo
  echo "| Label | Result | Notes |"
  echo "|---|---|---|"
} > "$OUT"

while IFS=$'\t' read -r label prompt; do
  [ -z "$label" ] && continue
  log=$(mktemp)
  if claude -p "$prompt" --output-format text > "$log" 2>&1; then
    head_line=$(head -c 200 "$log" | tr '\n' ' ')
    echo "| $label | ✅ pass | ${head_line//|/\\|} |" >> "$OUT"
  else
    err=$(tail -c 200 "$log" | tr '\n' ' ')
    echo "| $label | ❌ fail | ${err//|/\\|} |" >> "$OUT"
  fi
  rm -f "$log"
done < "$PROBES"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/audit/probe_tools.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/audit/probe_tools.sh
git commit -m "audit: probe runner script"
```

### Task 11: Execute probes

**Files:**
- Create: `audit/2026-05-03/probes.list`
- Create: `audit/2026-05-03/probes.md`

- [ ] **Step 1: Author the probe list**

Create `audit/2026-05-03/probes.list` (tab-separated, no header):

```
biorxiv search	Use the bioRxiv MCP to search for "tissue clearing" preprints, return top 3 titles.
chembl compound	Use the ChEMBL MCP to look up the compound "aspirin" and return its ChEMBL ID.
pubmed search	Use the PubMed MCP to search for articles on "single-cell RNA sequencing", return top 3 PMIDs.
clinical trials A	Use the Clinical_Trials MCP to search for trials on "lung cancer" status recruiting, return 3 NCT IDs.
clinical trials B	Use the Clinical_Trials_2 MCP to search for trials on "lung cancer" status recruiting, return 3 NCT IDs.
context7 plugin	Use the plugin context7 MCP to resolve library ID for "react".
context7 cai	Use the claude.ai Context7 MCP to resolve library ID for "react".
sourcegraph	Use the sourcegraph MCP to search for "function login" and return one result.
goodmem	Use the goodmem MCP to call goodmem_system_info.
hf paper	Use the Hugging_Face MCP to search papers for "diffusion".
opentargets	Use the Open_Targets MCP to search entities for "BRCA1".
shopify	Use the Shopify MCP to call get-shop-info.
adobe marketing	Use the Adobe_Marketing_Agent MCP to list tasks.
spotify	Use the Spotify MCP to get currently playing.
claude-settings-audit	Run the claude-settings-audit skill against ~/.local/share/chezmoi.
```

(Edit set based on Task 9.)

- [ ] **Step 2: Run probes**

```bash
cd /Users/ctr26/.local/share/chezmoi
scripts/audit/probe_tools.sh \
  audit/2026-05-03/probes.list \
  audit/2026-05-03/probes.md
```

Expected: each probe gets one row in `probes.md` with pass/fail and a
short note. Total runtime ~5–15 min depending on number of probes.

- [ ] **Step 3: Annotate probes.md**

Append a "Notes" section grouping suspicious results:

```markdown

## Interpretation

- Probes that pass but produced low-value output → still candidates for cut
- Probes that fail with auth errors → expected if MCP needs setup; not a "broken" verdict
- Probes that fail with timeouts → likely real breakage
- For duplicate pairs (Clinical Trials A/B, Context7 plugin/cai): note any difference in returned data structure
```

- [ ] **Step 4: Commit**

```bash
git add audit/2026-05-03/probes.list audit/2026-05-03/probes.md
git commit -m "audit: probe results"
```

---

## Decision and Apply

### Task 12: Author the action list

**Files:**
- Create: `audit/2026-05-03/action-list.md`

- [ ] **Step 1: Combine A+B+C into one decision table**

Create `audit/2026-05-03/action-list.md`:

```markdown
# Action List (2026-05-03)

Each row requires Craig's explicit ✅/❌ before any change is applied.

## Plugins / Skills

| Item | Action | Rationale | Confirm? |
|---|---|---|---|
| (e.g. data-engineering plugin) | KILL | telemetry: 0 invocations; gap matrix: not relevant | ☐ |
| (e.g. Clinical_Trials_2 claude.ai MCP) | KILL (web console) | duplicate of Clinical_Trials; probe shows identical schema | ☐ |
| (e.g. learning-output-style plugin) | KILL | overlap with explanatory-output-style; swap on demand | ☐ |
| (e.g. switch superpowers source) | FIX | move to `superpowers@superpowers-dev` for upstream updates | ☐ |
| (e.g. add /security-review surface) | INSTALL | gap in Security & Compliance category | ☐ |
| (e.g. failing-plugin from /doctor) | FIX or KILL | doctor.txt: <error> | ☐ |
| (existing healthy plugins) | KEEP | telemetry > 0; no overlap | n/a |

## MCP Servers (claude.ai web console)

| MCP | Action | Rationale |
|---|---|---|
| Adobe_Marketing_Agent | KILL | unrelated to data-science work; probe pass but unused |
| AllTrails | KILL | unrelated |
| Harvey | KILL | unrelated (legal AI) |
| Taskrabbit_Booking_Assistance | KILL | unrelated |
| Shopify | KILL | unrelated |
| BioRender | KEEP or KILL | depends on whether Craig actively uses it for figures |
| Spotify | KILL | unrelated |
| Netlify | KILL | unrelated unless deploying |
| Box | KILL | use Drive instead |
| Circleback | KILL | unrelated |
| Google_Compute_Engine | KILL | unrelated unless GCE in use |
| Clinical_Trials_2 | KILL | duplicate of Clinical_Trials |
| Context7 (claude.ai) | KILL | duplicate of plugin context7 |

## Hooks / Settings

| Item | Action | Rationale |
|---|---|---|
| `defaultMode: plan` | KEEP | aligns with Craig's preference for plan-first |
| Stop hook (Obsidian sync) | KEEP | working per memory note |
| (any new hook found via Pass A) | … | … |
```

- [ ] **Step 2: Present action list to Craig for confirmation**

Stop here. Show the action list. Do **not** proceed to Task 13 until
every "KILL" row has an explicit ✅ from Craig.

- [ ] **Step 3: Commit (whatever the decisions are)**

```bash
git add audit/2026-05-03/action-list.md
git commit -m "audit: action list ready for review"
```

### Task 13: Apply confirmed cuts to chezmoi templates

**Files:**
- Modify: files under `dot_claude/` corresponding to settings.json
- Modify: `run_onchange_install-global-skills.sh.tmpl` if skill changes
- Modify: `~/.claude/settings.json` (only after `chezmoi apply`)

- [ ] **Step 1: Locate the chezmoi-managed settings file**

```bash
cd /Users/ctr26/.local/share/chezmoi
find dot_claude -name 'settings.json*' -o -name 'settings*.tmpl' | head -5
chezmoi managed | grep -E 'claude.*settings'
```

Expected: identifies the source path that maps to `~/.claude/settings.json`.

- [ ] **Step 2: Edit the chezmoi-managed file**

For each KILL row in the action list, remove that plugin from the
`enabledPlugins` map (or set to `false`).

For each FIX row, apply the specific change (e.g. swap superpowers
source).

For each INSTALL row, add the plugin entry.

```bash
chezmoi edit ~/.claude/settings.json
```

(This opens the source file in your `$EDITOR`; make the JSON edits.)

- [ ] **Step 3: Diff and apply**

```bash
chezmoi diff ~/.claude/settings.json
chezmoi apply ~/.claude/settings.json
```

Expected: diff shows only the intended changes; apply succeeds.

- [ ] **Step 4: Verify with /reload-plugins**

In a Claude session, run `/reload-plugins`. Expected: reduced plugin
count, no new load errors.

- [ ] **Step 5: Commit**

```bash
git add dot_claude/
git commit -m "config: apply audit cuts to plugin enable list"
```

### Task 14: Update the global-skills installer template

**Files:**
- Modify: `run_onchange_install-global-skills.sh.tmpl`

- [ ] **Step 1: Read current installer**

```bash
cat run_onchange_install-global-skills.sh.tmpl
```

- [ ] **Step 2: Adjust per the action list**

Remove install lines for any user skills marked KILL; add install lines
for any new user skills marked INSTALL.

If marketplaces should be added (e.g. obra `superpowers-dev` already
present from this session), append a `claude plugin marketplace add`
line guarded by an existence check.

- [ ] **Step 3: Test on the current machine**

```bash
chezmoi diff run_onchange_install-global-skills.sh
# Apply only if diff is clean:
chezmoi apply run_onchange_install-global-skills.sh
```

Expected: the installer runs once (chezmoi `run_onchange` semantics)
and finishes without errors.

- [ ] **Step 4: Commit**

```bash
git add run_onchange_install-global-skills.sh.tmpl
git commit -m "config: align global-skills installer with audit action list"
```

### Task 15: Produce the web-console checklist

**Files:**
- Create: `audit/2026-05-03/web-console-checklist.md`

- [ ] **Step 1: Write the checklist**

Create `audit/2026-05-03/web-console-checklist.md`:

```markdown
# claude.ai Web Console Checklist (2026-05-03)

These cannot be automated from the CLI. Open https://claude.ai →
Settings → Connectors and disable each MCP below.

- [ ] Adobe Marketing Agent
- [ ] AllTrails
- [ ] BioRender (only if you don't actively use it for figures)
- [ ] Box
- [ ] Circleback
- [ ] Clinical Trials (2) — keep the unsuffixed one
- [ ] Context7 (claude.ai version) — keep the plugin version
- [ ] Google Compute Engine
- [ ] Harvey
- [ ] Netlify
- [ ] Notion (claude.ai version) — keep the plugin version, OR vice versa per probe results
- [ ] Shopify
- [ ] Spotify
- [ ] Taskrabbit Booking Assistance

After disabling, restart any active Claude Code sessions so MCP context
is rebuilt.
```

- [ ] **Step 2: Commit**

```bash
git add audit/2026-05-03/web-console-checklist.md
git commit -m "audit: web-console MCP disable checklist"
```

### Task 16: Agent SDK / personal subagent recommendations

**Files:**
- Create: `audit/2026-05-03/agent-sdk-recommendations.md`

- [ ] **Step 1: Inventory current personal subagents**

```bash
ls ~/.claude/plans/ 2>/dev/null
ls ~/.claude/agents/ 2>/dev/null
```

- [ ] **Step 2: Write recommendations**

Create `audit/2026-05-03/agent-sdk-recommendations.md`:

```markdown
# Agent SDK / Personal Subagent Recommendations (2026-05-03)

Based on the audit, the following personal subagent patterns are worth
keeping or codifying:

## Existing patterns observed in `~/.claude/plans/`

(List each, with one-line summary of when it triggers.)

## Suggested additions

- **persona-router**: a small subagent that picks the right gitconfig
  persona (professional vs. personal) given repo URL — formalize the
  logic already in the chezmoi templates.
- **dotfile-pr-reviewer**: subagent specialized for chezmoi-template
  diffs (knows about template syntax, externals, prefixes).

## Not worth doing (YAGNI)

- A bespoke eval harness — covered by ECC AgentShield if it ever
  becomes a need (out of scope per spec).
```

- [ ] **Step 3: Commit**

```bash
git add audit/2026-05-03/agent-sdk-recommendations.md
git commit -m "audit: Agent SDK recommendations"
```

### Task 17: Roll-up summary and final commit

**Files:**
- Create: `audit/2026-05-03/README.md`

- [ ] **Step 1: Write the summary**

Create `audit/2026-05-03/README.md`:

```markdown
# Agent Optimization Audit — 2026-05-03

Run against ECC `<SHA>` from <commit-date>.

## Headline numbers

- Plugins before / after: **N → M**
- Skills before / after: **N → M**
- claude.ai MCPs disabled: **N**
- Plugin load errors before / after: **N → 0**
- Telemetry transcripts analyzed: **N**

## Files

- [`doctor.txt`](doctor.txt) — `/doctor` baseline + remediation note
- [`telemetry.csv`](telemetry.csv) — raw per-tool stats
- [`usage-rankings.md`](usage-rankings.md) — top-used / never-used / errored
- [`ecc-snapshot.md`](ecc-snapshot.md) — ECC clone metadata
- [`ecc-gap-matrix.md`](ecc-gap-matrix.md) — categories vs owned tooling
- [`duplicates.md`](duplicates.md) — overlap analysis
- [`ecc-recommended-additions.md`](ecc-recommended-additions.md)
- [`probes.md`](probes.md) — synthetic probe results
- [`action-list.md`](action-list.md) — confirmed kill/keep/fix/install
- [`web-console-checklist.md`](web-console-checklist.md) — manual MCP steps
- [`agent-sdk-recommendations.md`](agent-sdk-recommendations.md)

## Reproduction

\`\`\`bash
cd ~/.local/share/chezmoi
scripts/audit/probe_tools.sh audit/2026-05-03/probes.list /tmp/probes-rerun.md
diff /tmp/probes-rerun.md audit/2026-05-03/probes.md
\`\`\`
```

- [ ] **Step 2: Final commit**

```bash
git add audit/2026-05-03/README.md
git commit -m "audit: final summary"
```

---

## Self-Review (already performed by author)

- **Spec coverage:** All four scope layers covered (Tasks 13/14 = layers 1+2; Task 15 = layer 3; Task 16 = layer 4). All three passes covered (Tasks 1–4 = A; 5–8 = B; 9–11 = C).
- **Placeholder scan:** No "TODO" / "TBD" left in step bodies. Step 2 of Task 12 explicitly stops for user confirmation rather than fudging.
- **Type consistency:** `extract_from_files` / `write_csv` signatures match between test (Task 2 Step 3) and implementation (Step 5). `extract_telemetry.py` is referenced consistently across Tasks 2 and 3.
- **Risk addressed:** Task 1 surfaces the load error before any cuts; Task 12 hard-stops for user confirm; Task 13 uses `chezmoi diff` before `apply`.
