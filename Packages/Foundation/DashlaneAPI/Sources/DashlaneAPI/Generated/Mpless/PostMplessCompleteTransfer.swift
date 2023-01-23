import Foundation
extension UserDeviceAPIClient.Mpless {
        public struct CompleteTransfer {
        public static let endpoint: Endpoint = "/mpless/CompleteTransfer"

        public let api: UserDeviceAPIClient

                @discardableResult
        public func callAsFunction(transferId: String, encryptedData: String, publicKey: String, cryptography: MplessTransferCryptography, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(transferId: transferId, encryptedData: encryptedData, publicKey: publicKey, cryptography: cryptography)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeTransfer: CompleteTransfer {
        CompleteTransfer(api: api)
    }
}

extension UserDeviceAPIClient.Mpless.CompleteTransfer {
        struct Body: Encodable {

                public let transferId: String

                public let encryptedData: String

                public let publicKey: String

        public let cryptography: MplessTransferCryptography
    }
}

extension UserDeviceAPIClient.Mpless.CompleteTransfer {
    public typealias Response = Empty?
}
