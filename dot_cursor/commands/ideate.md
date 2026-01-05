# Ideation Assistant

You are an ideation assistant. Analyze the current project, chat history, and .specstory files to propose future improvements grouped by category.

## When to Use

- After completing a feature (what's next?)
- During planning sessions
- When looking for optimization opportunities
- To generate a roadmap of improvements

---

## Gather Context First

Before ideating, understand what exists:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Project Overview ==="
echo "Repo: $REPO_ROOT"
echo "Branch: $(git branch --show-current)"

echo -e "\n=== Recent Work (commits) ==="
git log --oneline -20

echo -e "\n=== Project Structure ==="
find . -maxdepth 2 -type d ! -path "./.git*" ! -path "./node_modules*" ! -path "./__pycache__*" | head -20

echo -e "\n=== Key Config Files ==="
ls -la pyproject.toml setup.py requirements.txt configs/*.yaml experiments/*.yaml 2>/dev/null | head -10

echo -e "\n=== CLAUDE.md (current context) ==="
[ -f "$REPO_ROOT/CLAUDE.md" ] && head -50 "$REPO_ROOT/CLAUDE.md"

echo -e "\n=== Recent Chat History (.specstory) ==="
find "$REPO_ROOT" -path "*/.specstory/*" -name "*.md" -mtime -14 2>/dev/null | head -10

echo -e "\n=== TODO/FIXME in Code ==="
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" . 2>/dev/null | head -20
```

---

## Review .specstory Chat History

Read recent chat sessions to understand:
- What problems were discussed
- What solutions were considered but not implemented
- What pain points came up repeatedly
- What "nice to have" features were mentioned

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# List recent chats
echo "=== Recent Chat Sessions ==="
ls -lt "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | head -10

# Search for improvement keywords
echo -e "\n=== Improvement Mentions ==="
grep -h "could\|should\|TODO\|idea\|improve\|optimize\|refactor\|future" \
  "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | tail -30
```

---

## Output Format: IDEAS.md

Write to IDEAS.md (or update if exists):

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# IDEAS.md - Future Improvements

**Generated:** [date]
**Based on:** [list of sources analyzed]

---

## 🔬 Science / Research

Improvements to the scientific methodology, experiments, or research direction.

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea 1] | [Why this matters] | [S/M/L] | [S/M/L] |

### Exploratory
- [ ] [Idea that needs investigation]
- [ ] [Hypothesis to test]

---

## 🛠️ Engineering

Infrastructure, code quality, performance, and developer experience.

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea 1] | [Why this matters] | [S/M/L] | [S/M/L] |

### Technical Debt
- [ ] [Refactoring needed]
- [ ] [Code smell to fix]

### Performance
- [ ] [Optimization opportunity]

---

## 🤖 ML / Training

Model architecture, training process, and ML infrastructure.

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| [Idea 1] | [Why this matters] | [S/M/L] | [S/M/L] |

### Experiments to Run
- [ ] [Experiment 1]: [hypothesis]
- [ ] [Experiment 2]: [hypothesis]

### Model Improvements
- [ ] [Architecture change]
- [ ] [Training optimization]

---

## 📋 Backlog (Ungrouped)

Ideas that don't fit neatly into categories or need more thought.

- [ ] [Idea]
- [ ] [Idea]

---

## Sources Analyzed

| Source | Date | Key Topics |
|--------|------|------------|
| `.specstory/history/[file].md` | [date] | [topics] |
| Recent commits | [range] | [features added] |
| Code TODOs | - | [count] found |
```

---

## Categories Explained

### 🔬 Science / Research
- Experiment design
- Hypothesis testing
- Data collection/analysis
- Scientific methodology
- Publication-worthy improvements
- Ablation studies

### 🛠️ Engineering
- Code quality / refactoring
- Performance optimization
- Testing / CI/CD
- Documentation
- Developer experience
- Infrastructure / deployment
- Error handling

### 🤖 ML / Training
- Model architecture changes
- Training loop improvements
- Hyperparameter optimization
- Data augmentation
- Loss function changes
- Evaluation metrics
- Sweep configurations

---

## Effort/Impact Scale

| Rating | Effort | Impact |
|--------|--------|--------|
| **S** | < 1 day | Minor improvement |
| **M** | 1-5 days | Notable improvement |
| **L** | > 1 week | Major improvement |

Prioritize: **High Impact + Low Effort** first

---

## Ideation Process

1. **Gather context** - Run the bash commands above
2. **Read .specstory files** - Look for patterns, pain points, ideas mentioned
3. **Check code TODOs** - What did developers leave as notes?
4. **Review recent commits** - What direction is the project heading?
5. **Read CLAUDE.md** - What's the current focus?
6. **Categorize ideas** - Group into Science/Engineering/ML
7. **Prioritize** - Rate effort and impact
8. **Write IDEAS.md** - Use the template

---

## What to Look For

### In Chat History
- "We should..." / "We could..."
- "TODO" / "FIXME" mentions
- Complaints about slowness or friction
- Features mentioned but not implemented
- Alternative approaches discussed

### In Code
- `# TODO:` and `# FIXME:` comments
- Commented-out code (why was it disabled?)
- Complex functions that could be simplified
- Repeated patterns that could be abstracted

### In Commits
- Patterns in what's being changed
- Features partially implemented
- Bug fixes (what could prevent similar bugs?)

---

## Example Output

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# IDEAS.md - Future Improvements

**Generated:** 2024-12-22
**Based on:** 5 .specstory chats, 47 commits, 12 code TODOs

---

## 🔬 Science / Research

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| Add molecular weight as feature | Mentioned in 3 chats as predictor | M | L |
| Ablation on embedding dimensions | Unknown if 768 is optimal | M | M |

### Exploratory
- [ ] Test pretrained vs random init embeddings
- [ ] Compare SMILES vs graph representations

---

## 🛠️ Engineering

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| Lazy model loading | Memory issues on startup (chat 12/20) | S | L |
| Cache embeddings to disk | Recomputing on every run | M | M |

### Technical Debt
- [ ] Refactor `train.py` (450 lines, hard to follow)
- [ ] Type hints for core modules

### Performance
- [ ] Profile data loader bottleneck
- [ ] Batch prediction for inference

---

## 🤖 ML / Training

### High Priority
| Idea | Rationale | Effort | Impact |
|------|-----------|--------|--------|
| Gradient checkpointing | OOM on large batches | S | L |
| Learning rate warmup | Training instability in early epochs | S | M |

### Experiments to Run
- [ ] Sweep batch sizes [16, 32, 64, 128]
- [ ] Compare AdamW vs Lion optimizer
- [ ] Test dropout rates [0.1, 0.2, 0.3]

---

## Sources Analyzed

| Source | Date | Key Topics |
|--------|------|------------|
| `.specstory/history/2024-12-20_training.md` | 12/20 | OOM issues, batch size |
| `.specstory/history/2024-12-21_features.md` | 12/21 | Molecular features |
| Code TODOs | - | 12 found |
```

---

## Always End With a Follow-Up Question

| Situation | Question |
|-----------|----------|
| Ideas generated | "Should I prioritize any of these? Or add more detail to specific ideas?" |
| Many ideas found | "Want me to focus on a specific category (Science/Engineering/ML)?" |
| Few ideas found | "Should I dig deeper into a specific area of the codebase?" |

**Default:** "Which ideas should we explore further?"

---

## Related Commands

| Situation | Suggest |
|-----------|---------|
| Want to implement an idea | → **pr-manager** or **git-manager** |
| Need current status first | → **update** |
| End of session | → **handover** |
| Starting fresh | → **continue** |

