---
name: ext-website
description: Generate a complete frontend website for a Firefox browser extension. Use this skill whenever the user says "generate a website", "build a website", "create a landing page", "build an extension site", or any variation of generating or building a website for an extension. Always use this skill for website generation tasks even if the request seems simple.
---

# Generate Website

Generate a complete, hosting-ready frontend website for a Firefox browser extension.

## Step 1 -- Gather required info

Ask for all of the following in one message. Do not proceed until required fields are provided.

| Field | Required | Notes |
|---|---|---|
| Extension project directory | Yes | Path to the extension project. Used to read config, icons, logo, and content files |
| Extension Name | Yes | Display name used in copy and footer |
| Website domain | Yes | Ask if this is the primary Domain, LP Domain, or a custom domain |
| Use www prefix | Yes | yes or no |
| Tracking script URL | Yes | Full URL to bundle.js (e.g. https://stat.yourdomain.com/page/bundle.js) |
| AMO slug | Yes | Used in tracking script data-amo-slug attribute |
| Extension ID | Yes | Used in tracking script data-extension-id attribute |
| Nav pages to include | Yes | Ask which to include: About, FAQ, Features, Install button (can pick multiple or all) |
| Cookie consent banner | Yes | yes or no |

---

## Step 2 -- Read extension project files

Before generating anything, read the following files from the extension project directory in order of priority:

1. `.docs/LISTING.txt` -- AMO listing copy, summary, and description
2. `CLAUDE.md` -- project context and config
3. `README.md` -- project overview
4. `manifest.json` -- extension name, description, version, icons paths
5. All other files if the above do not provide enough content

Use this content to:
- Generate hero copy, tagline, and page descriptions
- Generate FAQ questions and answers relevant to the extension
- Generate Features page content based on what the extension actually does
- Generate About page as the extension's story and purpose
- Inform the color scheme and overall vibe if no strong direction exists

---

## Step 3 -- Generate color scheme and typography

Generate a full CSS custom property palette inspired by the extension name and purpose. If the name or purpose suggests a strong color direction, use it. Otherwise pick something visually interesting and cohesive.

Palette must include:
- `--color-primary` -- main brand color
- `--color-secondary` -- supporting color
- `--color-accent` -- highlight/CTA color
- `--color-bg` -- page background
- `--color-bg-alt` -- card/section background
- `--color-text` -- primary text
- `--color-text-muted` -- secondary/muted text
- `--color-border` -- border color
- `--font-heading` -- heading font (Google Font or system)
- `--font-body` -- body font (Google Font or system)
- `--radius` -- border radius base value

All colors and fonts live at the top of `css/style.css` as custom properties. Everything else references them. This makes the entire site's look swappable by editing one block.

---

## Step 4 -- Determine asset paths

Look in the extension project directory for assets in this order. Always use PNG files -- SVG source files live in non-published directories and are not used by the website.

Logo (check these locations in order, use first found):
- `icons/logo.png` -- preferred logo (written here by ext-icons)
- `logo.png` -- root fallback
- If no logo found anywhere: use the largest available icon as the logo

Icons (check `icons/` first, then root):
- `icons/icon128.png`, `icons/icon64.png`, `icons/icon48.png`, `icons/icon32.png`, `icons/icon16.png`
- Fall back to root-level equivalents if not found in `icons/`

Favicon:
- `favicon.ico` in the project ROOT (never inside `icons/`)

Copy all found assets into `.website/assets/`.

---

## Step 5 -- Generate file structure

Output everything into `.website/` inside the extension project directory.

```
.website/
  index.html
  css/
    style.css
  js/
    main.js
  assets/
    (favicon, icons, logo copied from extension dir)
  thanks/
    index.html
  privacy/
    index.html
  terms/
    index.html
  contact/
    index.html
  uninstall/
    index.html
  about/          (if selected)
    index.html
  faq/            (if selected)
    index.html
  features/       (if selected)
    index.html
```

---

## Step 6 -- Shared rules for all pages

Apply to every page:

### Head
- `<meta charset="UTF-8">`
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- `<link rel="icon" href="/assets/favicon.ico">`
- `<link rel="stylesheet" href="/css/style.css">` (adjust path depth for subpages: `../../css/style.css`)
- Google Fonts import if using non-system fonts
- noindex meta tag on thanks and uninstall pages only:
  `<meta name="robots" content="noindex, nofollow">`

### Tracking script
Include the tracking script on the root `index.html` ONLY -- not on any other page.
Place it near the bottom of `<body>`, before `</body>`:
```html
<script src="{tracking-script-url}"
  data-amo-slug="{amo-slug}"
  data-extension-id="{extension-id}"
  data-name="{extension-name}"></script>
```

### Nav
Always include a nav with:
- Logo (logo file or icon fallback) + Extension Name linking to home
- Links: Home, Contact, Privacy, Terms
- Optional links based on what was selected: About, FAQ, Features
- Do NOT include Thanks in the nav
- Mobile: hamburger menu that toggles open/closed via JS

### Footer
Always include a footer with:
- Links to every page except Thanks
- Copyright line: `&copy; {year} {Extension Name}`

### CSS custom properties
All pages share `/css/style.css`. Subpages reference it with `../../css/style.css`.

---

## Step 7 -- Page-specific rules

### index.html (root)
- Hero section with extension name, tagline, and description pulled from listing/manifest
- Extension icon or logo displayed prominently
- Install/CTA button with classes `jle-b-inst-btn ctabtn` linking to:
  `https://addons.mozilla.org/en-US/firefox/addon/{amo-slug}/`
- Feature highlights (3-4 bullet points or cards)
- Optionally include a secondary section showcasing the icon if it fits the layout
- The tracking script goes here on this page ONLY (see Step 6); do not place it on any other page

### thanks/index.html
- `<meta name="robots" content="noindex, nofollow">`
- Confirmation message that the extension was installed successfully
- Handle postMessage events from the extension via JS in main.js or inline:
  - `extInstalled`: log a vague message like `console.log("Page successfully established contact.")`
  - `searchEngineAccepted`: log a vague message like `console.log("Extension state confirmed.")`
  - `searchEngineNotAccepted`: log a vague message like `console.log("Extension state acknowledged.")`
- No install button on this page

### privacy/index.html
- Call the `ext-legal` skill, passing all gathered info automatically
- `ext-legal` will write the full privacy policy to this path and handle the review pause
- Do not generate placeholder content -- the skill handles everything

### terms/index.html
- Call the `ext-legal` skill, passing all gathered info automatically
- `ext-legal` will write the full terms to this path and handle the review pause
- Do not generate placeholder content -- the skill handles everything

### contact/index.html
- Contact form with: Name, Email (required, from-address), Message fields
- Form submits via FormSubmit.co:
  `<form action="https://formsubmit.co/support@{domain}" method="POST">`
- Add hidden fields:
  - `<input type="hidden" name="_captcha" value="false">`
  - `<input type="hidden" name="_next" value="">` (leave empty, handled by JS)
- On submit: show a success popup/overlay via JS, do not redirect to another page
- No install button

### uninstall/index.html
- `<meta name="robots" content="noindex, nofollow">`
- Manual browser toggle: Firefox (default, shown), Chrome (hidden), Edge (hidden)
- Firefox instructions are for both Windows and Mac -- show a sub-toggle for OS
- Firefox Windows and Firefox Mac are both written out
- Chrome and Edge instructions always generated but hidden by default
- Toggle buttons show/hide the relevant section via JS
- No install button

### about/index.html (if selected)
- Extension story: what it does, why it was built, who it's for
- Generated from .docs/LISTING.txt, README.md, and manifest description
- Use extension icon/logo in layout if it fits
- No install button

### faq/index.html (if selected)
- Accordion-style FAQ (click question to expand answer)
- Questions and answers generated from reading extension project files
- Aim for 6-10 relevant questions
- No install button

### features/index.html (if selected)
- Feature list with icons or visual treatment
- Content generated from extension project files
- No install button

---

## Step 8 -- Cookie consent banner (if selected)

If the user chose to include a cookie consent banner:
- Fixed banner at bottom of every page
- Two buttons: Accept, Decline
- On Accept: set a cookie `consent=accepted` and hide the banner
- On Decline: set a cookie `consent=declined` and hide the banner
- On page load: check for cookie, hide banner if already set
- Implement in `js/main.js`

---

## Step 9 -- js/main.js

Shared JS file for all pages. Include:
- Nav hamburger toggle
- Cookie consent logic (if selected)
- Contact form success popup handler
- postMessage listener for thanks page (scoped to only run on thanks page by checking `window.location.pathname`)
- Any other shared interactive behavior

---

## Step 10 -- Report

After all files are written, report back:
- Pages generated
- Optional pages included
- Asset files found and copied
- Color scheme summary (primary, accent, bg)
- Font choices
- Tracking script placement confirmed
- FormSubmit target email
- Any files not found (logo, icons) and what fallback was used

---

## Self-check

- [ ] All required inputs collected before starting
- [ ] Extension project files read before generating content
- [ ] CSS custom properties defined at top of style.css
- [ ] Tracking script near bottom of body on the root index.html ONLY (not on any other page)
- [ ] Install button only on index.html, with both jle-b-inst-btn and ctabtn classes
- [ ] Thanks and uninstall have noindex meta tags
- [ ] Nav does not include Thanks page
- [ ] Footer includes all pages except Thanks
- [ ] postMessage events handled on thanks page with vague console logs
- [ ] Uninstall page has Firefox/Chrome/Edge toggle, Firefox default and visible
- [ ] Uninstall Firefox has Windows/Mac sub-toggle
- [ ] Contact form uses FormSubmit, shows success popup, does not redirect
- [ ] Cookie consent implemented if selected
- [ ] All assets copied to .website/assets/
