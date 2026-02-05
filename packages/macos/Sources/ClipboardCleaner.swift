import JavaScriptCore
import AppKit

class ClipboardCleaner {
    private let context: JSContext

    init() {
        context = JSContext()!
        context.exceptionHandler = { _, exception in
            print("[Clipclean JSC] \(exception?.toString() ?? "unknown error")")
        }

        // Load the bundled JS (IIFE that sets global `clipclean`)
        if let jsURL = Bundle.main.url(forResource: "clipclean.bundle", withExtension: "js"),
           let jsCode = try? String(contentsOf: jsURL, encoding: .utf8) {
            context.evaluateScript(jsCode)
        } else {
            print("[Clipclean] Could not load clipclean.bundle.js from app bundle.")
        }
    }

    /// Cleans the system clipboard in-place. Returns the detected content type, or nil on failure.
    func clean() -> String? {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return nil }

        let stripAnsi = UserDefaults.standard.bool(forKey: "stripAnsi")

        context.setObject(text, forKeyedSubscript: "__input" as NSString)
        let js = "clipclean.cleanText(__input, { stripAnsi: \(stripAnsi) })"
        let result = context.evaluateScript(js)

        guard let dict = result?.toDictionary(),
              let output = dict["output"] as? String,
              let detectedType = dict["detectedType"] as? String else { return nil }

        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
        return detectedType
    }
}
