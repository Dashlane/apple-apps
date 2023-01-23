import Foundation
extension AppAPIClient.Mpless {
        public struct StartTransfer {
        public static let endpoint: Endpoint = "/mpless/StartTransfer"

        public let api: AppAPIClient

                public func callAsFunction(transferId: String, cryptography: MplessTransferCryptography, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(transferId: transferId, cryptography: cryptography)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var startTransfer: StartTransfer {
        StartTransfer(api: api)
    }
}

extension AppAPIClient.Mpless.StartTransfer {
        struct Body: Encodable {

                public let transferId: String

        public let cryptography: MplessTransferCryptography
    }
}

extension AppAPIClient.Mpless.StartTransfer {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let encryptedData: String

                public let publicKey: String

        public init(encryptedData: String, publicKey: String) {
            self.encryptedData = encryptedData
            self.publicKey = publicKey
        }
    }
}
