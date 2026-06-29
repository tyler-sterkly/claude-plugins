# ext-context

Generates a comprehensive CLAUDE.md for a Firefox extension project by reading all non-dotfile project files and writing a structured reference covering architecture, API surface, coding conventions, and gotchas.

## Design decisions

- Extension type is classified first (Template / VPN / Ad-blocking / Streaming / Utility) -- it determines which files to read and which sections to generate
- background-core.js is never read in full -- its API surface (ExtCore.PRODUCT, ExtCore.DOMAINS, CLIENT_OBJECT.KEYS, CHROME_STORAGE.KEYS, COOKIE_STORAGE.KEYS, storage helpers, lifecycle, message handler) is documented in the SKILL.md template and used as a known-good baseline
- Sections that do not apply are skipped entirely (no VPN section on a non-VPN extension, no LP section if LPDOMAIN is not active)
- EXTENSION.md is the authoritative identity source when present

## Key constraint

Do not mention internal org names (Sterkly, BitBoxMedia) anywhere in the generated CLAUDE.md.

## Output

Writes CLAUDE.md to the project root (not to any subdirectory). Always saves before responding.

## Related skills

- `ext-audit`: Can use the generated CLAUDE.md as context
- `ext-duplicate`: Writes a simpler CLAUDE.md as part of the duplication flow (ext-context generates a more detailed one)
- `ext-md`: Creates EXTENSION.md (different file, different purpose)
