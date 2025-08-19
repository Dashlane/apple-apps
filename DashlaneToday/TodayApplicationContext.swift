import CoreCrypto
import CoreKeychain
import CoreTypes
import Foundation
import LoginKit
import SwiftTreats

final public class TodayApplicationContext: Codable, Equatable {

  struct Token: Codable, Equatable {
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
      let identifier = info["com.dashlane.securityApplicationGroupIdentifier"] as? String
    else {
      return nil
    }
    if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    {
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

  func toDisk() throws {
    guard let url = TodayApplicationContext.storageURL else { throw DiskError.noStorageUrl }
    let data = try JSONEncoder().encode(self)
    let encrypted = try TodayCryptoEngine().encrypt(data)

    try encrypted.write(to: url, options: [.atomic, .completeFileProtection])
  }

  static func fromDisk() throws -> TodayApplicationContext {
    guard let url = TodayApplicationContext.storageURL else { throw DiskError.noStorageUrl }
    let data = try Data(contentsOf: url)
    let decrypted = try TodayCryptoEngine().decrypt(data)
    let context = try JSONDecoder().decode(TodayApplicationContext.self, from: decrypted)

    return context
  }
}

struct TodayCryptoEngine: CoreTypes.CryptoEngine {
  @KeychainItemAccessor
  private var communicationCryptoKey: Data?

  let cryptoConfig = CryptoConfiguration.defaultNoDerivation

  init() {
    _communicationCryptoKey = KeychainItemAccessor(
      identifier: "today-widget-extension",
      accessGroup: ApplicationGroup.keychainAccessGroup,
      shouldAccessAfterFirstUnlock: false)
  }

  var communicationKey: Data {
    guard let key = communicationCryptoKey, key.count == 64 else {
      let generated = Data.random(ofSize: 64)
      communicationCryptoKey = generated
      return generated
    }
    return key
  }

  private var cryptoEngine: CryptoEngine {
    get throws {
      try CryptoConfiguration.defaultNoDerivation.makeCryptoEngine(secret: .key(communicationKey))
    }
  }

  func encrypt(_ data: Data) throws -> Data {
    try cryptoEngine.encrypt(data)
  }

  func decrypt(_ data: Data) throws -> Data {
    try cryptoEngine.decrypt(data)
  }
}
