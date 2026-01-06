# Code Style Rules

## Before Writing Code

1. **Check .env** for preferred packages/versions
2. **Study existing patterns** in the repo
3. **Look at imports** to understand dependencies
4. **Match the style** already in use

## Formatting

- Follow **black/ruff** conventions
- **Max 4 indentation levels** - extract to functions if deeper
- Keep lines reasonable length
- Use descriptive variable names

## Architecture

- **Minimal changes** - prefer additive over modificative
- **Consolidate** - avoid file proliferation
- **Use abstractions** to reduce net LOC
- **One concern per function/commit**

## What to Avoid

```python
# ❌ BAD: Deep nesting
def process():
    for item in items:
        if condition:
            for sub in item.subs:
                if sub.valid:
                    for x in sub.data:
                        if x.ready:
                            do_thing(x)  # 6 levels deep!

# ✅ GOOD: Extract to functions
def process():
    for item in items:
        if condition:
            process_item(item)

def process_item(item):
    for sub in item.subs:
        if sub.valid:
            process_sub(sub)

def process_sub(sub):
    for x in sub.data:
        if x.ready:
            do_thing(x)
```

```python
# ❌ BAD: Try/catch hiding errors
try:
    result = risky_operation()
except Exception:
    pass  # Silently fails!

# ✅ GOOD: Let it fail (research code)
result = risky_operation()  # Will raise if broken
```

## Git Commits

Format: `[tag] lowercase description under 72 chars`

Tags: `[feat]`, `[fix]`, `[ref]`, `[docs]`, `[test]`, `[init]`, `[cfg]`, `[bug]`

### Atomic Commits
- **Short, verbose commits** that leave codebase in a healthy state
- Each commit should be independently buildable/runnable
- When in doubt, split into smaller commits
- Skip test files unless explicitly asked (they often need separate review)

### Embrace Hunks
- Use `git add -p` for partial staging
- Don't be scared of staging just part of a file
- Keeps commits focused on single concerns

```bash
# ✅ Good commits
[feat] add retry backoff to api client
[fix] handle null email in user validation
[ref] extract auth logic to middleware

# ❌ Bad commits
[feat] add retry and fix email bug   # Two concerns
Updated several files                 # Meaningless
WIP                                  # Not informative
```

