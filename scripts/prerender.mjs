import { readFileSync, writeFileSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DIST = join(__dirname, "..", "dist");
const PLACEHOLDER = '<div id="root"></div>';

async function prerender() {
	const template = readFileSync(join(DIST, "index.html"), "utf-8");

	if (!template.includes(PLACEHOLDER)) {
		console.error(
			"index.html does not contain the root placeholder — already prerendered?",
		);
		process.exit(1);
	}

	const { render } = await import(join(DIST, "server", "entry-server.js"));
	const appHtml = render();

	const html = template.replace(PLACEHOLDER, `<div id="root">${appHtml}</div>`);

	writeFileSync(join(DIST, "index.html"), html);
	console.log("Pre-rendered index.html written to dist/");

	rmSync(join(DIST, "server"), { recursive: true, force: true });
	console.log("Removed dist/server/");
}

prerender().catch((err) => {
	console.error("Prerender failed:", err);
	process.exit(1);
});
