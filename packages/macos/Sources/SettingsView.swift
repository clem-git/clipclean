import SwiftUI
import ServiceManagement
import Carbon.HIToolbox

struct SettingsView: View {
    @AppStorage("stripAnsi") private var stripAnsi: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false

    var body: some View {
        Form {
            Section("Shortcuts") {
                ShortcutRow(
                    label: "Copy & Clean",
                    description: "Copies the current selection and cleans it on the clipboard.",
                    keyCodeKey: "copyAndClean.keyCode",
                    modifiersKey: "copyAndClean.modifiers",
                    defaultKeyCode: Int(kVK_ANSI_C),
                    defaultModifiers: Int(cmdKey | shiftKey | optionKey)
                )
                Divider()
                ShortcutRow(
                    label: "Clean Clipboard",
                    description: "Cleans clipboard in-place \u{2014} removes terminal artifacts, joins soft-wrapped lines, strips box-drawing characters.",
                    keyCodeKey: "cleanClipboard.keyCode",
                    modifiersKey: "cleanClipboard.modifiers",
                    defaultKeyCode: Int(kVK_ANSI_X),
                    defaultModifiers: Int(cmdKey | shiftKey | optionKey)
                )
                Divider()
                ShortcutRow(
                    label: "Clean & Paste",
                    description: "Cleans clipboard then pastes the result into the active app.",
                    keyCodeKey: "cleanAndPaste.keyCode",
                    modifiersKey: "cleanAndPaste.modifiers",
                    defaultKeyCode: Int(kVK_ANSI_V),
                    defaultModifiers: Int(cmdKey | shiftKey | optionKey)
                )
            }
            Section("Cleaning") {
                Toggle("Strip ANSI escape codes", isOn: $stripAnsi)
                Text("Remove terminal color/formatting codes before cleaning.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Section("General") {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(newValue)
                    }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[Clipclean] Login item error: \(error)")
        }
    }
}

// MARK: - Shortcut row with recorder + description

struct ShortcutRow: View {
    let label: String
    let description: String
    let keyCodeKey: String
    let modifiersKey: String
    let defaultKeyCode: Int
    let defaultModifiers: Int

    @State private var keyCode: Int
    @State private var modifiers: Int
    @State private var isRecording = false
    @State private var eventMonitor: Any?

    init(label: String, description: String, keyCodeKey: String, modifiersKey: String, defaultKeyCode: Int, defaultModifiers: Int) {
        self.label = label
        self.description = description
        self.keyCodeKey = keyCodeKey
        self.modifiersKey = modifiersKey
        self.defaultKeyCode = defaultKeyCode
        self.defaultModifiers = defaultModifiers
        // Read from UserDefaults, falling back to defaults
        let storedKey = UserDefaults.standard.object(forKey: keyCodeKey) as? Int ?? defaultKeyCode
        let storedMods = UserDefaults.standard.object(forKey: modifiersKey) as? Int ?? defaultModifiers
        _keyCode = State(initialValue: storedKey)
        _modifiers = State(initialValue: storedMods)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(label) {
                Button(action: toggleRecording) {
                    Text(isRecording ? "Press shortcut\u{2026}" : displayString())
                        .frame(minWidth: 120)
                        .foregroundColor(isRecording ? .accentColor : .primary)
                }
                .onDisappear { stopRecording() }
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func displayString() -> String {
        shortcutDisplayString(keyCode: UInt32(keyCode), modifiers: UInt32(modifiers))
    }

    private func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        isRecording = true
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard mods.contains(.command) || mods.contains(.control) else {
                if event.keyCode == UInt16(kVK_Escape) {
                    self.stopRecording()
                    return nil
                }
                return event
            }
            self.keyCode = Int(event.keyCode)
            self.modifiers = Int(carbonModifiers(from: mods))
            UserDefaults.standard.set(self.keyCode, forKey: self.keyCodeKey)
            UserDefaults.standard.set(self.modifiers, forKey: self.modifiersKey)
            self.stopRecording()
            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
