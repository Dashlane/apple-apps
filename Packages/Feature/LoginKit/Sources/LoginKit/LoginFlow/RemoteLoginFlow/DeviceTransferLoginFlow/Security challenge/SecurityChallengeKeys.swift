import CoreCrypto
import CoreSession
import DashTypes
import Foundation

extension SecurityChallengeKeys {
  public func makeDeviceTransferCryptoEngine() -> DeviceTransferCryptoEngine {
    return DeviceTransferCryptoEngine(symmetricKey: symmetricKey)
  }
}
