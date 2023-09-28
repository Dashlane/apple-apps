import Foundation
extension AppAPIClient.Mpless {
        public struct RequestTransfer: APIRequest {
        public static let endpoint: Endpoint = "/mpless/RequestTransfer"

        public let api: AppAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestTransfer: RequestTransfer {
        RequestTransfer(api: api)
    }
}

extension AppAPIClient.Mpless.RequestTransfer {
        public struct Body: Encodable {
    }
}

extension AppAPIClient.Mpless.RequestTransfer {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case transferId = "transferId"
            case expireDateUnix = "expireDateUnix"
        }

                public let transferId: String

                public let expireDateUnix: Int

        public init(transferId: String, expireDateUnix: Int) {
            self.transferId = transferId
            self.expireDateUnix = expireDateUnix
        }
    }
}
