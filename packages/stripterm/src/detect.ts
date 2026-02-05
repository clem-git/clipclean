import { BOX_DRAWING_CHARS, GIT_DIFF_LINE, CODE_CHARS } from "./patterns.js";

export type ContentType = "claude-dump" | "git-diff" | "llm-text" | "code";

/**
 * Detect the type of content to determine which cleaner to use.
 *
 * Detection order:
 * 1. Lines matching `^\s*\d+\s*[+-]\s` → git-diff
 * 2. Contains Unicode box-drawing chars → claude-dump
 * 3. High ratio of code chars per line (>1.5) → code (leave untouched)
 * 4. Default → llm-text
 */
export function detectContentType(input: string): ContentType {
  const lines = input.split("\n");
  const nonEmptyLines = lines.filter((l) => l.trim().length > 0);

  if (nonEmptyLines.length === 0) return "llm-text";

  // Check for git-diff lines (strip box-drawing chars first so we detect diffs inside claude output)
  let diffLineCount = 0;
  for (const line of nonEmptyLines) {
    const stripped = line.replace(BOX_DRAWING_CHARS, "").trim();
    if (GIT_DIFF_LINE.test(stripped)) {
      diffLineCount++;
    }
  }
  if (diffLineCount >= 2 || (diffLineCount >= 1 && diffLineCount / nonEmptyLines.length > 0.1)) {
    return "git-diff";
  }

  // Check for box-drawing characters
  if (BOX_DRAWING_CHARS.test(input)) {
    return "claude-dump";
  }

  // Check for code-like content
  let totalCodeChars = 0;
  for (const line of nonEmptyLines) {
    const matches = line.match(CODE_CHARS);
    totalCodeChars += matches ? matches.length : 0;
  }
  const avgCodeCharsPerLine = totalCodeChars / nonEmptyLines.length;
  if (avgCodeCharsPerLine > 1.5) {
    return "code";
  }

  return "llm-text";
}
