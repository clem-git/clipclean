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

    /// Wait for modifier keys to be released, simulate Cmd+C, wait for clipboard to update, then clean
    func copyAndClean() {
        let prevCount = NSPasteboard.general.changeCount
        waitForModifierRelease { [weak self] in
            self?.simulateKeyCombo(key: CGKeyCode(kVK_ANSI_C), flags: .maskCommand)
            self?.waitForClipboardChange(from: prevCount, attempts: 0)
        }
    }

    /// Clean clipboard, wait for modifier release, then simulate Cmd+V
    func cleanAndPaste() {
        guard let detectedType = cleaner.clean() else { return }
        flashSuccess(detectedType)
        waitForModifierRelease { [weak self] in
            self?.simulateKeyCombo(key: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
        }
    }

    // MARK: - Helpers

    private func waitForModifierRelease(then action: @escaping () -> Void) {
        let flags = CGEventSource.flagsState(.hidSystemState)
        let held: CGEventFlags = [.maskShift, .maskAlternate, .maskCommand, .maskControl]
        if flags.intersection(held).isEmpty {
            action()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.waitForModifierRelease(then: action)
            }
        }
    }

    private func waitForClipboardChange(from prevCount: Int, attempts: Int) {
        if NSPasteboard.general.changeCount != prevCount {
            cleanClipboard()
        } else if attempts < 20 { // max ~1s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.waitForClipboardChange(from: prevCount, attempts: attempts + 1)
            }
        }
    }

    private func simulateKeyCombo(key: CGKeyCode, flags: CGEventFlags) {
        let src = CGEventSource(stateID: .privateState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
        keyDown?.flags = flags
        keyDown?.post(tap: .cghidEventTap)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false)
        keyUp?.flags = flags
        keyUp?.post(tap: .cghidEventTap)
    }
}
