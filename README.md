# Sum Zero

Website for Sum Zero, a game by Stampede Studios.

## Tech Stack

- [ReScript](https://rescript-lang.org) with React
- [Vite](https://vitejs.dev)
- [Tailwind CSS](https://tailwindcss.com) v4

## Development

Run ReScript in dev mode:

```sh
pnpm res:dev
```

In another tab, run the Vite dev server:

```sh
pnpm dev
```

## Build

```sh
pnpm res:build
pnpm build
```

Output is in the `dist` folder.

## Deployment

Deployed to GitHub Pages via GitHub Actions. Push to `main` triggers a build and deploy.

Custom domain: [sum-zero.com](https://sum-zero.com)
