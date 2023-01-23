import Foundation
import CoreSync
import Combine
import DashTypes
import IconLibrary
import VaultKit
import CoreSession
import DashlaneAppKit

extension DomainIconLibrary {
        init(webService: LegacyWebService, logger: Logger) {
        self.init(cacheDirectory: ApplicationGroup.authenticatorStandaloneStoreURL.appendingPathComponent("icons"),
                  cryptoEngine: DomainIconCryptoEngine(),
                  webservice: webService,
                  logger: logger)
    }
    
        init(webService: LegacyWebService, session: Session, logger: Logger) {
        let cacheDirectory: URL
        do {
            cacheDirectory = try session.directory.storeURL(for: .icons, in: .authenticator)
        } catch {
            logger.error("Failed to get a store url for the session, use temporary folder instead", error: error)
            cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(session.login.email)-authenticator-icons")
        }
        self.init(cacheDirectory: cacheDirectory,
                  cryptoEngine: session.localCryptoEngine,
                  webservice: webService,
                  logger: logger)
    }
    
}

struct DomainIconCryptoEngine: CryptoEngine {
    func decrypt(data: Data) -> Data? {
        return data
    }

    func encrypt(data: Data) -> Data? {
        return data
    }
}
