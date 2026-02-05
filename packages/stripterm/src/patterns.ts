/** Unicode box-drawing characters used by Claude terminal output */
export const BOX_DRAWING_CHARS = /[│┃╏╎▌]/g;

/** Detect git-diff style lines: leading digits followed by +/- */
export const GIT_DIFF_LINE = /^\s*\d+\s*[+-]\s/;

/** Detect any diff-numbered line (with or without +/-, i.e. context lines too) */
export const DIFF_NUMBERED_LINE = /^\s*\d+\s/;

/** ANSI escape sequences */
export const ANSI_ESCAPE = /\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])/g;

/** Bullet points: -, *, •, ▸, ▹, ▪, ▫ */
export const BULLET_START = /^[\s]*[-*•▸▹▪▫]\s/;

/** Numbered list items */
export const NUMBERED_LIST = /^[\s]*\d+[.)]\s/;

/** Line starts with emoji */
export const EMOJI_START = /^[\p{Emoji_Presentation}\p{Extended_Pictographic}]/u;

/** Code-like characters */
export const CODE_CHARS = /[{}();=]/g;

/** Multiple spaces (2+) */
export const MULTI_SPACES = /  +/g;

/** Three or more consecutive newlines */
export const THREE_PLUS_NEWLINES = /\n{3,}/g;

/** Four or more consecutive newlines */
export const FOUR_PLUS_NEWLINES = /\n{4,}/g;

/** Check if a line is a "break" line (starts a new logical block) */
export function isBreakLine(line: string): boolean {
  const trimmed = line.trim();
  if (trimmed === "") return true;
  if (BULLET_START.test(trimmed)) return true;
  if (NUMBERED_LIST.test(trimmed)) return true;
  if (EMOJI_START.test(trimmed)) return true;
  if (trimmed.startsWith("#")) return true;
  if (trimmed.startsWith(">")) return true;
  if (trimmed.startsWith("```")) return true;
  return false;
}

/** Check if current line should be joined to previous (continuation) */
export function isContinuationLine(prevLine: string, currentLine: string): boolean {
  const prevTrimmed = prevLine.trim();
  const currentTrimmed = currentLine.trim();
  if (currentTrimmed === "" || prevTrimmed === "") return false;
  if (isBreakLine(currentTrimmed)) return false;
  return true;
}
