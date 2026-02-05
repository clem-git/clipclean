import SwiftUI
import Carbon.HIToolbox

@main
struct ClipcleanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var state = AppState.shared
    @AppStorage("copyAndClean.keyCode") private var copyKeyCode: Int = Int(kVK_ANSI_C)
    @AppStorage("copyAndClean.modifiers") private var copyModifiers: Int = Int(cmdKey | shiftKey | optionKey)
    @AppStorage("cleanClipboard.keyCode") private var cleanKeyCode: Int = Int(kVK_ANSI_X)
    @AppStorage("cleanClipboard.modifiers") private var cleanModifiers: Int = Int(cmdKey | shiftKey | optionKey)
    @AppStorage("cleanAndPaste.keyCode") private var pasteKeyCode: Int = Int(kVK_ANSI_V)
    @AppStorage("cleanAndPaste.modifiers") private var pasteModifiers: Int = Int(cmdKey | shiftKey | optionKey)

    var body: some Scene {
        MenuBarExtra {
            Button("Copy & Clean  \(copyLabel)") {
                state.copyAndClean()
            }
            Button("Clean Clipboard  \(cleanLabel)") {
                state.cleanClipboard()
            }
            Button("Clean & Paste  \(pasteLabel)") {
                state.cleanAndPaste()
            }
            Divider()
            if let last = state.lastResult {
                Text("Last: \(last)")
                    .foregroundColor(.secondary)
                Divider()
            }
            Button("Settings\u{2026}") {
                SettingsWindowController.shared.show()
            }
            .keyboardShortcut(",")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(systemName: state.iconName)
        }
    }

    private var copyLabel: String {
        shortcutDisplayString(keyCode: UInt32(copyKeyCode), modifiers: UInt32(copyModifiers))
    }

    private var cleanLabel: String {
        shortcutDisplayString(keyCode: UInt32(cleanKeyCode), modifiers: UInt32(cleanModifiers))
    }

    private var pasteLabel: String {
        shortcutDisplayString(keyCode: UInt32(pasteKeyCode), modifiers: UInt32(pasteModifiers))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotkeyManager = HotkeyManager()
    private var observer: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [
            "copyAndClean.keyCode": Int(kVK_ANSI_C),
            "copyAndClean.modifiers": Int(cmdKey | shiftKey | optionKey),
            "cleanClipboard.keyCode": Int(kVK_ANSI_X),
            "cleanClipboard.modifiers": Int(cmdKey | shiftKey | optionKey),
            "cleanAndPaste.keyCode": Int(kVK_ANSI_V),
            "cleanAndPaste.modifiers": Int(cmdKey | shiftKey | optionKey),
            "stripAnsi": true,
            "launchAtLogin": false,
        ])

        hotkeyManager.register(configs: [
            HotkeyConfig(
                id: 1,
                keyCodeKey: "copyAndClean.keyCode",
                modifiersKey: "copyAndClean.modifiers",
                action: { AppState.shared.copyAndClean() }
            ),
            HotkeyConfig(
                id: 2,
                keyCodeKey: "cleanClipboard.keyCode",
                modifiersKey: "cleanClipboard.modifiers",
                action: { AppState.shared.cleanClipboard() }
            ),
            HotkeyConfig(
                id: 3,
                keyCodeKey: "cleanAndPaste.keyCode",
                modifiersKey: "cleanAndPaste.modifiers",
                action: { AppState.shared.cleanAndPaste() }
            ),
        ])

        observer = NotificationCenter.default.addObserver(
            forName: .hotkeyChanged, object: nil, queue: .main
        ) { [weak self] _ in
            self?.hotkeyManager.reregister()
        }
    }
}
