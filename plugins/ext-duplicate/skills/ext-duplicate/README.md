# ext-duplicate

Scaffolds a new Firefox extension by duplicating an existing one, wiring in new config values, genericizing source-brand identifiers, verifying against the FF-extension-Template, building a new icon set, writing listing verbiage, and producing a complete README and CLAUDE.md.

## When to trigger

Use this skill when the user asks to:
- "Duplicate a Firefox extension"
- "Clone an extension"
- "Create a new extension from an existing one"
- "Copy an extension project"
- Any variation of bootstrapping a new extension from an existing one

## Inputs required

Asked in one message -- do not proceed until Source, New directory, Extension Name, Domain, and Icons are provided:

| Field | Required |
|---|---|
| Source directory | Yes |
| New project directory | Yes |
| Extension Name | Yes |
| Domain | Yes |
| LP Domain | No |
| ExtID | No (say "generate", paste existing, or "skip") |
| FF ExtID | No (say "generate", paste existing, or "skip") |
| Icons | Yes (provide file, "generate", or "skip") |

## How it works

1. **Create** the new project directory and copy files from source (excluding dotfiles, node_modules, META-INF, .builds, __MACOSX)
2. **Wire** all 10 REPLACE_* placeholder tokens across config.js, messages.json, manifest.json, and script.js
3. **Genericize** source-extension brand identifiers (class names, window bindings, variable names, log prefixes, comments) -- does not touch config values or new-brand identifiers
4. **Verify** shared files against FF-extension-Template; update outdated ones; set strict_min_version to 142.0
5. **Build icons** via ext-icons skill (skip, generate, or use provided source)
6. **Write verbiage** via ext-verbiage skill; write manifest description to manifest.json; save listing copy to .docs/LISTING.txt
7. **Write README.md and CLAUDE.md** with all config data
8. **Write EXTENSION.md** (copied from source or template, all fields updated for the new extension)
9. **List unreferenced files** for the user to review (nothing auto-deleted)
10. **Deliver a plan** summarizing what was created, what was applied, and what still needs to be done

## Wiring notes

- `REPLACE_SEARCH_NAME` must exactly equal `NAME` in config.js -- a mismatch means SearchEngineAccepted never fires
- `REPLACE_PRODUCT_DOMAIN` appears in three places in manifest.json (two content_scripts matches and search_url)
- `REPLACE_FIREFOX_UUID` appears in both config.js and manifest.json gecko.id

## Outputs

| File | Where |
|---|---|
| New extension files | New project directory |
| icons/ | Built by ext-icons |
| .docs/LISTING.txt | Listing copy from ext-verbiage |
| README.md | New project root |
| CLAUDE.md | New project root |
| EXTENSION.md | New project root |

## Related skills

- `ext-ids`: Called after Step 3 when user says "generate" for ExtID/FFADDID
- `ext-icons`: Called in Step 6 to build the icon set
- `ext-verbiage`: Called in Step 7 to write listing copy
- `ext-context`: Generates a detailed CLAUDE.md (ext-duplicate writes a simpler version)
