---
name: code-simplify
description: Review changed code for reuse, simplification, efficiency, and altitude cleanups, then apply the fixes. Quality only -- does not hunt for bugs. Use when the user asks to simplify, clean up, streamline, or refactor code for clarity or DRY-ness. Always use this skill for simplification tasks even if the request seems simple.
version: 1.0.0
license: MIT
---

# Code Simplify

Review code for unnecessary complexity, then apply cleanups directly. This skill is quality-only -- it does not hunt for bugs.

## What to Look For

| Pattern | Action |
|---|---|
| Duplicated logic that can be extracted | Extract to shared function |
| Abstraction that adds indirection without benefit | Inline it |
| Dead code (unused vars, functions, imports) | Delete it |
| Over-engineered solution for a simple problem | Replace with simpler equivalent |
| Intermediate variables that hold a value only used once | Inline the expression |
| Nested conditionals that can be flattened | Flatten with early returns |
| Manual loops replaceable with built-in array methods | Use map/filter/reduce/find |
| Constants defined far from their only use | Move them closer |
| Comments that explain what the code does (not why) | Delete the comment |

## What NOT to Do

- Do not change behavior
- Do not add error handling that wasn't there
- Do not introduce new abstractions -- only remove unnecessary ones
- Do not rename things unless the current name is actively misleading
- Do not touch code outside the scope the user specified

## Process

1. Read the target file(s) or diff
2. Identify simplification opportunities from the table above
3. Apply each fix directly to the file
4. If a fix requires judgment (e.g. the extraction would make the code harder to follow in context), skip it
5. After applying fixes, summarize what was changed and why -- one line per change

## Output

Apply changes directly. Then summarize:

```
Simplified:
- Extracted duplicated X into helper Y (lines 23, 47, 81)
- Removed unused import Z
- Replaced manual loop with .filter() at line 55
- Deleted comment at line 12 that restated the function name
```
