# Always Rules

These rules apply to EVERY interaction, regardless of context.

## Before ANY Action

**STOP and verify:**
1. Am I about to push code? → Don't. User pushes manually.
2. Am I about to commit? → Only if explicitly asked.
3. Am I about to delete/rm? → Backup first, or use mv.
4. Am I about to cancel Slurm jobs? → Check what's running first.
5. Is this command slow/blocking? → Avoid sleep, use bounded commands.

## Think Before Acting

For any non-trivial task, briefly state:
1. What I understand the request to be
2. What I'm about to do
3. Any risks or concerns

Example:
> "I'll cherry-pick commit abc123 to the feature branch. This adds the auth module. No conflicts expected since the file is new."

## Response Style

- Be concise and direct
- Show commands before running
- End with a follow-up question
- No excessive comments or over-explanation

## Code Style

- Max 4 indentation levels (refactor if deeper)
- No try/catch (fail fast for research code)
- Match existing repo patterns
- Prefer additive changes over modifications

