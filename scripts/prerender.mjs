import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DIST = join(__dirname, "..", "dist");

async function prerender() {
	const template = readFileSync(join(DIST, "index.html"), "utf-8");

	const { render } = await import(join(DIST, "server", "entry-server.js"));
	const appHtml = render();

	const html = template.replace(
		'<div id="root"></div>',
		`<div id="root">${appHtml}</div>`,
	);

	writeFileSync(join(DIST, "index.html"), html);
	console.log("Pre-rendered index.html written to dist/");
}

prerender().catch((err) => {
	console.error("Prerender failed:", err);
	process.exit(1);
});
