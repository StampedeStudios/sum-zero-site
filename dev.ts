import { serveDir } from "@std/http/file-server";

async function build() {
  const cmd = new Deno.Command(Deno.execPath(), {
    args: [
      "run",
      "--allow-net",
      "--allow-read",
      "--allow-write",
      "--allow-env",
      "build.ts",
    ],
    stdout: "inherit",
    stderr: "inherit",
  });
  await cmd.output();
}

// Initial build
await build();

// File server
Deno.serve(
  { port: 8000 },
  (req) => serveDir(req, { fsRoot: "dist", quiet: true }),
);
console.log("Dev server running at http://localhost:8000");

// Watch src/ and rebuild on changes
const watcher = Deno.watchFs("src");
for await (const event of watcher) {
  if (event.kind === "modify" || event.kind === "create") {
    console.log(`Changed: ${event.paths[0]} — rebuilding…`);
    await build();
  }
}
