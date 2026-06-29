# sys-commit

Handles the final git commit step for any repo. Works standalone (asks for context) or invoked mode (receives title, body, and repo_path from a calling skill). Never pushes.

## Design decisions

- Invoked mode: caller passes title, body, repo_path, and already_committed; the skill shows the user for approval then commits
- Standalone mode: gathers context itself before generating the commit message
- Never pushes under any circumstances -- always stops at commit
- The user sees the generated title and body before any commit is made

## Integration

Called by ext-changelog at the end of the changelog generation flow. ext-changelog generates the title and body; sys-commit handles user approval and the actual git commit.

## Related skills

- `ext-changelog`: Primary caller
- `ext-publish`: Calls ext-changelog which in turn calls sys-commit
