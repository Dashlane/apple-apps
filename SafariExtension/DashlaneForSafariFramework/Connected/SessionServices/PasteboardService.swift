import Cocoa
import DashlaneAppKit
import CoreSettings

public extension NSPasteboard.PasteboardType {
    static let concealed: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: "org.nspasteboard.ConcealedType")
}

struct PasteboardService {

    let userSettings: UserSettings

    func set(_ text: String) {
        NSPasteboard.general.setPassword(text)
    }

}

extension PasteboardService {
    public static func mock() -> PasteboardService {
        return PasteboardService(userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore()))
    }
}

private extension NSPasteboard {
            func setPassword(_ password: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.concealed, .string], owner: nil)
        pasteboard.setString(password, forType: .concealed)
        pasteboard.setString(password, forType: .string)
    }
}
