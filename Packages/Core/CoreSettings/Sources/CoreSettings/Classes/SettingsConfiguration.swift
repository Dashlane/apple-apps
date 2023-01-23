import Foundation

public struct SettingsConfiguration {
        public let modelURL: URL
        public let storeURL: URL
    
    public init(modelURL: URL, storeURL: URL) {
        self.modelURL = modelURL
        self.storeURL = storeURL
    }
    
}
