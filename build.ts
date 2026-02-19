import { Eta } from "@eta-dev/eta";
import { copy } from "@std/fs/copy";
import { Err, Ok, type Result, unwrapOrElse } from "./result.ts";

const API_URL =
  "https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest";

type Asset = { name: string; browser_download_url: string };
type Release = { tag_name: string; published_at: string; assets: Asset[] };
type TemplateData = { release: Release; releaseDate: string };

async function fetchRelease(): Promise<Result<Release>> {
  let res: Response;
  try {
    res = await fetch(API_URL, {
      headers: { Accept: "application/vnd.github.v3+json" },
    });
  } catch (e) {
    return Err(`Network error: ${e}`);
  }

  if (!res.ok) {
    return Err(`GitHub API error: ${res.status} ${res.statusText}`);
  }

  let data: unknown;
  try {
    data = await res.json();
  } catch {
    return Err("Failed to parse GitHub API response as JSON");
  }

  return validateRelease(data);
}

function validateRelease(data: unknown): Result<Release> {
  if (typeof data !== "object" || data === null) {
    return Err("Expected an object from GitHub API");
  }

  const d = data as Record<string, unknown>;

  if (typeof d.tag_name !== "string") {
    return Err("Missing or invalid field: tag_name");
  }
  if (typeof d.published_at !== "string") {
    return Err("Missing or invalid field: published_at");
  }
  if (!Array.isArray(d.assets)) {
    return Err("Missing or invalid field: assets");
  }

  const assets: Asset[] = [];
  for (const [i, asset] of d.assets.entries()) {
    if (typeof asset !== "object" || asset === null) {
      return Err(`Asset at index ${i} is not an object`);
    }
    const a = asset as Record<string, unknown>;
    if (typeof a.name !== "string") {
      return Err(`Asset at index ${i} is missing field: name`);
    }
    if (typeof a.browser_download_url !== "string") {
      return Err(`Asset at index ${i} is missing field: browser_download_url`);
    }
    assets.push({ name: a.name, browser_download_url: a.browser_download_url });
  }

  return Ok({ tag_name: d.tag_name, published_at: d.published_at, assets });
}

async function renderTemplate(data: TemplateData): Promise<Result<string>> {
  const eta = new Eta({ views: "./src" });
  try {
    const html = await eta.renderAsync("index", data);
    return Ok(html);
  } catch (e) {
    return Err(`Template render error: ${e}`);
  }
}

// Fetch release
const release = unwrapOrElse(await fetchRelease(), (err) => {
  console.error(err);
  Deno.exit(1);
});

const releaseDate = new Intl.DateTimeFormat("en-US", { dateStyle: "long" })
  .format(new Date(release.published_at));

// Render template
const html = unwrapOrElse(
  await renderTemplate({ release, releaseDate }),
  (err) => {
    console.error(err);
    Deno.exit(1);
  },
);

// Write output
await Deno.remove("dist", { recursive: true }).catch(() => {});
await Deno.mkdir("dist/assets", { recursive: true });
await Deno.writeTextFile("dist/index.html", html);
await copy("src/assets", "dist/assets", { overwrite: true });
await Deno.copyFile("src/assets/favicon.ico", "dist/favicon.ico");
await copy("src/style.css", "dist/style.css", { overwrite: true });
await copy("src/main.js", "dist/main.js", { overwrite: true });

console.log(`Built dist/index.html — ${release.tag_name} (${releaseDate})`);
