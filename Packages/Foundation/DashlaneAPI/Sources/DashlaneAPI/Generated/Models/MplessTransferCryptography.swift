import Foundation

public struct MplessTransferCryptography: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case algorithm = "algorithm"
        case ellipticCurve = "ellipticCurve"
    }

    public let algorithm: MplessTransferAlgorithm

    public let ellipticCurve: MplessTransferEllipticCurve

    public init(algorithm: MplessTransferAlgorithm, ellipticCurve: MplessTransferEllipticCurve) {
        self.algorithm = algorithm
        self.ellipticCurve = ellipticCurve
    }
}
