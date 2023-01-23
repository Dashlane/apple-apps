import SwiftTreats

public extension SharedUserDefault {
    init(key: Key, `default` defaultValue: T) {
        self.init(key: key, default: defaultValue, userDefaults: ApplicationGroup.userDefaults)
    }
    
    init<P>(key: Key, `default` defaultValue: P? = nil) where T == P? {
        self.init(key: key, default: defaultValue, userDefaults: ApplicationGroup.userDefaults)
    }
}
