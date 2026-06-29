# ext-icons

Generates a complete Firefox extension icon set (PNG sizes + favicon.ico) from a single square source, with an optional logo lockup. Delegates SVG authoring to sys-svg when available; falls back to inline authoring if not.

## Design decisions

- sys-svg is a soft dependency -- ext-icons must still work without it; never block on the plugin
- ext-icons orchestrates the full flow: concept/approval gates, then PNG rendering, favicon generation, and file placement
- All output files use lowercase with no spaces
- logo.svg and logo.png are optional outputs produced only when a product name is available and a lockup is requested
- Files are placed per Firefox conventions: PNG icons in icons/, favicon.ico at project root

## Integration with ext-duplicate

ext-duplicate calls ext-icons in Step 6. After ext-icons completes, ext-duplicate replaces all matching files in the project's icons/ directory (targets .png and .ico files with "icon" or "logo" in the name).

## Related skills

- `sys-svg`: Used to author the SVG source files
- `ext-duplicate`: Calls ext-icons as part of the extension scaffolding flow
- `sys-logo`: Alternative for standalone logo work (ext-icons is extension-specific)
