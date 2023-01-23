import Foundation

public struct MplessTransferCryptography: Codable, Equatable {

    public let algorithm: MplessTransferAlgorithm

    public let ellipticCurve: MplessTransferEllipticCurve

    public init(algorithm: MplessTransferAlgorithm, ellipticCurve: MplessTransferEllipticCurve) {
        self.algorithm = algorithm
        self.ellipticCurve = ellipticCurve
    }
}
