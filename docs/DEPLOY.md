# Deployment Workflow

## GitHub Pages (Static Site)

- **Repo:** https://github.com/grotkoaleksandra/syrena-studio
- **Live URL:** https://grotkoaleksandra.github.io/syrena-studio/
- **Build type:** Workflow (GitHub Actions builds Next.js static export)
- **Branch:** main

### Push Workflow
```bash
git add -A && git commit -m "message" && git push
```

### Post-Push Verification
1. Wait ~60s for CI to run
2. `git pull --rebase origin main`
3. Read `version.json` — report version

### Version Format
`vYYMMDD.NN H:MMa` — date + daily counter + local time.
CI bumps automatically via GitHub Action on every push. **Never bump locally.**

## Edge Functions

Deploy with Supabase CLI:
```bash
supabase functions deploy <function-name>
```

For webhook functions (no JWT verification):
```bash
supabase functions deploy <function-name> --no-verify-jwt
```

## Tailwind CSS

After adding new Tailwind classes, run: `npm run css:build`
