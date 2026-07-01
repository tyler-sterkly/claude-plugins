# sys-context-tuner

Reads recent Claude Code conversation history and suggests improvements to CLAUDE.md files using parallel subagents.

## Design decisions

- Scope is always confirmed with the user before any analysis runs — never assumes local vs global
- All files to be analyzed are listed and approved before spawning agents
- Focus menu narrows agent analysis to one of five categories; "no focus" runs everything
- Spawns parallel Sonnet subagents batched by file size for efficiency
- Diff-style presentation for every suggested edit — never edits files without explicit per-change approval
- Reads markdown context files (README.md, EXTENSION.md, etc.) alongside conversations for richer analysis

## Related skills

- sys-handoff — writes session context; sys-context-tuner improves the instructions that shape future sessions
- sys-context-clone — clone/branch conversations; useful before a major tune session to preserve state
