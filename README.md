# clipclean

Clean Claude Code / Codex terminal output. npm CLI + VS Code extension.

## Install

```bash
npm install -g clipclean    # CLI
npm install clipclean       # library
```

## CLI Usage

```bash
pbpaste | clipclean | pbcopy          # pipe mode
pbpaste | clipclean --type claude     # force content type
clipclean -c                          # clean clipboard in-place
```

## Library API

```ts
import { cleanText } from "clipclean";

const { output, detectedType } = cleanText(messy);
// detectedType: "claude-dump" | "git-diff" | "llm-text" | "code"
```

## VS Code Extension

Install from the VS Code marketplace or build locally.

| Command | Shortcut (Mac) | Description |
|---------|----------------|-------------|
| Copy Clean | `Cmd+Shift+Alt+C` | Copy selection, clean, to clipboard |
| Paste Clean | `Cmd+Shift+Alt+V` | Read clipboard, clean, paste |
| Clean Clipboard | `Cmd+Shift+Alt+X` | Clean clipboard in-place |
| Clean Selection | `Cmd+Shift+Alt+S` | Clean selected text in-place |

## Content Detection

Clipclean auto-detects content type:

1. **git-diff** - Lines matching `^\s*\d+\s*[+-]\s`
2. **claude-dump** - Contains Unicode box-drawing chars (`│┃╏╎▌`)
3. **code** - High ratio of `{}();=` per line (left untouched)
4. **llm-text** - Default fallback

## Development

```bash
pnpm install
pnpm build
pnpm test
```

## License

MIT
