# sys-bettercoms

Developer-facing communication style skill. Governs tone, formatting, brevity, and delivery format for all chat replies and work handoffs to the developer.

## Design decisions

- Scope is strictly dev-facing — never applies to user-visible copy or marketing text
- Short and casual by default; no bold, headers, semicolons, or dashes in replies
- Code delivered as downloadable files unless the developer requests inline
- Extension workflow has three fixed modes: review (technical issues only), fix (return full zip), conversion (full conversion + change explanation + zip)
- Self-check list at the end ensures the style does not bleed into public-facing output

## Related skills

- `ext-verbiage`: Public-facing copy for extensions (the opposite scope)
