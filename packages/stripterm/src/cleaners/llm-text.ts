import {
  MULTI_SPACES,
  THREE_PLUS_NEWLINES,
  isBreakLine,
  isContinuationLine,
} from "../patterns.js";

/**
 * Clean generic LLM text output.
 *
 * - Join soft-wrapped lines (preserving bullets, numbered lists, uppercase, emojis)
 * - Collapse whitespace to single space
 * - Trim each line
 * - Collapse 3+ newlines → 2
 */
export function cleanLLMText(input: string): string {
  // Collapse multiple spaces
  let text = input.replace(MULTI_SPACES, " ");

  // Process lines
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

    // If this is a continuation line, join it
    if (!isBreakLine(trimmed) && isContinuationLine(prevLine, trimmed)) {
      result[result.length - 1] = prevLine + " " + trimmed;
    } else {
      result.push(trimmed);
    }
  }

  let output = result.join("\n");

  // Collapse 3+ newlines → 2
  output = output.replace(THREE_PLUS_NEWLINES, "\n\n");

  return output.trim();
}
