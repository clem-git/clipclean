import {
  BOX_DRAWING_CHARS,
  MULTI_SPACES,
  THREE_PLUS_NEWLINES,
  isBreakLine,
  isContinuationLine,
} from "../patterns.js";

/**
 * Clean Claude terminal dump output.
 *
 * - Remove box-drawing chars │┃╏╎▌ (NOT plain pipes)
 * - Collapse 2+ spaces → 1
 * - Join soft-wrapped lines, preserving bullets, numbered lists, uppercase starts, emojis
 * - Join continuation lines (lowercase after lowercase/comma/colon)
 * - Trim lines, filter empty
 * - Collapse 3+ newlines → 2
 */
export function cleanClaudeDump(input: string): string {
  // Remove box-drawing characters
  let text = input.replace(BOX_DRAWING_CHARS, "");

  // Collapse multiple spaces
  text = text.replace(MULTI_SPACES, " ");

  // Process lines: join soft-wrapped lines
  const lines = text.split("\n");
  const result: string[] = [];

  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();

    if (result.length === 0) {
      result.push(trimmed);
      continue;
    }

    const prevLine = result[result.length - 1];

    if (trimmed === "") {
      result.push("");
      continue;
    }

    // If this line is a continuation of the previous, join them
    if (!isBreakLine(trimmed) && isContinuationLine(prevLine, trimmed)) {
      result[result.length - 1] = prevLine + " " + trimmed;
    } else {
      result.push(trimmed);
    }
  }

  // Filter consecutive empty lines and trim
  let output = result.join("\n");

  // Collapse 3+ newlines → 2
  output = output.replace(THREE_PLUS_NEWLINES, "\n\n");

  return output.trim();
}
