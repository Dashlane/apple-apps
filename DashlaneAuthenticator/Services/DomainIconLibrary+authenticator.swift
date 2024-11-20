import Combine
import CoreSession
import CoreSync
import DashTypes
import DashlaneAPI
import Foundation
import IconLibrary
import VaultKit

extension DomainIconLibrary {
  init(userDeviceAPIClient: UserDeviceAPIClient, logger: Logger) async {
    await self.init(
      cacheDirectory: ApplicationGroup.authenticatorStandaloneStoreURL.appendingPathComponent(
        "icons"),
      cryptoEngine: DomainIconCryptoEngine(),
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger
    )
  }

  init(userDeviceAPIClient: UserDeviceAPIClient, session: Session, logger: Logger) async {
    let cacheDirectory: URL
    do {
      cacheDirectory = try session.directory.storeURL(for: .icons, in: .authenticator)
    } catch {
      logger.error(
        "Failed to get a store url for the session, use temporary folder instead", error: error)
      cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
        "\(session.login.email)-authenticator-icons")
    }
    await self.init(
      cacheDirectory: cacheDirectory,
      cryptoEngine: session.localCryptoEngine,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger
    )
  }

}

struct DomainIconCryptoEngine: CryptoEngine {
  func decrypt(_ data: Data) throws -> Data {
    return data
  }

  func encrypt(_ data: Data) throws -> Data {
    return data
  }
}
