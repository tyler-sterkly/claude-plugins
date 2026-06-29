# sys-svg

SVG authoring skill covering path commands, shape primitives, styling, gradients, masks, animation, accessibility, and optimization. Referenced by ext-icons and sys-logo for SVG generation.

## Design decisions

- Central principle: SVGs are code; write them by hand, clean and minimal -- every element and attribute earns its place
- Uses topic routing to reference-specific guidance files (path-patterns.md, logo-techniques.md, icon-design.md, advanced-techniques.md, animation.md, optimization.md, accessibility-and-pitfalls.md) rather than embedding all rules inline

## Related skills

- `ext-icons`: Calls sys-svg to author the source icon SVG and logo SVG
- `sys-logo`: Uses sys-svg for detailed path work during logo design
