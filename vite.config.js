import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vitejs.dev/config/
export default defineConfig({
	base: "/sum-zero-site/",
	plugins: [
		tailwindcss(),
		react({
			include: ["**/*.res.mjs"],
		}),
	],
	server: {
		watch: {
			// We ignore ReScript build artifacts to avoid unnecessarily triggering HMR on incremental compilation
			ignored: ["**/lib/bs/**", "**/lib/ocaml/**", "**/lib/rescript.lock"],
		},
	},
});
