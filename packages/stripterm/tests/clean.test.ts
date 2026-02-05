import { describe, it, expect } from "vitest";
import { readFileSync } from "fs";
import { join } from "path";
import { cleanText } from "../src/clean.js";
import { cleanClaudeDump } from "../src/cleaners/claude-dump.js";
import { cleanGitDiff } from "../src/cleaners/git-diff.js";
import { cleanLLMText } from "../src/cleaners/llm-text.js";

const fixturesDir = join(import.meta.dirname, "fixtures");

function readFixture(name: string): string {
  return readFileSync(join(fixturesDir, name), "utf8");
}

describe("cleanClaudeDump", () => {
  it("cleans claude-dump fixture", () => {
    const input = readFixture("claude-dump.input.txt");
    const expected = readFixture("claude-dump.expected.txt");
    expect(cleanClaudeDump(input)).toBe(expected);
  });

  it("removes box-drawing characters", () => {
    expect(cleanClaudeDump("│ hello │")).toBe("hello");
  });

  it("collapses multiple spaces", () => {
    expect(cleanClaudeDump("hello    world")).toBe("hello world");
  });

  it("preserves bullet points", () => {
    const input = "Intro text\n- item one\n- item two";
    const result = cleanClaudeDump(input);
    expect(result).toContain("- item one");
    expect(result).toContain("- item two");
  });
});

describe("cleanGitDiff", () => {
  it("cleans git-diff fixture", () => {
    const input = readFixture("git-diff.input.txt");
    const expected = readFixture("git-diff.expected.txt");
    expect(cleanGitDiff(input)).toBe(expected);
  });

  it("preserves diff line markers", () => {
    const input = "10 + added\n11 - removed";
    const result = cleanGitDiff(input);
    expect(result).toContain("10 + added");
    expect(result).toContain("11 - removed");
  });
});

describe("cleanLLMText", () => {
  it("cleans llm-text fixture", () => {
    const input = readFixture("llm-text.input.txt");
    const expected = readFixture("llm-text.expected.txt");
    expect(cleanLLMText(input)).toBe(expected);
  });

  it("joins soft-wrapped lines", () => {
    const input = "This is a line that\ncontinues here.";
    const result = cleanLLMText(input);
    expect(result).toBe("This is a line that continues here.");
  });

  it("preserves paragraph breaks", () => {
    const input = "Paragraph one.\n\nParagraph two.";
    expect(cleanLLMText(input)).toBe("Paragraph one.\n\nParagraph two.");
  });
});

describe("cleanText", () => {
  it("auto-detects claude-dump and cleans", () => {
    const input = "│ hello world";
    const result = cleanText(input);
    expect(result.detectedType).toBe("claude-dump");
    expect(result.output).toBe("hello world");
  });

  it("respects forced type", () => {
    const input = "some text";
    const result = cleanText(input, { type: "claude-dump" });
    expect(result.detectedType).toBe("claude-dump");
  });

  it("strips ANSI when enabled", () => {
    const input = "\x1B[31mhello\x1B[0m world";
    const result = cleanText(input, { stripAnsi: true });
    expect(result.output).toContain("hello");
    expect(result.output).not.toContain("\x1B");
  });

  it("leaves code untouched", () => {
    const input = "function foo() {\n  const x = bar();\n  return x;\n}";
    const result = cleanText(input);
    expect(result.detectedType).toBe("code");
    expect(result.output).toBe(input);
  });
});
