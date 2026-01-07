# Ideation Assistant

Analyze the project, chat history, and .specstory files to propose future improvements grouped by category.

**When to use:** After completing a feature, during planning, looking for optimization opportunities.

---

## Gather Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Recent work
git log --oneline -20

# Project structure
find . -maxdepth 2 -type d ! -path "./.git*" ! -path "./node_modules*" | head -15

# CLAUDE.md context
[ -f "$REPO_ROOT/CLAUDE.md" ] && head -30 "$REPO_ROOT/CLAUDE.md"

# .specstory history
ls -lt "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | head -5

# Code TODOs
grep -rn "TODO\|FIXME" --include="*.py" . 2>/dev/null | head -15
```

---

## Review Sources

**In .specstory/chat history:**
- "We should..." / "We could..."
- Complaints about slowness or friction
- Features mentioned but not implemented

**In code:**
- `# TODO:` and `# FIXME:` comments
- Complex functions that could be simplified
- Repeated patterns

**In commits:**
- Patterns in what's being changed
- Features partially implemented

---

## Output: IDEAS.md

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# IDEAS.md - Future Improvements

**Generated:** [date]
**Based on:** [sources analyzed]

---

## 🔬 Science / Research

| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea] | [Why] | S/M/L | S/M/L |

Exploratory:
- [ ] [Hypothesis to test]

---

## 🛠️ Engineering

| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea] | [Why] | S/M/L | S/M/L |

Technical Debt:
- [ ] [Refactoring needed]

---

## 🤖 ML / Training

| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea] | [Why] | S/M/L | S/M/L |

Experiments:
- [ ] [Experiment]: [hypothesis]

---

## Sources Analyzed

| Source | Key Topics |
|--------|------------|
| .specstory/... | [topics] |
| Code TODOs | [count] found |
```

---

## Effort/Impact Scale

| Rating | Effort | Impact |
|--------|--------|--------|
| **S** | < 1 day | Minor |
| **M** | 1-5 days | Notable |
| **L** | > 1 week | Major |

**Prioritize:** High Impact + Low Effort first

---

## Categories

**🔬 Science:** Experiment design, hypothesis testing, ablation studies, methodology

**🛠️ Engineering:** Code quality, performance, testing, infrastructure, DX

**🤖 ML/Training:** Architecture, training loop, hyperparams, data augmentation, sweeps

---

## Example Follow-Up

"Which ideas should we explore further? Or focus on a specific category?"
