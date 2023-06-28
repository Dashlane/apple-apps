import Foundation

public struct CryptoRawConfig: Equatable {
    public init(fixedSalt: Data?, parametersHeader: String) {
        self.fixedSalt = fixedSalt
        self.parametersHeader = parametersHeader
    }

    public var fixedSalt: Data?
    public let parametersHeader: String
}
