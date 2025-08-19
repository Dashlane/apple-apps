import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import IconLibrary
import LogFoundation

public struct IconService: IconServiceProtocol {
  public let domain: DomainIconLibraryProtocol
  public let gravatar: GravatarIconLibraryProtocol

  public init(
    session: Session, userDeviceAPIClient: UserDeviceAPIClient, logger: Logger, target: BuildTarget
  ) async {
    let cacheDirectory: URL
    do {
      cacheDirectory = try session.directory.storeURL(for: .icons, in: target)
    } catch {
      logger.error(
        "Failed to get a store url for the session, use temporary folder instead", error: error)
      cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
        "\(session.login.email)-icons")
    }

    let cryptoEngine = session.localCryptoEngine

    domain = await DomainIconLibrary(
      cacheDirectory: cacheDirectory,
      cryptoEngine: cryptoEngine,
      userDeviceAPIClient: userDeviceAPIClient,
      logger: logger
    )

    gravatar = await GravatarIconLibrary(
      cacheDirectory: cacheDirectory,
      cryptoEngine: cryptoEngine,
      logger: logger
    )
  }
}
