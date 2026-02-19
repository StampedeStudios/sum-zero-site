# Sum Zero Site Rewrite Plan

This is the ouput of a Rescript + React app for a videogame called Sum Zero. What I want you to do is to create a new project that stripts out the unnecessary dependencies and use html js and css, with the help of eta and deno. This is the plan

## Goal

Replace the ReScript + React + Vite stack with a plain HTML/CSS/JS site built by a Deno script using the Eta template engine. GitHub data is fetched at build time and baked into a static `index.html`.

---

## Project Structure

```
sum-zero-site/
├── src/
│   ├── index.eta          # HTML template
│   ├── style.css          # All styles (ported from current CSS)
│   ├── main.js            # Minimal JS (back-to-top scroll only)
│   └── assets/            # Images, SVGs, favicon (copied from current dist/)
├── build.ts               # Deno build script
├── dist/                  # Build output (gitignored)
│   └── index.html
├── public/
│   └── CNAME
└── .github/
    └── workflows/
        └── deploy.yml
```

---

## Build Flow

```
src/index.eta  →  build.ts (fetches GitHub API + renders template)  →  dist/index.html
```

At build time Deno:
1. Fetches latest release data from GitHub API
2. Passes it as variables to Eta
3. Eta renders `index.eta` into a complete `index.html` with data already baked in
4. Copies static assets to `dist/`

---

## Step 1 — Port HTML into `src/index.eta`

Use current `dist/index.html` as the source of truth for structure and content. Clean up inlined Tailwind utilities into semantic class names in `style.css`. Eta syntax is used only where release data appears:

```html
<h1 class="release-version"><%= it.release.tag_name %></h1>
<p class="release-date"><%= it.releaseDate %></p>

<% for (const asset of it.release.assets) { %>
  <% if (asset.name.includes("Linux")) { %>
    <a href="<%= asset.browser_download_url %>">Download for Linux</a>
  <% } %>
<% } %>
```

---

## Step 2 — Write `build.ts` (Deno)

```ts
import { Eta } from "jsr:@eta-dev/eta"
import { copy } from "jsr:@std/fs/copy"

const API_URL = "https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest"

const res = await fetch(API_URL, { headers: { Accept: "application/vnd.github.v3+json" } })
const data = await res.json()

const release = {
  tag_name: data.tag_name,
  published_at: data.published_at,
  assets: data.assets.map((a: any) => ({
    name: a.name,
    browser_download_url: a.browser_download_url,
  })),
}

const releaseDate = new Intl.DateTimeFormat("en-US", { dateStyle: "long" })
  .format(new Date(release.published_at))

const eta = new Eta({ views: "./src" })
const html = await eta.renderAsync("index", { release, releaseDate })

await Deno.mkdir("dist/assets", { recursive: true })
await Deno.writeTextFile("dist/index.html", html)
await copy("src/assets", "dist/assets", { overwrite: true })
await copy("src/style.css", "dist/style.css", { overwrite: true })
await copy("src/main.js", "dist/main.js", { overwrite: true })
await copy("public/CNAME", "dist/CNAME", { overwrite: true })
```

---

## Step 3 — Port `style.css`

The current CSS is mostly Tailwind utilities inlined in HTML. Move them into proper classes in `style.css`.

The following carry over verbatim from `src/style/index.css`:
- Color palette (lime/gray CSS custom properties)
- `.shadow-image`, `.shadow-image-sm`
- `.hero-bg` with background pattern
- `.color-accent`, `.color-danger` button theming
- `.qr-chevron` transition

The JetBrains Mono font can either stay as a local file in assets or switch to a CDN `@import` — see open questions below.

---

## Step 4 — `main.js` (minimal)

The only JS on the page is the back-to-top button scroll listener (~10 lines):

```js
const btn = document.querySelector('[data-back-to-top]')
window.addEventListener('scroll', () => {
  btn.style.opacity = window.scrollY > 300 ? '1' : '0'
})
```

No framework, no hydration, no bundle step.

---

## Step 5 — Update GitHub Actions workflow

The existing `static.yml` already has `repository_dispatch: [release-published]` configured (triggered by the game repo on new release). Replace the pnpm/Node build steps with Deno:

```yaml
- name: Setup Deno
  uses: denoland/setup-deno@v2
  with:
    deno-version: v2.x

- name: Build
  run: deno run --allow-net --allow-read --allow-write build.ts
```

The action goes from ~6 steps to ~4. No `npm install`, no `pnpm`, no ReScript compiler.

---

## What Gets Deleted

Everything except:
- `src/assets/` (images, SVGs)
- `public/CNAME`
- `.github/workflows/static.yml` (updated in place)

The following are removed entirely:
- `src/*.res` — all ReScript source files
- `scripts/` — fetch-release.mjs, prerender.mjs, entry-server.mjs
- `lib/` — ReScript compiler output
- `node_modules/`
- `package.json`, `pnpm-lock.yaml`
- `rescript.json`
- `vite.config.js`

---

## Open Questions

1. **Font loading** — keep `@fontsource/jetbrains-mono` as a local file in assets, or switch to a CDN `@import`?
   - Local: no external dependency at runtime
   - CDN: one less file to copy, but adds external request

2. **CSS approach** — port Tailwind utilities to hand-written CSS classes, or use Tailwind CDN play build?
   - Hand-written: no build dependency, full control, cleaner output
   - Tailwind CDN: faster to port but adds a runtime script

3. **Fallback for failed GitHub fetch** — if the API call fails during build, should `build.ts`:
   - Fail loudly and abort the deploy?
   - Fall back to a committed `release-data.json` snapshot?
