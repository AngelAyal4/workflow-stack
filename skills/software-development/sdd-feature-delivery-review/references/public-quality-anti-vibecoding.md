# Public-quality / anti-vibecoding review

Use this reference when reviewing a Next.js app for release quality beyond the core security checklist. These controls cover SEO, accessibility, HTML delivery, runtime hygiene, and client performance; they are not all vulnerabilities, so classify each as resolved, N/A with reason, or follow-up.

## 20-point gate

1. `*.vercel.app` is acceptable for staging/testing; require a domain before final public launch.
2. View Source contains meaningful initial HTML, not an empty JS shell.
3. A deliberate branded 404 exists; Next's generated `/_not-found` proves only that a status exists, not that the UX is complete.
4. The chosen framework/build matches the architecture; detect accidental Vite/React scaffolds or duplicate apps.
5. Important routes have descriptive, unique titles; a single inherited generic title is incomplete.
6. Indexable routes have useful, route-specific descriptions.
7. Shareable public routes have valid Open Graph metadata including `og:image`.
8. Add valid JSON-LD only where the page type justifies it; never invent structured data for private dashboards.
9. No document has more than one H1.
10. Every content/error/empty page has a meaningful H1.
11. Indexable routes define absolute canonicals; private routes have an explicit no-index policy or are excluded.
12. Public projects expose a controlled `/llms.txt` when appropriate; never include private data.
13. `/robots.txt` expresses an intentional policy and does not accidentally block search/AI crawlers; exclude private/API paths as needed.
14. Favicon and PWA icons are valid and reachable.
15. `/sitemap.xml` contains only public indexable URLs.
16. `<html lang>` matches the primary content language.
17. Images have appropriate alt text; decorative images use empty alt; interactive SVGs have accessible names.
18. Production requests for public `*.js.map` return 404/blocked; private observability uploads are fine.
19. Main navigation and flows have no unexpected browser-console errors or warnings.
20. Define a bundle budget and report both raw and gzip sizes; lazy-load heavy libraries and avoid route-inappropriate imports.

## Evidence workflow

1. Inspect `src/app` for `layout.tsx`, `not-found.tsx`, `robots.ts`, `sitemap.ts`, `manifest.ts`, `favicon.ico`, and per-route metadata.
2. Run the production build and record its route table. A generated `/_not-found` route is not a substitute for a custom 404 review.
3. Request `/login`, a representative public route, and an unknown route with `curl`; record status, content type, byte count, title, HTML language, H1 count, description, canonical, and OG tags.
4. Request `/robots.txt`, `/sitemap.xml`, `/llms.txt`, `/favicon.ico`, and representative `*.js.map` URLs; distinguish absent policy (404) from an explicit safe policy.
5. Search source for `<img>`, `next/image`, inline SVG accessibility attributes, `dangerouslySetInnerHTML`, and source-map references.
6. Measure `.next/static/chunks/*.js` raw and gzip sizes. Do not label a bundle "giant" without a project budget; report the largest chunk and total.
7. Use a real browser for console verification. Static `console.*` searches find logging statements but cannot prove a clean browser console; if browser access is blocked, mark this check unverified instead of claiming success.

## Review pitfalls

- A globally defined Next metadata description is not the same as unique descriptions per route.
- A favicon or PWA manifest icon does not imply that Open Graph image metadata exists.
- No `robots.txt` means no explicit AI block, but it also means no documented crawl policy.
- No image elements means alt-text review is currently N/A, not evidence that future images will be accessible.
- Source maps present under local `.next/server` artifacts are not automatically exposed; verify HTTP reachability separately.
- Default Next 404 status and a branded, useful 404 page are different acceptance criteria.
- Keep the 20 public-quality controls separate from the ten core security controls, but run both before release.
- Metadata tests must be environment-agnostic: never import root metadata once at module load and assert the localhost fallback unconditionally. Load the module after setting/deleting `NEXT_PUBLIC_APP_URL`, and test both fallback and production URL cases. Re-run the full suite with `NEXT_PUBLIC_APP_URL` defined; the local-default suite alone misses CI failures.
- Treat generated public assets as UI artifacts, not only file-format checks. For OG images, verify dimensions, format, and composition geometry (text bounds against the safe frame) after regeneration; a valid 1200×630 PNG can still visibly clip or cross its border.
- Baseline evidence must be captured before implementation from a clean tree. If a log's `git status` already contains the implementation, label it invalid/post-implementation instead of calling it a baseline; preserve a separate post-fix evidence log.
- When `output: standalone` is active, use the actual standalone runtime (`node .next/standalone/server.js`) for local production smoke tests, or build with `VERCEL=1` before using `next start`; `next start` may warn even when requests still succeed.
