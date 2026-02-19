# Sum Zero - Site

Static site for [Sum Zero](https://github.com/StampedeStudios/sum-zero), a minimalist math puzzle game.

## Build

The site is statically generated: a Deno script fetches data from the GitHub API and renders pages with Eta.

```sh
deno run --allow-net --allow-read --allow-write build.ts
```
---

### Pipeline

The pipeline will run when a commit hits main or when there is a release from the Sum Zero repository.
