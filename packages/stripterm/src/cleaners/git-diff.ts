import {
  BOX_DRAWING_CHARS,
  MULTI_SPACES,
  FOUR_PLUS_NEWLINES,
  GIT_DIFF_LINE,
  DIFF_NUMBERED_LINE,
  isBreakLine,
} from "../patterns.js";

/**
 * Clean git-diff output from terminal.
 *
 * - Remove box-drawing chars
 * - Join soft-wrapped lines (preserving diff lines `\d+ [+-]`, bullets, etc.)
 * - Collapse whitespace
 * - Collapse 4+ newlines → 3
 */
export function cleanGitDiff(input: string): string {
  // Remove box-drawing characters
  let text = input.replace(BOX_DRAWING_CHARS, "");

  // Collapse multiple spaces
  text = text.replace(MULTI_SPACES, " ");

  // Process lines
  const lines = text.split("\n");
  const result: string[] = [];

  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();

    if (result.length === 0) {
      result.push(trimmed);
      continue;
    }

    if (trimmed === "") {
      result.push("");
      continue;
    }

    // Don't join if this is a diff line (with +/- or context line with line number)
    if (GIT_DIFF_LINE.test(trimmed) || DIFF_NUMBERED_LINE.test(trimmed)) {
      result.push(trimmed);
      continue;
    }

    // Don't join if this is a break line
    if (isBreakLine(trimmed)) {
      result.push(trimmed);
      continue;
    }

    const prevLine = result[result.length - 1];

    // Don't join if previous line was empty
    if (prevLine.trim() === "") {
      result.push(trimmed);
      continue;
    }

    // Join continuation
    result[result.length - 1] = prevLine + " " + trimmed;
  }

  let output = result.join("\n");

  // Collapse 4+ newlines → 3
  output = output.replace(FOUR_PLUS_NEWLINES, "\n\n\n");

  return output.trim();
}
