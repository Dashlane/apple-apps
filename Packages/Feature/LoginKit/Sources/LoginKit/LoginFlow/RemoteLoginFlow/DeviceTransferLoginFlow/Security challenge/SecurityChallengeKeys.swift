import CoreCrypto
import CoreSession
import CoreTypes
import Foundation

extension SecurityChallengeKeys {
  public func makeDeviceTransferCryptoEngine() -> DeviceTransferCryptoEngine {
    return DeviceTransferCryptoEngine(symmetricKey: symmetricKey)
  }
}
