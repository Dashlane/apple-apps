import Foundation
import DashTypes

public class Session: Hashable {
    public let configuration: SessionConfiguration
    public let directory: SessionDirectory

    public let localKey: Data

        public internal(set) var cryptoEngine: SessionCryptoEngine

        public internal(set) var localCryptoEngine: CryptoEngine

        public internal(set) var remoteCryptoEngine: CryptoEngine

    public var login: Login {
        return configuration.login
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(login)
    }

    public init(configuration: SessionConfiguration,
                localKey: Data,
                directory: SessionDirectory,
                cryptoEngine: SessionCryptoEngine,
                localCryptoEngine: CryptoEngine,
                remoteCryptoEngine: CryptoEngine) {
        self.configuration = configuration
        self.localKey = localKey
        self.directory = directory
        self.cryptoEngine = cryptoEngine
        self.localCryptoEngine = localCryptoEngine
        self.remoteCryptoEngine = remoteCryptoEngine
    }

    public static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.configuration == rhs.configuration
    }

}

public extension Session {
    static var mock: Session {
        .init(configuration: SessionConfiguration.mock,
              localKey: Data(),
              directory: .init(url: URL(fileURLWithPath: "")),
              cryptoEngine: FakeSessionCryptoEngine(),
              localCryptoEngine: FakeSessionCryptoEngine(),
              remoteCryptoEngine: FakeSessionCryptoEngine())
    }
}
