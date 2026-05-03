# Agent Optimization via ECC Yardstick — Design

**Date:** 2026-05-03
**Status:** Draft (awaiting user review)
**Owner:** Craig Russell
**Repo:** `~/.local/share/chezmoi`

## 1. Goal

Optimize Craig's Claude Code agent harness — the global `~/.claude/` setup
managed through chezmoi — by benchmarking it against the
[Everything Claude Code (ECC)](https://ecc.tools/) harness
(`affaan-m/everything-claude-code`).

Three concrete outputs:

1. **Usage inventory** — what is installed vs. actually invoked
2. **Gap matrix** — current setup mapped onto ECC's skill/agent/command taxonomy
3. **Prioritized action list** — categorized as kill / keep / fix / install

ECC is used as a *yardstick only*. We are not adopting `ecc-universal`
or vendoring ECC's content. The goal is to inform our own choices.

## 2. Current State (snapshot 2026-05-03)

- **Plugins:** 39 enabled (was 71, audited down to 43, then 39 after
  `/reload-plugins`)
- **User skills (`~/.claude/skills/`):** 8 — `chezmoi-workflows`,
  `claude-settings-audit`, `continuous-learning-v2`, `find-docs`,
  `find-skills`, `obsidian-bases`, `obsidian-cli`, `obsidian-markdown`
- **Hooks:** `SessionStart` (tmux rename), `Stop` (Obsidian sync)
- **Default mode:** `plan`
- **MCP servers:** ~30 from claude.ai (many irrelevant to data-science /
  dotfiles work) + ~14 plugin-provided
- **Transcripts available:** `~/.claude/projects/` ≈ 15MB, 6 project dirs
- **Known load error:** 1 plugin failed during `/reload-plugins` — to be
  identified via `/doctor` as the first discovery step in Pass A

## 3. Methodology — Three Layered Passes

### Pass A — Telemetry mining (objective)

**Sources:**
- `~/.claude/projects/**/*.jsonl` — raw transcripts
- `/session-report` plugin (already installed) — pre-aggregated session stats
- `/doctor` output — surfaces the current plugin load error and any other
  silent failures

**Per skill / plugin / MCP, compute:**

| Metric | Definition |
|---|---|
| `invocations` | Count of tool/skill calls |
| `last_used` | Most recent invocation timestamp |
| `error_rate` | Failed calls / total calls |
| `refusal_or_timeout_rate` | Tool refused or timed out |
| `bytes_consumed` | Total response bytes (proxy for context cost) |

**Outputs:**

- `audit/telemetry.csv` — raw per-tool stats
- `audit/usage-rankings.md` — top 20 most-used, all-zero used, high-error tools

### Pass B — ECC gap matrix (structural)

**Source:** Clone `affaan-m/everything-claude-code`, extract its skill /
agent / command index.

**Matrix axes:**

- Rows: ECC categories (Planning & Architecture, TDD, Code Review & Quality,
  Security & Compliance, Continuous Learning, Execution & Automation, plus
  any extras seen in the repo)
- Columns: Craig's installed equivalents (or "GAP")

**Outputs:**

- `audit/ecc-gap-matrix.md` — table with ECC categories vs. owned tooling
- `audit/duplicates.md` — overlapping plugins/MCPs (e.g., `Clinical Trials` ×2,
  `Context7` ×2, multiple PR-review plugins)
- `audit/ecc-recommended-additions.md` — ECC-shipped items worth installing
  even though we are not adopting ECC wholesale

### Pass C — Probes (targeted)

Only run on suspects from A/B (low-use, high-error, or duplicated).

**Probe script:** synthetic invocation of one representative call per suspect
tool. Examples:

- `bioRxiv.search_preprints("imaging biomarkers")` — does it return?
- `ChEMBL.compound_search("aspirin")` — does it return?
- `claude-settings-audit` run against `~/.local/share/chezmoi`
- `Sourcegraph.search` for a known string
- `GoodMem.system_info`
- Disabled-but-loaded MCPs: confirm they are actually consuming context

**Outputs:** `audit/probes.md` — pass/fail/notes per probe.

## 4. Scope — Four Layers

| Layer | What changes | How it lands |
|---|---|---|
| 1. Live `~/.claude/` | `settings.json`, hooks, custom skills | Direct edits, then upstreamed |
| 2. Chezmoi source | `dot_claude/`, `run_onchange_install-global-skills.sh.tmpl` | Git-committed templates in `~/.local/share/chezmoi` |
| 3. claude.ai MCPs | Adobe Marketing, AllTrails, Harvey, Taskrabbit, Shopify, Box, BioRender, Circleback, Spotify, Netlify, GCE, etc. | Manual checklist for the web console (cannot be automated) |
| 4. Agent SDK / personal subagents | Patterns under `~/.claude/plans/` | Recommendations doc only |

## 5. Pre-Identified Cuts (hypotheses, not decisions)

These are visible from inspection alone. **Cut decisions require BOTH**:
1. Pass A telemetry showing zero or near-zero invocations, AND
2. Explicit user confirmation that the tool is not relevant to Craig's
   workflow (some tools may be unused only because no occasion arose,
   not because they are unwanted).

The list below is the candidate set going into that decision.

**Duplicate tooling:**
- Clinical Trials MCP × 2 (claude.ai)
- Context7 × 2 (claude.ai + plugin)
- Notion × 2 (claude.ai + plugin)

**Likely never invoked (irrelevant to Craig's work):**
Adobe Marketing Agent, AllTrails, Harvey, Taskrabbit, Shopify, BioRender,
Circleback, Box, Spotify, Netlify, Google Compute Engine

**Output style overlap:**
`explanatory-output-style` and `learning-output-style` both enabled —
pick a default, leave the other as a `/output-style` opt-in.

**PR-review overlap:**
`pr-review-toolkit` + `code-review` + `coderabbit` + superpowers
`requesting-code-review` all overlap. Likely keep 2, drop 2.

**Plugin load error:**
`/reload-plugins` reports 1 error — needs `/doctor` investigation.

## 6. Deliverables

- **This spec** — `docs/superpowers/specs/2026-05-03-agent-optimization-design.md`
- **Audit artifacts** (produced during plan execution):
  - `audit/telemetry.csv`
  - `audit/usage-rankings.md`
  - `audit/ecc-gap-matrix.md`
  - `audit/duplicates.md`
  - `audit/ecc-recommended-additions.md`
  - `audit/probes.md`
- **Action list** — `audit/2026-05-03-action-list.md` with kill / keep /
  fix / install columns
- **Settings diff** — concrete patch to `~/.claude/settings.json`
- **Chezmoi template diffs** — under `dot_claude/` and skills installer
- **Manual web-console checklist** for claude.ai MCP disable steps

## 7. Out of Scope

- Adopting `ecc-universal` (npm) or vendoring ECC content
- Building a custom evaluation harness or AgentShield equivalent
- Project-level `.claude/settings.json` files in individual repos
- Skills / plugins with healthy telemetry and no overlap (leave alone)
- Refactoring the Obsidian sync hook unless telemetry shows breakage

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Telemetry only sees logged sessions; non-interactive work invisible | Combine with Pass B/C structural analysis |
| claude.ai MCPs cannot be controlled from CLI | Produce a manual checklist; user disables in web console |
| ECC repo may have changed since training cutoff | Pull fresh on first run, document the SHA |
| Duplicate Context7 may indicate one is configured differently | Diff configs before deciding which to drop |
| Killing a plugin breaks an in-flight workflow | Defer destructive cuts to a single explicit step at end |

## 9. Success Criteria

- Plugin/skill/MCP count reduced where telemetry confirms zero use
- All ECC categories have at least one Craig-owned equivalent (or an
  explicit "intentionally absent" note)
- No duplicate functionality across plugins
- Plugin load error resolved
- All changes reproducible via `chezmoi apply` on a fresh machine
