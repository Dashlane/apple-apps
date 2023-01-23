import Foundation

internal struct ResourcesAccessor {
    static var modelURL: URL {
        return Bundle.settings.url(forResource: "SettingsDataModel", withExtension: "momd")!
    }
}
