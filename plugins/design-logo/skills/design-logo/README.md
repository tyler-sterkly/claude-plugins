# design-logo

Design and iterate on logos using SVG. Generates side-by-side previews and exports to PNG at standard sizes. Optionally integrates the final logo into a project repo.

## When to trigger

Use this skill when the user asks to:
- "Create a logo"
- "Design a logo"
- "Make me a logo"
- "Iterate on this logo"
- "Logo for my project"
- Discuss logo design, branding icons, or wordmarks

## How it works

The skill runs in 5 phases: Interview, Explore, Refine, Export, and optionally Repo Integration.

### Phase 1: Interview

Gathers context before generating anything.

If the user points to a repo or project, the skill reads README, package.json, CSS/config files, and any existing branding first, then asks only what isn't already known.

Structured questions (batched, skipping anything already answered):
- **Format**: icon only (512x512), wordmark only (1024x512), or combination mark (icon + text, 1024x512)
- **Style direction**: minimal/geometric, playful/hand-drawn, bold/corporate, or match existing app style
- **Color preferences**: use project colors, surprise me, or specific colors
- **Size** (only if a specific platform was mentioned)

If the user says "just make something", the skill uses sensible defaults and skips to Phase 2.

### Phase 2: Explore

Generates 3-5 **distinct** SVG logo concepts in parallel, each taking a meaningfully different creative direction (e.g., geometric letterform, abstract symbol, mascot-based). Minor variations of the same idea are not generated.

Each concept is saved to `logos/concepts/concept-N.svg`. After all concepts are generated, a `logos/preview.html` is produced with a light/dark toggle and the user is asked to pick a direction.

### Phase 3: Refine

Iterates on the chosen concept. Two modes:
- **Single iteration**: user gives specific feedback, the change is applied and saved as the next `logos/iterations/iteration-N.svg`
- **Batch variations**: user wants to explore multiple directions at once (e.g., "try 3 color palettes"), generated in parallel

`logos/preview.html` is regenerated after each iteration showing all iterations most recent first, plus a favicon size check strip (64px, 32px, 16px renders) to catch legibility issues early.

If the user says "go back to iteration N", that becomes the new base.

### Phase 4: Export

Triggered when the user says "export", "I'm happy with this", "this is the one", or similar.

1. Final iteration SVG is copied to `logos/export/logo.svg`
2. Export script runs to produce PNGs at: 16, 32, 48, 192, 512, 1024, 2048px
3. Results are reported with file sizes

If no SVG-to-PNG converter is found, the user is told to install one (`@aspect-build/resvg`, Inkscape, or librsvg).

### Phase 5: Repo Integration (optional)

If the user asks to commit to a repo or create a PR:
1. Checks the repo for existing icon/logo files (favicon.svg, favicon.ico, pwa-*.png, etc.)
2. Creates a branch (`chore/new-logo`)
3. Replaces only files that already exist in the repo (no new files added)
4. Generates platform-specific sizes: favicon.ico (48px), apple-touch-icon (180px), pwa-192 (192px), pwa-512 (512px), iOS AppIcon (1024px)
5. Commits and creates a PR

## SVG conventions

Every generated SVG follows these rules:
- `viewBox="0 0 W H"` without fixed `width`/`height` attributes (512x512 for icons, 1024x512 for wordmarks/combination marks)
- Self-contained: no external fonts, images, or `<use>` references
- Text uses widely available system fonts with fallbacks, or is converted to `<path>` elements
- Logical groups use `<g>` with descriptive IDs: `id="icon"`, `id="wordmark"`, `id="tagline"`
- Solid fills by default; gradients only when requested or clearly called for
- Details must survive 16-32px (favicons); stroke-width 6+ for visible outlines
- Clean markup: no unnecessary transforms, no empty groups

## Inputs

- A design brief (format, style, colors, project context)
- Optionally: an existing repo or project to extract design language from
- User feedback during iteration

## Outputs

```
logos/
├── concepts/
│   ├── concept-1.svg
│   ├── concept-2.svg
│   └── ... (up to concept-5.svg)
├── iterations/
│   ├── iteration-1.svg
│   ├── iteration-2.svg
│   └── ...
├── export/
│   ├── logo.svg
│   ├── logo-16.png
│   ├── logo-32.png
│   ├── logo-48.png
│   ├── logo-192.png
│   ├── logo-512.png
│   ├── logo-1024.png
│   └── logo-2048.png
└── preview.html
```

## Edge cases and limitations

- Export requires an SVG-to-PNG converter (resvg, Inkscape, or librsvg). The skill reports clearly if none is found.
- Repo integration only replaces files that already exist; it does not add new asset types to a project.
- Parallel concept/iteration generation uses Task agents that do not share context: each agent must receive the full brief and SVG conventions inline.
- The favicon size check strip in the preview catches small-size legibility issues before export.

## Non-obvious uses

- Can be used to audit an existing logo for small-size legibility without designing a new one (just move to Phase 3 with the existing SVG)
- Batch variation mode in Phase 3 is useful for A/B testing color palettes or icon treatments across a team
- Repo integration can update favicon, PWA icons, and iOS app icons all in one PR

## Related skills

- `design-icon-set`: Generates the full icon set (PNG sizes + favicon.ico) from a final icon SVG
- `design-svg`: SVG authoring engine
- `design-frontend-ui`: Full frontend UI design
