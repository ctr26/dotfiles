# Slack

Draft replies to Slack questions about your codebase. Paste the message, get a copy-pasteable response in Slack mrkdwn format.

---

## Usage

`/slack [pasted message]` - Draft a reply to the pasted Slack question

---

## Workflow

### 1. Parse the Question

Identify what they're asking about:
- Specific file/function?
- How something works?
- Where something lives?
- Why a decision was made?

### 2. Gather Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Check CLAUDE.md for project context
cat "$REPO_ROOT/CLAUDE.md" 2>/dev/null | head -50

# Search for mentioned keywords
# grep -r "keyword" --include="*.py" "$REPO_ROOT/src" | head -10

# Recent relevant commits
# git log --oneline --all --grep="keyword" | head -5
```

Search the codebase for files/functions mentioned in the question. Read relevant code to understand context.

### 3. Draft Reply

Output in **Slack mrkdwn format** (not standard markdown):

| Element | Slack mrkdwn |
|---------|--------------|
| Bold | `*bold*` |
| Italic | `_italic_` |
| Strikethrough | `~strike~` |
| Code inline | `` `code` `` |
| Code block | ` ```code``` ` |
| Link | `<url\|text>` |
| Quote | `> quoted text` |

---

## Response Template

```
*Re: [topic from their question]*

[2-3 sentence answer - direct and helpful]

`path/to/relevant/file.py` - [what it does]

[Optional: short code snippet if it helps]
```

---

## Tone Guidelines

| Their tone | Your response |
|------------|---------------|
| Casual ("hey where's the...") | Friendly, brief |
| Technical ("what's the interface for...") | Precise, include types/signatures |
| Confused ("I can't figure out...") | Empathetic, step-by-step |
| Urgent ("this is broken...") | Direct, actionable |

---

## Examples

**Question:** "hey where does the auth logic live?"

**Response:**
```
*Re: auth logic location*

Auth is in `src/auth/` - main entry point is `authenticate.py`. Token validation happens in `jwt_handler.py`.

`src/auth/authenticate.py` - login/logout flows
`src/auth/jwt_handler.py` - token creation & validation
```

**Question:** "what's the expected format for the config file?"

**Response:**
```
*Re: config format*

We use YAML configs in `configs/`. The schema is defined in `src/config/schema.py`.

Required fields:
• `model.name` - model identifier
• `training.epochs` - number of epochs
• `data.path` - dataset location

Example in `configs/example.yaml`
```

---

## Keep It Slack-Sized

- **Max 10-15 lines** - Break longer answers into follow-up messages
- **Bullet points** - Use `•` or `-` for lists (both work in Slack)
- **One topic per message** - Don't answer 5 questions in one wall of text
- **Link don't paste** - Reference file paths, don't dump whole files

---

## Output

After drafting, present the response in a code block for easy copying:

> "Here's your Slack reply:"
> 
> ```
> [the mrkdwn-formatted response]
> ```
> 
> "Copy and paste into Slack. Want me to adjust the tone or add more detail?"

---

## Related Commands

| Need | Command |
|------|---------|
| Explain feature in detail | → **ideate** |
| Check project status | → **update** |
| Persist context for later | → **note** |

