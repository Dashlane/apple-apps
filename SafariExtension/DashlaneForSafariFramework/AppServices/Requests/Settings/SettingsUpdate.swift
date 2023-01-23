import Foundation

struct SettingsUpdate {

    enum Action: String {
        case userDefinedRulesUpdate
    }

    let action: Action

    func communication() -> Communication {
        let messageDictionary = [
            "action" : action.rawValue,
        ]
        let message = Message(message: messageDictionary, tabId: -1)
        return Communication(from: .plugin, to: .background, subject: "settingsUpdate", body: message.rawValue)
    }
}
