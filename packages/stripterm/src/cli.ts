import { cleanText, type ContentType } from "./clean.js";

const HELP = `clipclean - Clean Claude Code / Codex terminal output

Usage:
  pbpaste | clipclean | pbcopy     Pipe mode (stdin → stdout)
  pbpaste | clipclean --type claude Force content type
  clipclean -c                     Read/write clipboard in-place

Options:
  --type <type>   Force content type: claude, diff, llm, code
  -c, --clipboard Read from clipboard, clean, write back to clipboard
  -h, --help      Show this help
  -v, --version   Show version
`;

function parseArgs(args: string[]): {
  type?: ContentType;
  clipboard: boolean;
  help: boolean;
  version: boolean;
} {
  let type: ContentType | undefined;
  let clipboard = false;
  let help = false;
  let version = false;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--type" || arg === "-t") {
      const val = args[++i];
      const typeMap: Record<string, ContentType> = {
        claude: "claude-dump",
        "claude-dump": "claude-dump",
        diff: "git-diff",
        "git-diff": "git-diff",
        llm: "llm-text",
        "llm-text": "llm-text",
        code: "code",
      };
      type = typeMap[val];
      if (!type) {
        process.stderr.write(`Unknown type: ${val}\n`);
        process.exit(1);
      }
    } else if (arg === "-c" || arg === "--clipboard") {
      clipboard = true;
    } else if (arg === "-h" || arg === "--help") {
      help = true;
    } else if (arg === "-v" || arg === "--version") {
      version = true;
    }
  }

  return { type, clipboard, help, version };
}

function readStdin(): Promise<string> {
  return new Promise((resolve, reject) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => (data += chunk));
    process.stdin.on("end", () => resolve(data));
    process.stdin.on("error", reject);
  });
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));

  if (opts.help) {
    process.stdout.write(HELP);
    return;
  }

  if (opts.version) {
    process.stdout.write("clipclean 1.0.0\n");
    return;
  }

  let input: string;

  if (opts.clipboard) {
    const { default: clipboardy } = await import("clipboardy");
    input = await clipboardy.read();
    const { output } = cleanText(input, { type: opts.type, stripAnsi: true });
    await clipboardy.write(output);
    process.stderr.write("Clipboard cleaned.\n");
  } else {
    input = await readStdin();
    const { output } = cleanText(input, { type: opts.type, stripAnsi: true });
    process.stdout.write(output + "\n");
  }
}

main().catch((err) => {
  process.stderr.write(`Error: ${err.message}\n`);
  process.exit(1);
});
