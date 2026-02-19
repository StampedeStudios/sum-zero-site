# Sum Zero - Site

Site for [Sum Zero](https://github.com/StampedeStudios/sum-zero), a minimalist
math puzzle game.

## Local development

### Prerequisites

Install [Deno](https://docs.deno.com/runtime/getting_started/installation/):

```sh
curl -fsSL https://deno.land/install.sh | sh
```

Build

```sh
deno run --allow-net --allow-read --allow-write build.ts
```

This will:

1. Fetch the latest release from the GitHub API
2. Render `src/index.eta` with the release data
3. Write `dist/index.html`, `dist/style.css`, `dist/main.js`, and `dist/assets/`

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

### Manual deploy

Push any commit to `main`.

### Updating release data only

The game repo sends a `repository_dispatch` webhook with type
`release-published` after publishing a new GitHub release. This triggers a
rebuild without any manual intervention.
