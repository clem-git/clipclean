import SwiftUI
import Carbon.HIToolbox

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var iconName = "sparkles"
    @Published var lastResult: String? = nil

    private let cleaner = ClipboardCleaner()

    private func flashSuccess(_ detectedType: String) {
        lastResult = detectedType
        iconName = "checkmark.circle.fill"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.iconName = "sparkles"
        }
    }

    /// Clean clipboard in-place
    func cleanClipboard() {
        guard let detectedType = cleaner.clean() else { return }
        flashSuccess(detectedType)
    }

    /// Simulate Cmd+C, then clean the clipboard
    func copyAndClean() {
        simulateKeyCombo(key: CGKeyCode(kVK_ANSI_C), flags: .maskCommand)
        // Small delay to let the clipboard update from the copy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.cleanClipboard()
        }
    }

    /// Clean clipboard then simulate Cmd+V to paste into frontmost app
    func cleanAndPaste() {
        guard let detectedType = cleaner.clean() else { return }
        flashSuccess(detectedType)
        simulateKeyCombo(key: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
    }

    private func simulateKeyCombo(key: CGKeyCode, flags: CGEventFlags) {
        let src = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
        keyDown?.flags = flags
        keyDown?.post(tap: .cghidEventTap)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false)
        keyUp?.flags = flags
        keyUp?.post(tap: .cghidEventTap)
    }
}
