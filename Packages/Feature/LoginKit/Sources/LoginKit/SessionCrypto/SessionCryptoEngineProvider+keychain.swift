import CoreCrypto
import CoreKeychain
import CoreUserTracking
import CyrilKit
import DashTypes
import Foundation

extension SessionCryptoEngineProvider:
  CoreKeychain.AuthenticationKeychainCryptoEngineProvider,
  CoreUserTracking.UserTrackingAppActivityReporterCryptoEngineProvider
{

  public func keychainCryptoEngine(using key: SymmetricKey) throws -> CryptoEngine {
    try CryptoConfiguration.defaultNoDerivation.makeCryptoEngine(secret: .key(key))
  }

  public func keychainCryptoEngine(
    forEncryptedPayload encryptedData: Data, using secret: EncryptionSecret
  ) throws -> CryptoEngine {
    try CryptoConfiguration(encryptedData: encryptedData).makeCryptoEngine(secret: secret)
  }

  public func trackingDataCryptoEngine(forKey data: Data) throws -> CryptoEngine {
    try CryptoConfiguration.legacy(.kwc5).makeCryptoEngine(secret: .key(data))
  }
}
