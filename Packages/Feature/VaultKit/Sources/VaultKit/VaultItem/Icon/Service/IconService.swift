import Foundation
import IconLibrary
import DashTypes
import CoreSession

public struct IconService: Mockable {
    public let domain: DomainIconLibraryProtocol
    public let gravatar: GravatarIconLibraryProtocol

    public init(session: Session, webservice: LegacyWebService, logger: Logger, target: BuildTarget) {
        let cacheDirectory: URL
        do {
            cacheDirectory = try session.directory.storeURL(for: .icons, in: target)
        } catch {
            logger.error("Failed to get a store url for the session, use temporary folder instead", error: error)
            cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(session.login.email)-icons")
        }

        let cryptoEngine = session.localCryptoEngine

        domain =  DomainIconLibrary(cacheDirectory: cacheDirectory,
                                    cryptoEngine: cryptoEngine,
                                    webservice: webservice,
                                    logger: logger)

        gravatar =  GravatarIconLibrary(cacheDirectory: cacheDirectory,
                                        cryptoEngine: cryptoEngine,
                                        logger: logger)
    }
}
