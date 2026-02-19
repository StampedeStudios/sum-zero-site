# Sum Zero — Site

Marketing site for [Sum Zero](https://github.com/StampedeStudios/sum-zero), a minimalist math puzzle game by Stampede Studios.

Live at **[sum-zero.com](https://sum-zero.com)** via GitHub Pages.

---

## Stack

| Layer | Tool |
|---|---|
| Runtime | [Deno](https://deno.com) v2 |
| Templating | [Eta](https://eta.js.org) (`jsr:@eta-dev/eta`) |
| Styles | Hand-written CSS (no build step) |
| JavaScript | Vanilla (~4 lines, back-to-top only) |
| Hosting | GitHub Pages |

No Node.js, no npm, no bundler.

---

## Project structure

```
sum-zero-site/
├── src/
│   ├── index.eta        # HTML template (Eta syntax for release data)
│   ├── style.css        # All styles
│   ├── main.js          # Back-to-top scroll listener
│   └── assets/          # Images, SVGs, fonts (stable names, no hashes)
├── public/
│   └── CNAME            # Custom domain: sum-zero.com
├── build.ts             # Deno build script
├── dist/                # Build output — gitignored
└── .github/
    └── workflows/
        └── static.yml   # GitHub Actions: build + deploy
```

---

## Local development

### Prerequisites

Install [Deno](https://docs.deno.com/runtime/getting_started/installation/):

```sh
curl -fsSL https://deno.land/install.sh | sh
```

### Run a build

```sh
deno run --allow-net --allow-read --allow-write build.ts
```

This will:
1. Fetch the latest release from the GitHub API
2. Render `src/index.eta` with the release data
3. Write `dist/index.html`, `dist/style.css`, `dist/main.js`, and `dist/assets/`

### Preview locally

Any static file server works. With Deno:

```sh
deno run --allow-net --allow-read jsr:@std/http/file-server dist/
```

Then open [http://localhost:8000](http://localhost:8000).

---

## How the build works

`build.ts` runs entirely at build time — there is no client-side data fetching.

1. Calls `GET https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest`
2. Extracts `tag_name`, `published_at`, and `assets[]` (name + download URL)
3. Passes the data to Eta, which renders `src/index.eta` into a complete HTML file
4. Copies static files to `dist/`

If the GitHub API call fails, the build exits with a non-zero code and the deploy is aborted.

---

## Deploying to production

Deployments are handled automatically by GitHub Actions (`.github/workflows/static.yml`).

### Triggers

| Event | Description |
|---|---|
| Push to `main` | Rebuilds and deploys the site |
| `workflow_dispatch` | Manual trigger from the Actions tab |
| `repository_dispatch: release-published` | Triggered by the game repo when a new release is published |

### Manual deploy

Push any commit to `main`:

```sh
git add .
git commit -m "your message"
git push origin main
```

GitHub Actions will run `deno run --allow-net --allow-read --allow-write build.ts`, upload `dist/` as a Pages artifact, and deploy it.

### Updating release data only

The game repo sends a `repository_dispatch` webhook with type `release-published` after publishing a new GitHub release. This triggers a rebuild without any manual intervention — the new version, date, and download URLs are fetched and baked into the HTML automatically.

---

## Editing content

| What | Where |
|---|---|
| Page structure and copy | `src/index.eta` |
| Styles | `src/style.css` |
| Images / fonts | `src/assets/` |
| Build logic | `build.ts` |
| CI/CD | `.github/workflows/static.yml` |

The only Eta template syntax in `src/index.eta` is in the download section, where release data is interpolated:

```html
<h1 class="release-version"><%= it.release.tag_name %></h1>
<h2 class="release-date"><%= it.releaseDate %></h2>

<% for (const asset of it.release.assets) { %>
  <% if (asset.name.includes("Linux")) { %>
    <a href="<%= asset.browser_download_url %>">Download for Linux</a>
  <% } %>
<% } %>
```

Everything else is plain HTML.
