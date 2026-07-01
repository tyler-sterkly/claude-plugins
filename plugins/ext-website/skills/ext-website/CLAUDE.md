# ext-website

Generates a complete hosting-ready frontend website for a Firefox extension. Outputs everything into .website/ inside the extension project directory. Calls ext-legal for privacy/terms pages and includes tracking script, FormSubmit contact form, cookie consent, and uninstall instructions.

## Design decisions

- CSS custom properties define the entire palette and typography at the top of style.css -- the whole site's look is swappable by editing one block
- Tracking script goes on the root index.html ONLY -- not on any other page
- Install button uses both classes: jle-b-inst-btn and ctabtn
- Thanks and uninstall pages have noindex meta tags
- Contact form uses FormSubmit.co, shows success popup, does not redirect
- Uninstall page has Firefox/Chrome/Edge toggle with Firefox as default and visible; Firefox shows Windows/Mac sub-toggle

## ext-legal integration

privacy/index.html and terms/index.html are handled by ext-legal -- the skill passes all gathered info automatically; no placeholder content is generated for those pages.

## Output structure

.website/ contains: index.html, css/style.css, js/main.js, assets/ (favicon + icons), thanks/, privacy/, terms/, contact/, uninstall/, and optional about/, faq/, features/ subdirectories.

## Related skills

- `ext-legal`: Called for privacy/index.html and terms/index.html
- `ext-icons`: Icon assets are read from the extension project directory, not generated here
