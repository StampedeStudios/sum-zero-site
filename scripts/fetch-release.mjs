import { writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = join(__dirname, "..", "src", "assets", "release-data.json");

const API_URL =
	"https://api.github.com/repos/StampedeStudios/sum-zero/releases/latest";

async function main() {
	console.log("Fetching latest release data...");
	const res = await fetch(API_URL, {
		headers: { Accept: "application/vnd.github.v3+json" },
	});

	if (!res.ok) {
		console.error(`GitHub API returned ${res.status}: ${res.statusText}`);
		process.exit(1);
	}

	const data = await res.json();

	const release = {
		tag_name: data.tag_name,
		published_at: data.published_at,
		assets: (data.assets || []).map((a) => ({
			name: a.name,
			browser_download_url: a.browser_download_url,
		})),
	};

	writeFileSync(OUTPUT, JSON.stringify(release, null, 2));
	console.log(`Release data written to ${OUTPUT}`);
}

main().catch((err) => {
	console.error("Failed to fetch release data:", err);
	process.exit(1);
});
