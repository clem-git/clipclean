import * as vscode from "vscode";
import { copyClean, pasteClean, cleanClipboard, cleanSelection } from "./commands.js";

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand("clipclean.copyClean", copyClean),
    vscode.commands.registerCommand("clipclean.pasteClean", pasteClean),
    vscode.commands.registerCommand("clipclean.cleanClipboard", cleanClipboard),
    vscode.commands.registerCommand("clipclean.cleanSelection", cleanSelection),
  );

  // Status bar item
  const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  statusBar.text = "Clipclean";
  statusBar.command = "clipclean.cleanClipboard";
  statusBar.tooltip = "Click to clean clipboard";
  statusBar.show();
  context.subscriptions.push(statusBar);
}

export function deactivate() {}
