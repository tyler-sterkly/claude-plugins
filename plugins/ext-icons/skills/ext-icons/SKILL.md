---
name: ext-icons
description: Generate a full icon set from a single square source icon, a multi-size Windows favicon.ico, and an optional matching logo (logo.svg + logo.png) when a product name is available. Use this skill whenever the user asks to generate icons, create an icon set, produce favicon and PNG sizes, convert an icon to multiple sizes, build a favicon, or build a logo/logo lockup for an extension. Triggers when the user attaches an SVG or PNG and wants multiple icon sizes out, or mentions favicon, icon16, icon32, icon48, icon128, any icon size set, or a logo. Always use this skill for icon generation tasks even if the request seems simple.
---

# Design Icon Set

Generate a complete icon set, a Windows favicon, and (optionally) a matching logo from a single square source icon.

## Filename rules (apply to every file this skill writes)

- Use lowercase with no spaces. Examples: `icon16.png`, `icon32.png`, `icon48.png`, `icon64.png`, `icon128.png`, `icon.svg`, `favicon.ico`, `logo.svg`, `logo.png`.
- If the user supplies a custom output list, use the names they give (lowercased).

## SVG authoring engine (tyler-sterkly-claude-plugins:sys-svg)

The SVG files this skill produces -- the source icon (`icons/icon.svg`) and the logo lockup
(`icons/logo.svg`) -- are authored by the **sys-svg** skill when it is
available. ext-icons orchestrates: it gathers requirements, runs the concept/approval gates,
then renders the PNG sizes, the favicon, and `logo.png`, and places files per the Firefox
conventions in this skill.

- **When `sys-svg` is installed:** invoke `Skill(tyler-sterkly-claude-plugins:sys-svg)` to author each SVG.
  Install it with `/plugin install sys-svg@tyler-sterkly-claude-plugins`. Confirm the exact skill name against the live
  skills list before calling.
- **Soft fallback:** if the plugin/skill is not available, author the SVGs inline using the rules
  already written into Step 1 and Step 4. Never block on the plugin -- the skill must still work
  without it.

**Constraints to pass into `sys-svg` on every hand-off** (ext-icons owns these; they take
precedence over sys-svg defaults):
- Source icon: square **128x128** canvas, legible at 16px.
- Logo: horizontal lockup (icon on the left, wordmark on the right), **~5:1** ratio -- or match an
  existing asset's aspect ratio when replacing one.
- Transparent background; use the brand colors and product name as given.
- **Wordmark converted to vector paths -- the final `logo.svg` must contain no `<text>` element.**
- Every SVG carries **both `width`/`height` AND `viewBox`**, an `xmlns`, a tight viewBox, and no
  editor metadata. (A missing `width`/`height` renders 0x0 in `<img>` tags -- the most common cause
  of a logo that "shows as text only" in some viewers.)
- For colored logos, also produce a dark-background variant (`logo-dark.svg`).

**Previews and approval stay in this skill, not in sys-svg.** Use ext-icons's inline
rendered-PNG montages (ImageMagick) for all concept/variant previews. Do **not** use sys-svg's
`preview.html` + `open`/`xdg-open` workflow -- it is macOS/Linux and does not work on Windows.

**Design-rule tension.** sys-svg discourages gradients and drop-shadows in logos; treat that as
guidance and defer to explicit user design choices (e.g. an approved gradient pill).

## Step 0 -- Read EXTENSION.md (if present)

Check for `EXTENSION.md` in the project root. If it exists, read it and use:
- **Name** -- use as the product name for icon concept generation and logo wordmark
- **Brand Color Scheme** -- if set, use as the color palette for generated icons and logo; do not ask the user for a color direction if one is already defined here
- **Icon Style** -- if set, use as a starting point for icon concept generation

After icons and logo are approved and finalized, update the `Branding` section of `EXTENSION.md`:
- Set `Brand Color Scheme:` to the full color palette used (all hex values, e.g. primary, secondary, accent, background)
- Set `Icon Style:` to a one-line description of the approved icon design

If `EXTENSION.md` does not exist, proceed as normal.

## Step 1 -- Get or generate the source icon SVG

The SVG is the single source of truth for all rendered files.

- If the user attaches an SVG, save it as `icons/icon.svg` and use it as the source.
- If the user attaches a raster (PNG etc.), convert it to SVG, save as `icons/icon.svg`, then:
  - Sample actual pixel colors, geometry, and corner radii -- do not eyeball.
  - Rebuild with the fewest primitives possible.
  - Visually diff the reproduction against the source before continuing.
- If the user has no source icon, generate one using the concept flow below.

### Icon concept generation (no source provided)

**Author the concept SVGs with `sys-svg` when available** (see "SVG authoring engine"): pass it
the four directions and rules below. ext-icons still renders the previews and runs the
approval gate. If sys-svg is unavailable, author the concepts inline per these same rules.

Using the product/extension name and any purpose info available, produce 4 distinct 128x128 SVG concepts and display them inline so the user can see all four before choosing.

Each concept should explore a different visual direction:
- Symbolic -- an object or symbol related to the product's function
- Letterform -- a stylized initial or abbreviation of the name
- Abstract -- a geometric shape or pattern that conveys the feel
- Metaphorical -- a visual metaphor for what the product does for the user

Rules for generated icons:
- Square canvas, 128x128
- Clean, simple, legible at small sizes
- No text unless it is a single letter or two-character abbreviation
- Solid or simple gradient backgrounds are fine
- Avoid detail that won't read at 16x16

Present all 4 inline with a one-line description each. The user may: pick one as-is, pick one with modifications (describe the change), ask for 4 new concepts in a different direction, or provide their own source. Do not proceed until the user has chosen. Refine until approved. If after 3 rounds of rejection no concept has been chosen, stop and ask the user to describe more specifically what they are looking for before continuing.

## Step 2 -- Generate the icon set (PNG sizes)

Render every PNG from the approved SVG at its exact pixel size. Never upscale one PNG to make another.

Default set (use unless the user specifies a different list):

| File | Type | Size |
|------|------|------|
| icon16.png | PNG | 16x16 |
| icon32.png | PNG | 32x32 |
| icon48.png | PNG | 48x48 |
| icon64.png | PNG | 64x64 |
| icon128.png | PNG | 128x128 |

If the user provides a custom list (name, type, size), use those names and sizes (lowercased).

Spot-check the smallest and largest renders for legibility before delivering.

## Step 3 -- Generate the favicon (always required)

Always produce a `favicon.ico`. This step is mandatory -- do it even when the user supplied a custom icon list.

- Build a single multi-resolution Windows ICO that contains the 16x16, 32x32, and 48x48 sizes together.
- Render each size directly from the SVG (never upscale), then combine into one `favicon.ico`. Reliable methods: combine the rendered PNGs (`magick icon16.png icon32.png icon48.png favicon.ico`) or render-and-resize in one pass (`magick source.svg -background none -define icon:auto-resize=16,32,48 favicon.ico`).
- Write `favicon.ico` to the project ROOT directory (same level as manifest.json) -- never inside the `icons/` folder.
- Confirm afterward that the `.ico` actually contains all three resolutions.

## Step 4 -- Generate the logo (horizontal lockup, optional)

Always generate a horizontal logo lockup when a product/extension name is available. Build the logo only after the icon is approved -- it reuses the chosen icon art. If the user provides logo rules or style preferences upfront, follow them. If not, proceed with the default flow below.

**Author `icons/logo.svg` with `sys-svg` when available** (see "SVG authoring engine"), drawing
on its logo ideation and category-diversity guidance for the style step. ext-icons keeps the
inline-PNG variant previews and the approval gate, and still vectorizes the wordmark with
`fonttools` (see "Convert the wordmark to vector paths" below) so the result has no `<text>`. If
sys-svg is unavailable, author the lockup inline per the flow below.

### Layout

- Icon (the approved icon art) on the left, the product-name wordmark on the right.
- Default to a horizontal lockup around a 5:1 width-to-height ratio. If the logo will replace an existing one, match the existing asset's aspect ratio and usage first: check how it is sized in CSS/markup (e.g. a fixed `background-size`) and keep the same ratio so nothing distorts.
- Vertically center the wordmark against the icon.
- Size the wordmark to fill the available width with a small, balanced right margin -- large enough to read, never clipped by the canvas edge.

### Font and style

- Ask the user for a style/color direction first (font feel, color palette), the same way icon concepts are gathered.
- Produce 4 distinct variants (different fonts / weights / treatments -- e.g. semibold, bold, rounded, uppercase-tracked) and present all 4 inline for the user to pick. Then:
  - Pick one as-is
  - Pick one with modifications (describe what to change)
  - Ask for 4 new variants in a different direction
  - Do not proceed until the user has chosen. Refine until approved.
- Use fonts actually installed on the system so previews are accurate.

### Convert the wordmark to vector paths

Once the font is decided, convert the wordmark text to vector `<path>` outlines so the logo renders identically everywhere with no font dependency. The final `logo.svg` must contain no `<text>` element:

- Read the chosen font's glyph outlines from its font file (e.g. with `fonttools`: load the TTF/OTF, map characters to glyphs, draw each glyph through an SVG path pen, scaling by `font_size / unitsPerEm` and flipping the y-axis, advancing by each glyph's horizontal metric).
- Keep the icon art as paths/shapes too.
- If path conversion is genuinely not possible, fall back to a `<text>` element with the chosen font plus a safe generic fallback, and flag the font dependency to the user.

Save the result as `icons/logo.svg`. Show a rendered preview for approval and refine (font, color split, spacing, size) until approved.

### Render the logo PNG

Render `icons/logo.png` from the approved `icons/logo.svg` at the SVG's native dimensions (its `width`/`height` or viewBox), with a transparent background. Render directly from the SVG -- never upscale. Preserve the aspect ratio exactly; do not crop or pad. Write `icons/logo.png` next to `icons/logo.svg`.

## Step 5 -- Deliver

- If called standalone: zip the icon set, `favicon.ico`, the logo files (if any), and the source SVG (`icons/icon.svg`) into a single archive and provide a download link.
- If called from duplicate-firefox-extension: write the files directly into the project (no zip; duplicate-firefox-extension handles placement):
  - icon set PNGs -> the project's `icons/` directory
  - `favicon.ico` -> the project ROOT directory
  - `logo.svg` and `logo.png` -> the `icons/` directory
  - the source `icon.svg` -> the `icons/` directory

Keep file names exactly as specified -- downstream tooling depends on them.
