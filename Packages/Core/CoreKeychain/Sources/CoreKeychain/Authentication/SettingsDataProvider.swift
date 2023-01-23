import Foundation

public protocol SettingsDataProvider {
                func masterKeyExpirationDate() throws -> Date
    
                func saveMasterKeyExpirationDate(_ expirationDate: Date) throws
    
                func removeMasterKeyExpirationDate()
}
