# Clipclean

A tiny macOS menu bar app that cleans messy terminal output on your clipboard. One shortcut to remove box-drawing characters, join soft-wrapped lines, and strip ANSI codes from Claude Code, Codex, and other LLM terminal output.

## Install

**Download** the latest `Clipclean.app` from [Releases](https://github.com/clem-git/clipclean/releases), move to `/Applications`, and launch. A sparkles icon appears in your menu bar.

**Or build from source:**

```bash
git clone https://github.com/clem-git/clipclean.git
cd clipclean
pnpm install && pnpm build
open packages/macos/build/Clipclean.app
```

## How it works

Copy messy terminal output, press the shortcut, paste clean text. No more box-drawing characters, no more lines broken mid-sentence, no more trailing whitespace padding every line.

### Before

What you get when you copy from Claude Code or a narrow terminal — lines broken at the terminal width, `│` characters everywhere, and invisible trailing spaces padding every line:

```
│ Here's how the authentication flow works in       ·
│ your codebase. When a user hits the /login        ·
│ endpoint, the server validates credentials        ·
│ against the database and generates a JWT          ·
│ token with a 24-hour expiry.                      ·
│                                                   ·
│ The middleware in auth.ts then:                    ·
│                                                   ·
│ 1. Extracts the Bearer token from the             ·
│    Authorization header                           ·
│ 2. Verifies the signature using the               ·
│    RS256 algorithm and your public key             ·
│ 3. Checks the token hasn't expired and            ·
│    attaches the decoded payload to                 ·
│    req.user for downstream handlers               ·
│                                                   ·
│ The refresh token flow is separate — it           ·
│ uses an HTTP-only cookie rather than the          ·
│ Authorization header, which prevents XSS          ·
│ attacks from accessing it. When the access        ·
│ token expires, the client calls /refresh          ·
│ and gets a new pair.                              ·
```

<sub>(`·` = trailing spaces that are invisible but mess up your docs when you paste)</sub>

### After

```
Here's how the authentication flow works in your codebase. When a user hits the /login endpoint, the server validates credentials against the database and generates a JWT token with a 24-hour expiry.

The middleware in auth.ts then:

1. Extracts the Bearer token from the Authorization header
2. Verifies the signature using the RS256 algorithm and your public key
3. Checks the token hasn't expired and attaches the decoded payload to req.user for downstream handlers

The refresh token flow is separate — it uses an HTTP-only cookie rather than the Authorization header, which prevents XSS attacks from accessing it. When the access token expires, the client calls /refresh and gets a new pair.
```

## Shortcuts

All shortcuts are customizable in Settings.

| Default Shortcut | Action | Description |
|------------------|--------|-------------|
| `Cmd+Shift+Alt+C` | **Copy & Clean** | Copies selection and cleans it on the clipboard |
| `Cmd+Shift+Alt+X` | **Clean Clipboard** | Cleans whatever is on the clipboard in-place |
| `Cmd+Shift+Alt+V` | **Clean & Paste** | Cleans clipboard then pastes into the active app |

## What it cleans

Clipclean auto-detects content type and applies the right cleaner:

- **Claude/terminal dump** -- Removes Unicode box-drawing characters (`│┃╏╎▌`), joins soft-wrapped lines, collapses whitespace
- **Git diff** -- Preserves diff line markers and structure while cleaning terminal artifacts
- **LLM text** -- Joins soft-wrapped lines, preserves bullets/lists/headers, collapses blank lines
- **Code** -- Left untouched (detected by `{}();=` density)
- **ANSI codes** -- Stripped automatically (configurable)

## Also available as

**CLI** (`npm install -g clipclean`):

```bash
pbpaste | clipclean | pbcopy
clipclean -c                     # clean clipboard in-place
```

**Node library** (`npm install clipclean`):

```ts
import { cleanText } from "clipclean";
const { output, detectedType } = cleanText(messy);
```

**VS Code extension** (in `packages/vscode/`):

4 commands with `Cmd+Shift+Alt` shortcuts -- Copy Clean, Paste Clean, Clean Clipboard, Clean Selection.

## Development

```bash
pnpm install
pnpm build        # builds all packages
pnpm test         # runs core library tests
```

### macOS app only

```bash
cd packages/macos
bash build.sh     # outputs build/Clipclean.app
```

Requires Xcode command-line tools (`xcode-select --install`).

## License

MIT
