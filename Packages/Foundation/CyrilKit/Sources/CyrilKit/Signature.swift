import Foundation

public struct Signature {
    public let data: Data

    public init(_ data: Data) {
        self.data = data
    }

    public init?(base64Encoded base64String: String) {
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        self.init(data)
    }
}

public typealias Message = Data

public protocol MessageSigner {
    func sign(_ data: Message) throws -> Signature
}

public protocol SignatureVerifier {
    func verify(_ data: Message, with signature: Signature) -> Bool
}
