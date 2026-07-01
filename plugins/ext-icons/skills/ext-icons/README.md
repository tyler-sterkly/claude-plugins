# ext-icons

Generate a complete icon set from a single square source icon, a multi-size Windows `favicon.ico`, and an optional matching logo lockup (`logo.svg` + `logo.png`).

## When to trigger

Use this skill when the user asks to:
- Generate icons or create an icon set
- Produce favicon and PNG sizes
- Convert an icon to multiple sizes
- Build a favicon
- Build a logo or logo lockup for an extension
- "Generate icons for my extension"
- "I need a favicon.ico"
- "Create icon16, icon32, icon48, icon128"
- "Make a logo for this extension"

Also triggers when the user attaches an SVG or PNG and wants multiple sizes out, or mentions any specific icon size.

Always use this skill for icon generation tasks even if the request seems simple.

## How it works

### Step 0: Read EXTENSION.md

If `EXTENSION.md` exists in the project root, read it for:
- **Name**: used as the product name for icon concepts and logo wordmark
- **Brand Color Scheme**: used as the color palette, skips asking the user for colors
- **Icon Style**: used as a starting point for concept generation

After icons and logo are approved, the `Branding` section of `EXTENSION.md` is updated with the final color palette and icon style.

### Step 1: Get or generate the source icon SVG

The SVG is the single source of truth for all rendered files.

- **User provides an SVG**: saved as `icons/icon.svg` and used directly
- **User provides a raster (PNG etc.)**: converted to SVG, colors/geometry sampled precisely, rebuilt with fewest primitives, visually diffed before continuing
- **No source provided**: concept generation flow runs (see below)

**Icon concept generation** (when no source is provided):
Generates 4 distinct 128x128 SVG concepts across four visual directions:
- Symbolic: an object or symbol related to the product's function
- Letterform: a stylized initial or abbreviation
- Abstract: a geometric shape conveying the feel
- Metaphorical: a visual metaphor for what the product does

All 4 are displayed inline with one-line descriptions. The user picks one (as-is or with modifications), requests 4 new directions, or provides their own source. The skill does not proceed until one is approved. After 3 rounds of rejection, the skill stops and asks for more specific direction.

### Step 2: Generate the icon set (PNG sizes)

Default set rendered from the approved SVG:

| File | Size |
|---|---|
| icon16.png | 16x16 |
| icon32.png | 32x32 |
| icon48.png | 48x48 |
| icon64.png | 64x64 |
| icon128.png | 128x128 |

Each size is rendered directly from the SVG at its exact pixel dimensions. Never upscaled from another PNG.

Custom lists (name, type, size) are supported when the user specifies them.

### Step 3: Generate the favicon (always required)

Always produces `favicon.ico` regardless of the icon list. The favicon is written to the **project root** (same level as `manifest.json`), never inside `icons/`.

The ICO file is multi-resolution and contains 16x16, 32x32, and 48x48 sizes combined into a single Windows ICO file. All sizes are rendered from the SVG, not upscaled.

### Step 4: Generate the logo (when a product name is available)

Always generates a horizontal logo lockup after the icon is approved. If the user provides logo rules upfront, those take precedence.

**Layout**: icon on the left, wordmark on the right, approximately 5:1 width-to-height ratio, wordmark vertically centered against the icon.

**Font and style flow**:
1. Asks the user for style/color direction
2. Produces 4 distinct variants (different fonts/weights/treatments) and displays them inline
3. User picks one or requests new variants
4. Does not proceed until approved

**Wordmark vectorization**: once the font is decided, converts the wordmark text to vector `<path>` outlines using the font's glyph data so there is no font dependency. The final `logo.svg` contains no `<text>` element. Falls back to `<text>` only if path conversion is genuinely not possible (and flags the dependency).

**Dark variant**: for colored logos, also produces `logo-dark.svg`.

Renders `icons/logo.png` from the approved `icons/logo.svg` at native dimensions, transparent background, exact aspect ratio.

### Step 5: Deliver

- **Standalone**: zips all files (icon PNGs, `favicon.ico`, logo files, source `icon.svg`) and provides a download link
- **Called from `duplicate-firefox-extension`**: writes files directly into the project with no zip

## Inputs

- A product/extension name (or EXTENSION.md with one)
- Optionally: an existing SVG or PNG source icon
- Optionally: brand colors, icon style, font preferences

## Outputs

| File | Location |
|---|---|
| icon.svg | icons/ |
| icon16.png | icons/ |
| icon32.png | icons/ |
| icon48.png | icons/ |
| icon64.png | icons/ |
| icon128.png | icons/ |
| favicon.ico | project root |
| logo.svg | icons/ |
| logo-dark.svg | icons/ (colored logos only) |
| logo.png | icons/ |

## SVG validation rules

Every SVG this skill produces must have:
- Both `width`/`height` AND `viewBox` attributes (missing width/height renders 0x0 in img tags)
- `xmlns` attribute
- Tight viewBox (no extra padding)
- No editor metadata (no Inkscape/Illustrator namespaces)

## Edge cases and limitations

- After 3 rounds of rejected icon concepts, the skill stops and asks for more specific direction
- If `sys-svg` is installed, SVG authoring is delegated to it. If not, SVGs are authored inline.
- Logo matching an existing asset: the skill checks how the existing logo is sized in CSS/markup and matches the aspect ratio so nothing distorts
- The `favicon.ico` must be confirmed to contain all three resolutions after generation
- Previews use ImageMagick-rendered PNGs, not a `preview.html` workflow (Windows compatible)

## Related skills

- `sys-svg`: SVG authoring engine used internally by this skill
- `sys-logo`: Standalone logo design with more iteration depth
- `design-frontend-ui`: Full frontend UI design
