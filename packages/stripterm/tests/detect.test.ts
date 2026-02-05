import { describe, it, expect } from "vitest";
import { detectContentType } from "../src/detect.js";

describe("detectContentType", () => {
  it("detects claude-dump from box-drawing chars", () => {
    const input = "│ Hello world\n│ Second line";
    expect(detectContentType(input)).toBe("claude-dump");
  });

  it("detects git-diff from diff lines", () => {
    const input = "10 + added line\n11 - removed line\n12   context";
    expect(detectContentType(input)).toBe("git-diff");
  });

  it("detects code from high code-char ratio", () => {
    const input = "function foo() {\n  const x = bar();\n  return x;\n}";
    expect(detectContentType(input)).toBe("code");
  });

  it("defaults to llm-text", () => {
    const input = "This is a regular paragraph\nwith some text.";
    expect(detectContentType(input)).toBe("llm-text");
  });

  it("returns llm-text for empty input", () => {
    expect(detectContentType("")).toBe("llm-text");
  });

  it("prioritizes git-diff over claude-dump", () => {
    const input = "│ 10 + added\n│ 11 - removed\n│ 12   context";
    expect(detectContentType(input)).toBe("git-diff");
  });

  it("does not misdetect plain pipe as claude-dump", () => {
    const input = "A | B | C\nD | E | F";
    expect(detectContentType(input)).not.toBe("claude-dump");
  });
});
