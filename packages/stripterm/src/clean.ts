import { detectContentType, type ContentType } from "./detect.js";
import { cleanClaudeDump } from "./cleaners/claude-dump.js";
import { cleanGitDiff } from "./cleaners/git-diff.js";
import { cleanLLMText } from "./cleaners/llm-text.js";
import { ANSI_ESCAPE } from "./patterns.js";

export interface CleanOptions {
  /** Force a specific content type instead of auto-detecting */
  type?: ContentType;
  /** Strip ANSI escape codes before cleaning. Default: false */
  stripAnsi?: boolean;
}

export interface CleanResult {
  output: string;
  detectedType: ContentType;
}

/**
 * Clean messy terminal/LLM output.
 *
 * Auto-detects content type and applies the appropriate cleaner.
 * Code content is returned as-is (only ANSI stripping if enabled).
 */
export function cleanText(input: string, opts?: CleanOptions): CleanResult {
  let text = input;

  // Strip ANSI if requested
  if (opts?.stripAnsi) {
    text = text.replace(ANSI_ESCAPE, "");
  }

  const detectedType = opts?.type ?? detectContentType(text);

  let output: string;
  switch (detectedType) {
    case "claude-dump":
      output = cleanClaudeDump(text);
      break;
    case "git-diff":
      output = cleanGitDiff(text);
      break;
    case "code":
      output = text; // Leave code untouched
      break;
    case "llm-text":
    default:
      output = cleanLLMText(text);
      break;
  }

  return { output, detectedType };
}
