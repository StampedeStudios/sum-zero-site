import { Eta } from "jsr:@eta-dev/eta"
import { copy } from "jsr:@std/fs/copy"

const API_URL =
  "https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest"

const res = await fetch(API_URL, {
  headers: { Accept: "application/vnd.github.v3+json" },
})

if (!res.ok) {
  console.error(`GitHub API error: ${res.status} ${res.statusText}`)
  Deno.exit(1)
}

const data = await res.json()

const release = {
  tag_name: data.tag_name as string,
  published_at: data.published_at as string,
  assets: (data.assets as Array<{ name: string; browser_download_url: string }>).map(
    (a) => ({
      name: a.name,
      browser_download_url: a.browser_download_url,
    }),
  ),
}

const releaseDate = new Intl.DateTimeFormat("en-US", { dateStyle: "long" }).format(
  new Date(release.published_at),
)

const eta = new Eta({ views: "./src" })
const html = await eta.renderAsync("index", { release, releaseDate })

// Clean previous build
await Deno.remove("dist", { recursive: true }).catch(() => {})
await Deno.mkdir("dist/assets", { recursive: true })
await Deno.writeTextFile("dist/index.html", html)
await copy("src/assets", "dist/assets", { overwrite: true })
// favicon lives at root of dist
await Deno.copyFile("src/assets/favicon.ico", "dist/favicon.ico")
await copy("src/style.css", "dist/style.css", { overwrite: true })
await copy("src/main.js", "dist/main.js", { overwrite: true })
await copy("public/CNAME", "dist/CNAME", { overwrite: true })

console.log(`Built dist/index.html — ${release.tag_name} (${releaseDate})`)
