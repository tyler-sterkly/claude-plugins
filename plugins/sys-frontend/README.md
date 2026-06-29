# design-frontend-ui

Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults.

## When to trigger

Use this skill when:
- Building a new UI, page, or component from scratch
- Reshaping or redesigning an existing UI
- The user asks for help with visual design direction
- The user wants the UI to feel distinctive and not generic
- "Design a landing page for X"
- "Make this look less templated"
- "Help me with the aesthetic direction for this"
- "What should the design feel like?"

## How it works

The skill runs in two passes: plan first, then build.

### Pass 1: Design plan

Before writing any code:
1. Pin down the subject if the brief doesn't specify it: name the product, audience, and the page's single job
2. Build a compact token system covering:
   - **Color**: 4-6 named hex values
   - **Type**: display face, body face, and utility face (if needed), with scale, weights, and spacing
   - **Layout**: concept in one-sentence prose + ASCII wireframes
   - **Signature**: the single element the page will be remembered by
3. Review the plan against the brief: if any part reads like a default you'd produce for any similar page, revise it and explain what changed and why
4. Only start writing code after the plan is confirmed as distinctive to this specific brief

### Pass 2: Build

- Derive every color and type decision from the plan
- Watch CSS selector specificities carefully (type-based and element-based selectors can cancel each other out, especially on paddings/margins)
- Take screenshots if the environment supports them to critique visually
- Apply Chanel's rule before finishing: look at the result and remove one accessory

## Design principles applied

**Hero as thesis.** Open with the most characteristic thing about the subject. Avoid the default (big number + small label + gradient accent) unless it's genuinely the best choice.

**Typography carries personality.** Pair display and body faces deliberately, not the same families you'd reach for on any project. Make the type treatment memorable.

**Structure encodes meaning.** Numbered markers (01/02/03) only make sense when the content is actually a sequence. Structural devices should be true to the content.

**Motion serves the subject.** Animation is deliberate. An orchestrated moment lands harder than scattered effects. Less is often more.

**Spend boldness in one place.** The signature element is the one memorable thing. Everything around it stays quiet and disciplined.

## Writing in UI

- Write from the end user's side of the screen, never from the system's internals
- Use active voice: "Save changes" not "Submit"
- Keep vocabulary consistent across a whole flow (the button that says "Publish" produces a toast that says "Published")
- Errors explain what went wrong and how to fix it, never apologize, never stay vague
- Empty states are invitations to act, not mood pieces
- Sentence case, plain verbs, no filler

## What to avoid

Three looks that AI-generated design clusters into (legitimate for some briefs, but only if chosen deliberately for the specific brief):
1. Warm cream background with high-contrast serif and terracotta accent
2. Near-black background with a single bright acid-green or vermilion accent
3. Broadsheet-style with hairline rules, zero border-radius, dense columns

Where the brief leaves an axis free, don't default to one of these.

## Inputs

- A design brief (product, audience, page job, any existing brand constraints)
- Any memory or prior context about the user's preferences or previous designs
- Real content if available (copy, images, data)

## Outputs

- A design plan (token system, layout concept, signature element)
- Working HTML/CSS/JS code
- A summary of design decisions and what was changed from any generic defaults

## Edge cases and limitations

- If the brief gives no content, the skill generates representative copy. Be as specific to the subject as possible.
- The skill does not handle accessibility audits beyond keyboard focus and reduced motion
- CSS specificity conflicts are a known risk and are explicitly guarded against, but complex layouts may still require manual review

## Related skills

- `sys-logo`: Logo design and SVG export
- `sys-svg`: SVG authoring and path work
- `ext-icons`: Icon set generation for extensions
