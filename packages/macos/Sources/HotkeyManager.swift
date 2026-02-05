import Carbon.HIToolbox

struct HotkeyConfig {
    let id: UInt32
    let keyCodeKey: String    // UserDefaults key for key code
    let modifiersKey: String  // UserDefaults key for modifiers
    let action: () -> Void
}

class HotkeyManager {
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var handlerRef: EventHandlerRef?

    static var actions: [UInt32: () -> Void] = [:]
    private var configs: [HotkeyConfig] = []

    func register(configs: [HotkeyConfig]) {
        self.configs = configs
        for config in configs {
            HotkeyManager.actions[config.id] = config.action
        }

        // Install the event handler once
        var eventType = EventTypeSpec(
            eventClass: UInt32(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotkeyEventHandler,
            1,
            &eventType,
            nil,
            &handlerRef
        )

        registerAllFromDefaults()
    }

    func reregister() {
        // Unregister all existing hotkeys
        for (_, ref) in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()
        registerAllFromDefaults()
    }

    private func registerAllFromDefaults() {
        for config in configs {
            let keyCode = UInt32(UserDefaults.standard.integer(forKey: config.keyCodeKey))
            let modifiers = UInt32(UserDefaults.standard.integer(forKey: config.modifiersKey))

            guard keyCode != 0 || modifiers != 0 else { continue }

            let hotKeyID = EventHotKeyID(
                signature: 0x434C_5043, // "CLPC"
                id: config.id
            )

            var ref: EventHotKeyRef?
            RegisterEventHotKey(
                keyCode,
                modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &ref
            )
            if let ref = ref {
                hotKeyRefs[config.id] = ref
            }
        }
    }
}

// Free function required for C callback compatibility
private func hotkeyEventHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event = event else { return OSStatus(eventNotHandledErr) }

    var hotKeyID = EventHotKeyID()
    GetEventParameter(
        event,
        UInt32(kEventParamDirectObject),
        UInt32(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    HotkeyManager.actions[hotKeyID.id]?()
    return noErr
}
