# sys-logo

Logo design and iteration skill using SVG. Runs a brief interview before generating, produces side-by-side previews, and exports to PNG at standard sizes.

## Design decisions

- Interview phase runs before any generation -- gathers context, subject, audience, style direction
- Generates multiple concepts for comparison before committing to one
- Exports to PNG at standard sizes alongside the SVG source

## Relationship to other skills

- `sys-svg`: sys-logo delegates SVG authoring to sys-svg when detailed path work is needed; sys-logo is the design/concept layer, sys-svg is the technical SVG layer
- `ext-icons`: For extension-specific icon sets (not standalone logo work)
