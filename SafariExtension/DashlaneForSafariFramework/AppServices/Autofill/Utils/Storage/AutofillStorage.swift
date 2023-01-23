import Foundation

protocol AutofillStorageProtocol {
    func getUserDefinedRules() -> Set<UserDefinedRule>
    func removeUserDefinedRules(_ rules: Set<UserDefinedRule>)
}

struct AutofillStorage: AutofillStorageProtocol {

        enum Keys: String {
        case userDefinedRules = "background.maverick.userDefinedRules"
    }

    fileprivate let storage: UnencryptedRawStorage = UserDefaults.standard

    let postSettingsUpdate: (SettingsUpdate) -> Void
}

private extension UnencryptedRawStorage {
    func object(for key: AutofillStorage.Keys) -> Any? {
        self.object(forKey: key.rawValue)
    }

    func set(_ value: Any?, for key: AutofillStorage.Keys) {
        self.set(value, forKey: key.rawValue)
    }
}

extension AutofillStorage {
    func getUserDefinedRules() -> Set<UserDefinedRule> {
        guard let rawString = storage.object(for: .userDefinedRules) as? String,
              let data = rawString.data(using: .utf8) else {
            return []
        }
        let rules = (try? JSONDecoder().decode(Set<UserDefinedRule>.self, from: data)) ?? []
        return rules
    }

    func removeUserDefinedRules(_ rules: Set<UserDefinedRule>) {
        let filteredRules = getUserDefinedRules().subtracting(rules)
        guard let encoded = try? JSONEncoder().encode(filteredRules),
              let json = String(data: encoded, encoding: .utf8) else {
            return
        }
        storage.set(json, for: .userDefinedRules)
        postSettingsUpdate(SettingsUpdate(action: .userDefinedRulesUpdate))
    }
}

struct AutofillStorageMock: AutofillStorageProtocol {

    var rules = Set<UserDefinedRule>()

    func getUserDefinedRules() -> Set<UserDefinedRule> {
        rules
    }

    func removeUserDefinedRules(_ rules: Set<UserDefinedRule>) {

    }
}
