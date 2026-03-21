# Common Patterns & Conventions

> This file is loaded on-demand. Referenced from CLAUDE.md.

## Tech Stack

- **Framework:** Next.js 16, React 19, TypeScript
- **Styling:** Tailwind CSS v4
- **Backend:** Supabase (PostgreSQL, Auth, Edge Functions, Storage)
- **Hosting:** GitHub Pages (static export)

## Tailwind CSS Design Tokens

Use design tokens defined in `@theme` block. Run `npm run css:build` after adding new classes.

Tailwind v4 uses CSS-first config — no `tailwind.config.js`. Tokens are defined in `@theme`:

```css
@theme {
  --color-brand-primary: #your-color;
  --color-brand-secondary: #your-color;
  /* add project-specific tokens here */
}
```

## Auth System

- Supabase Auth with email/password + OAuth
- Roles: oracle (4), admin (3), staff (2), resident (1), associate (1), demo (read-only)

## Supabase Client

```typescript
import { supabase } from "@/lib/supabase";
```

## Conventions

1. Use toast notifications, not `alert()`
2. Tailwind: use design tokens from `@theme` block
3. Run `npm run css:build` after new Tailwind classes
