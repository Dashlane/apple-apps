import Foundation
import DashTypes

public protocol SessionCryptoEngine: AnyObject, CryptoEngine {
    var config: CryptoRawConfig { get }
    var displayedKeyDerivationInfo: String { get }

    func update(to config: CryptoRawConfig) throws
}

public class FakeSessionCryptoEngine: SessionCryptoEngine {

    public init() {}

    public func encrypt(data: Data) -> Data? {
        return Data(data.reversed())
    }

    public func decrypt(data: Data) -> Data? {
        return Data(data.reversed())
    }

    public var config: CryptoRawConfig {
        .init(fixedSalt: nil, parametersHeader: "")
    }

    public var displayedKeyDerivationInfo: String { "" }

    public func update(to config: CryptoRawConfig) throws {}
}
