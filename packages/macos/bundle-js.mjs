import * as esbuild from "esbuild";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const outdir = process.argv[2] || resolve(__dirname, "build");

await esbuild.build({
  entryPoints: [resolve(__dirname, "../stripterm/src/index.ts")],
  bundle: true,
  format: "iife",
  globalName: "clipclean",
  outfile: resolve(outdir, "clipclean.bundle.js"),
  platform: "neutral",
  target: "es2020",
});

console.log("JS bundle created.");
