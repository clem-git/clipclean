import * as vscode from "vscode";
import { cleanText } from "clipclean";

/** Copy selection → clean → clipboard */
export async function copyClean() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage("No active editor.");
    return;
  }

  const selection = editor.document.getText(editor.selection);
  if (!selection) {
    vscode.window.showWarningMessage("No text selected.");
    return;
  }

  const { output } = cleanText(selection);
  await vscode.env.clipboard.writeText(output);
  vscode.window.showInformationMessage("Cleaned text copied to clipboard.");
}

/** Read clipboard → clean → paste into editor */
export async function pasteClean() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage("No active editor.");
    return;
  }

  const text = await vscode.env.clipboard.readText();
  if (!text) {
    vscode.window.showWarningMessage("Clipboard is empty.");
    return;
  }

  const { output } = cleanText(text);
  await editor.edit((editBuilder) => {
    editBuilder.replace(editor.selection, output);
  });
}

/** Clean clipboard in-place */
export async function cleanClipboard() {
  const text = await vscode.env.clipboard.readText();
  if (!text) {
    vscode.window.showWarningMessage("Clipboard is empty.");
    return;
  }

  const { output, detectedType } = cleanText(text);
  await vscode.env.clipboard.writeText(output);
  vscode.window.showInformationMessage(`Clipboard cleaned (${detectedType}).`);
}

/** Clean selected text in-place in editor */
export async function cleanSelection() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage("No active editor.");
    return;
  }

  const selection = editor.selection;
  const text = editor.document.getText(selection);
  if (!text) {
    vscode.window.showWarningMessage("No text selected.");
    return;
  }

  const { output } = cleanText(text);
  await editor.edit((editBuilder) => {
    editBuilder.replace(selection, output);
  });
}
