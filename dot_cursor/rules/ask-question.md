---
tag: ASK-QUESTION
---
# ask_question Tool Enforcement

**STRICT RULE:** Use the `ask_question` tool for ANY question with discrete options.

---

## When to Use ask_question (MUST)

| Situation | Example |
|-----------|---------|
| Scope narrowing | "Which file should I focus on?" |
| Implementation choice | "Use approach A, B, or C?" |
| Yes/No confirmation | "Should I proceed with X?" |
| Configuration selection | "Which config option?" |
| Plan approval alternatives | "Modify plan or execute?" |
| Error resolution | "Fix with option A or B?" |

---

## When Plain Text Is OK

| Situation | Why |
|-----------|-----|
| Open-ended clarification | No discrete options exist |
| Follow-up within flow | Already mid-conversation |
| Single obvious action | No choice needed |
| Reporting results | Information, not decision |

---

## Format Requirements

When using `ask_question`:

1. **Clear title** - What decision is being made
2. **2-6 options** - Not too many, not too few
3. **First option = default** - If user doesn't answer, assume first
4. **Mutually exclusive** - Unless `allow_multiple: true`

---

## Anti-Patterns (NEVER DO)

```markdown
# BAD: Discrete options in plain text
"Would you like me to:
A) Fix the bug
B) Add a test first
C) Investigate more

Let me know which you prefer."
```

```markdown
# GOOD: Use ask_question tool
ask_question(
  title="How to proceed with the bug?",
  options=[
    {"id": "fix", "label": "Fix the bug directly"},
    {"id": "test", "label": "Add a failing test first"},
    {"id": "investigate", "label": "Investigate root cause more"}
  ]
)
```

---

## Planning Mode (EXTRA STRICT)

When in planning mode:

1. **All scope questions** → ask_question
2. **All implementation alternatives** → ask_question
3. **All clarifications with options** → ask_question

**Never interpret "yes" or "sounds good" as plan approval.** Only the explicit plan UI action exits planning mode.

---

## Integration

All agents and commands should reference this rule. Add to your "Before Any Action" checklist:

```
✓ If I'm about to ask a question with options, use ask_question tool
```

