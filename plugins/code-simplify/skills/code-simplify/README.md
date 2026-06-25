# code-simplify

Reviews changed code for reuse, simplification, efficiency, and altitude cleanups, then applies the fixes directly. Quality-only: does not hunt for bugs.

## When to trigger

Use this skill when the user asks to:
- Simplify code
- Clean up or streamline code
- Refactor for clarity or DRY-ness
- "Remove complexity from this"
- "Make this code cleaner"
- "Can you simplify this file?"

Always use this skill for simplification tasks even if the request seems simple.

## How it works

1. Read the target file(s) or diff
2. Identify simplification opportunities from the checklist below
3. Apply each fix directly to the file
4. Skip any fix that requires judgment where the change would make the code harder to follow in context
5. Summarize what was changed, one line per change

## What it looks for

| Pattern | Action taken |
|---|---|
| Duplicated logic | Extract to a shared function |
| Abstraction with no benefit | Inline it |
| Dead code (unused vars, functions, imports) | Delete it |
| Over-engineered solution for a simple problem | Replace with simpler equivalent |
| Intermediate variable used only once | Inline the expression |
| Nested conditionals | Flatten with early returns |
| Manual loops replaceable with array methods | Use map/filter/reduce/find |
| Constants defined far from their only use | Move closer |
| Comments that explain what (not why) | Delete the comment |

## What it does NOT do

- Does not change behavior
- Does not add error handling that wasn't there
- Does not introduce new abstractions, only removes unnecessary ones
- Does not rename things unless the current name is actively misleading
- Does not touch code outside the scope the user specified
- Does not hunt for bugs (use `code-review` for that)

## Inputs

- A file path, directory, or diff to review (provided by the user or inferred from context)

## Outputs

Changes applied directly to the files, followed by a summary:

```
Simplified:
- Extracted duplicated X into helper Y (lines 23, 47, 81)
- Removed unused import Z
- Replaced manual loop with .filter() at line 55
- Deleted comment at line 12 that restated the function name
```

## Edge cases and limitations

- Judgment calls where an extraction would hurt readability are skipped
- Only touches the scope the user specified, not the entire codebase
- Does not verify that tests still pass after changes (assumed to run in CI)

## Related skills

- `code-review`: Bug and CLAUDE.md compliance review
- `code-security-review`: OWASP security audit
