import Carbon.HIToolbox
import AppKit

// MARK: - Key code to display string

let keyCodeToString: [UInt32: String] = [
    UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
    UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
    UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
    UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
    UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
    UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
    UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
    UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
    UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
    UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
    UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
    UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
    UInt32(kVK_ANSI_9): "9",
    UInt32(kVK_Space): "Space", UInt32(kVK_Return): "Return", UInt32(kVK_Tab): "Tab",
    UInt32(kVK_Delete): "Delete", UInt32(kVK_ForwardDelete): "Fwd Del",
    UInt32(kVK_UpArrow): "↑", UInt32(kVK_DownArrow): "↓",
    UInt32(kVK_LeftArrow): "←", UInt32(kVK_RightArrow): "→",
    UInt32(kVK_ANSI_Minus): "-", UInt32(kVK_ANSI_Equal): "=",
    UInt32(kVK_ANSI_LeftBracket): "[", UInt32(kVK_ANSI_RightBracket): "]",
    UInt32(kVK_ANSI_Semicolon): ";", UInt32(kVK_ANSI_Quote): "'",
    UInt32(kVK_ANSI_Comma): ",", UInt32(kVK_ANSI_Period): ".",
    UInt32(kVK_ANSI_Slash): "/", UInt32(kVK_ANSI_Backslash): "\\",
]

// MARK: - Modifier conversion

func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
    var mods: UInt32 = 0
    if flags.contains(.command) { mods |= UInt32(cmdKey) }
    if flags.contains(.shift) { mods |= UInt32(shiftKey) }
    if flags.contains(.option) { mods |= UInt32(optionKey) }
    if flags.contains(.control) { mods |= UInt32(controlKey) }
    return mods
}

func modifierSymbols(from carbonMods: UInt32) -> String {
    var s = ""
    if carbonMods & UInt32(controlKey) != 0 { s += "\u{2303}" } // ⌃
    if carbonMods & UInt32(optionKey) != 0 { s += "\u{2325}" }  // ⌥
    if carbonMods & UInt32(shiftKey) != 0 { s += "\u{21E7}" }   // ⇧
    if carbonMods & UInt32(cmdKey) != 0 { s += "\u{2318}" }     // ⌘
    return s
}

func shortcutDisplayString(keyCode: UInt32, modifiers: UInt32) -> String {
    let modStr = modifierSymbols(from: modifiers)
    let keyStr = keyCodeToString[keyCode] ?? "?"
    return modStr + keyStr
}

// MARK: - Notification

extension Notification.Name {
    static let hotkeyChanged = Notification.Name("clipcleanHotkeyChanged")
}
