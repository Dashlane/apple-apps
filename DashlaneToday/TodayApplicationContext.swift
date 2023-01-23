import Foundation
import CoreKeychain
import DashlaneCrypto
import DashTypes
import DashlaneAppKit
import LoginKit

final public class TodayApplicationContext: Codable, Equatable {
    
    struct Token: Codable, Equatable  {
        let url: URL
        let title: String
        let login: String
    }
    
    public struct ReportHeaderInfo: Codable {
        public let userId: String
        public let device: String
    }

    var tokens = [Token]()
    var isUniversalClipboardEnabled = false
    var isClipboardExpirationSet = true
    var advancedSystemIntegration = false
    public var reportHeaderInfo: ReportHeaderInfo?
    
    public static func == (lhs: TodayApplicationContext, rhs: TodayApplicationContext) -> Bool {
        return lhs.tokens == rhs.tokens
            && lhs.isUniversalClipboardEnabled == rhs.isUniversalClipboardEnabled
            && lhs.isClipboardExpirationSet == rhs.isClipboardExpirationSet
            && lhs.advancedSystemIntegration == rhs.advancedSystemIntegration
    }
    
    static var containerURL: URL? {
                guard let info = Bundle.main.infoDictionary,
            let identifier = info["com.dashlane.securityApplicationGroupIdentifier"] as? String else {
                return nil
        }
       if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
            return url
        }
                return nil
    }
    
    static var storageURL: URL? {
        guard let containerURL = containerURL else { return nil }
        return containerURL.appendingPathComponent("today.json", isDirectory: false)
    }
    
    enum DiskError: Error {
        case noStorageUrl
    }
    
    enum EncryptionError: Error {
        case cannotEncrypt
        case cannotDecrypt
    }
    
    func toDisk() throws {
        guard let url = TodayApplicationContext.storageURL else { throw DiskError.noStorageUrl }
        let data = try JSONEncoder().encode(self)
        guard let encrypted = TodayCryptoEngine().encrypt(data: data) else {
            throw EncryptionError.cannotEncrypt
        }
        try encrypted.write(to: url, options: [.atomic, .completeFileProtection])
    }
    
    static func fromDisk() throws -> TodayApplicationContext {
        guard let url = TodayApplicationContext.storageURL else { throw DiskError.noStorageUrl }
        let data = try Data(contentsOf: url)
        guard let decrypted = TodayCryptoEngine().decrypt(data: data) else {
            throw EncryptionError.cannotDecrypt
        }
        let context = try JSONDecoder().decode(TodayApplicationContext.self, from: decrypted)
        
        return context
    }
}

struct TodayCryptoEngine: DashTypes.CryptoEngine {
 
    @KeychainItemAccessor
    private var communicationCryptoKey: Data?
    
    private let cryptoCenter: CryptoCenter
    
    private func generateCommunicationKey() -> Data {
        Random.randomData(ofSize: 64)
    }
    
    init() {
        _communicationCryptoKey = KeychainItemAccessor(identifier: "today-widget-extension",
                                                       accessGroup: ApplicationGroup.keychainAccessGroup)
        self.cryptoCenter = CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!
    }
    
    var communicationKey: Data {
        guard let key = communicationCryptoKey, key.count == 64 else {
            let generated = generateCommunicationKey()
            communicationCryptoKey = generated
            return generated
        }
        return key
    }
    
    
    func encrypt(data: Data) -> Data? {
        try? cryptoCenter.encrypt(data: data, with: .key(communicationKey))
    }
    
    func decrypt(data: Data) -> Data? {
        try? cryptoCenter.decrypt(data: data, with: .key(communicationKey))
    }
}



