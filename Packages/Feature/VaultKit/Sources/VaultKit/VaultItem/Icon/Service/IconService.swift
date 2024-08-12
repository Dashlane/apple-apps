import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import IconLibrary

public protocol IconServiceProtocol {
  var domain: DomainIconLibraryProtocol { get }
  var gravatar: GravatarIconLibraryProtocol { get }
}

public struct IconService: IconServiceProtocol {
  public let domain: DomainIconLibraryProtocol
  public let gravatar: GravatarIconLibraryProtocol

  public init(session: Session, appAPIClient: AppAPIClient, logger: Logger, target: BuildTarget) {
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

    domain = DomainIconLibrary(
      cacheDirectory: cacheDirectory,
      cryptoEngine: cryptoEngine,
      appAPIClient: appAPIClient,
      logger: logger)

    gravatar = GravatarIconLibrary(
      cacheDirectory: cacheDirectory,
      cryptoEngine: cryptoEngine,
      logger: logger)
  }
}
