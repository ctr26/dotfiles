---
tag: CODE-STYLE
scope: global
---
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

## Error Handling Philosophy

| Code Type | Strategy | Why |
|-----------|----------|-----|
| **Research/experiment** | No try/catch - fail fast | Errors must be visible for debugging |
| **Production internal** | No try/catch - propagate | Let errors bubble up to boundaries |
| **System boundaries** | Handle with specific catches | API endpoints, file I/O, external calls |

```python
# ❌ BAD: Try/catch hiding errors (anywhere)
try:
    result = risky_operation()
except Exception:
    pass  # Silently fails!

# ✅ GOOD: Let it fail (research code)
result = risky_operation()  # Will raise if broken

# ✅ GOOD: Handle at system boundary (production)
def api_endpoint(request):
    try:
        data = parse_request(request)
        return success_response(process(data))  # process() has no try/catch
    except ValidationError as e:
        return error_response(400, str(e))
```

## Git Commits

Format: `[tag] lowercase description under 72 chars`

Tags: `[feat]`, `[fix]`, `[ref]`, `[docs]`, `[test]`, `[init]`, `[cfg]`, `[bug]`

### Atomic Commits
- **Many small commits** over few large ones (verbose = quantity, not message length)
- Each commit must be **standalone** and cherry-pick-able
- Codebase should be healthy at every commit
- When in doubt, split

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

