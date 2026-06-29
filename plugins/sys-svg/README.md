# sys-svg

Generates and edits SVG logos, icons, and graphics by writing SVG as code. Covers path commands, shape primitives, styling, accessibility, gradients, masks, sprites, optimization, and animation.

## When to trigger

Use this skill when the user asks to:
- Create or edit an SVG file
- Design a logo or icon in SVG
- Write or fix SVG path data
- Optimize an SVG
- Build an icon system
- Animate SVG elements
- "Write me an SVG for X"
- "Fix the path in this SVG"
- "Convert this shape to a path"
- "Add animation to this SVG"

## How it works

SVGs are treated as code: written by hand, minimal, and semantically meaningful. Every element and attribute must earn its place.

The skill uses a topic routing table to load the right reference for each task:

| Task | Reference loaded |
|---|---|
| Arc flags, common path shapes | path-patterns.md |
| Logo design, typography, negative space | logo-techniques.md |
| Icon design, grid systems, pixel alignment | icon-design.md |
| Gradients, masks, clips, filters, transforms | advanced-techniques.md |
| CSS keyframes, stagger, GPU acceleration, easing | animation.md |
| Optimization, sprites, SVGO config | optimization.md |
| Accessibility, browser pitfalls | accessibility-and-pitfalls.md |
| Editing workflow, boolean operations, combining SVGs | editing-workflow.md |

## SVG structure

Every generated SVG starts from:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <!-- content -->
</svg>
```

`width`/`height` attributes are omitted by default so the SVG scales with its container. Added only when a fixed size is required.

## Canvas size conventions

| viewBox | Use case |
|---|---|
| 0 0 16 16 | Micro icons, favicons |
| 0 0 20 20 | Small UI icons, form elements |
| 0 0 24 24 | Standard icons (default) |
| 0 0 32 32 | Medium icons, navigation |
| 0 0 48 48 | Large display icons |
| Custom | Logos, illustrations (match natural aspect ratio) |

Default is 24x24 unless there's a reason otherwise.

## Styling defaults

Set on the root `<svg>` element:

| Attribute | Icon | Logo |
|---|---|---|
| `fill` | `none` | varies |
| `stroke` | `currentColor` | `none` or `currentColor` |
| `stroke-width` | `2` (on 24x24) | varies |
| `stroke-linecap` | `round` | `round` or `butt` |
| `stroke-linejoin` | `round` | `round` or `miter` |

`currentColor` lets the SVG inherit the parent element's color, making icons themeable with no extra CSS.

## Logo design process

When creating logos, the skill always clarifies design direction before writing any SVG:

1. Uses `AskUserQuestion` to present curated design direction choices (visual personality, focus, and inspiration logos from the user's actual industry)
2. Explores multiple metaphors and structural categories (typographic, symbolic, abstract geometric, letterform hybrid)
3. Sets up a preview file immediately, then populates it progressively as each concept is completed
4. Produces a `-dark.svg` variant for all colored logos
5. Plans vertical budget before drawing (especially important for stacked elements on small canvases)

The only skip for the clarification step: when the user has specified both a concrete visual style AND specific imagery (e.g., "minimalist geometric logo using a mountain silhouette in navy blue").

## Inputs

- A description of what to create or edit
- For logos: project name, industry, any existing branding
- For edits: the existing SVG file
- Design direction preferences (answered through structured questions for logos)

## Outputs

- An SVG file (or inline SVG markup)
- For logos: multiple concept SVGs plus a preview.html with a dark/light toggle, and a `-dark.svg` variant
- For edits: the modified SVG file

## Anti-patterns avoided

| Never | Instead |
|---|---|
| `width="24" height="24"` without `viewBox` | Always use `viewBox`; add width/height only if needed |
| `fill="none"` on a `<g>` group | Set fill on individual elements or root `<svg>` |
| `px` units inside SVG | SVG coordinates are unitless |
| Editor metadata (`<sodipodi:*>`, `<inkscape:*>`) | Strip all editor cruft |
| `<text>` in distributed logos | Convert text to paths |
| Transforms nested 3 levels deep | Flatten into path coordinates |
| `xlink:href` | Use `href` (xlink is deprecated) |
| Missing `xmlns` on standalone files | Always include `xmlns="http://www.w3.org/2000/svg"` |
| Decimal precision beyond 2-3 places for icons | Round to 2 decimals for icons |

## Edge cases and limitations

- The preview.html workflow for logos uses `open` (macOS) or `xdg-open` (Linux). It does not work on Windows. On Windows, use `ext-icons`'s ImageMagick-based preview instead.
- When called from `ext-icons`, previews and approval gates stay in that skill, not here.
- When `ext-icons` passes constraints (128x128 canvas, no `<text>` in logos), those take precedence over this skill's defaults.

## Related skills

- `ext-icons`: Orchestrates icon set generation and calls this skill for SVG authoring
- `sys-logo`: Standalone logo design with full interview/explore/refine/export flow
- `design-frontend-ui`: Full frontend UI design
