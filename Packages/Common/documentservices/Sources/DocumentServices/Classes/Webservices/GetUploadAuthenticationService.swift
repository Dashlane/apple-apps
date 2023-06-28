import Foundation
import DashTypes
import CoreNetworking

public struct GetUploadLinkServiceError: Error {
    public let uploadedFileSize: UInt64
    public let serverError: ServerError
}

public struct GetUploadAuthenticationService {

    private enum Endpoint: String {
        case getUploadLink = "_"
    }

    private enum Key: String {
        case contentLength
        case secureFileInfoId
    }

    private let webservice: ProgressableNetworkingEngine

    public init(webservice: ProgressableNetworkingEngine) {
        self.webservice = webservice
    }

                                @discardableResult
    public func getLink(size: UInt64, secureFileInfoId: String) async throws -> UploadAuthentication {
        let params: [String: Encodable] = [
            Key.contentLength.rawValue: size,
            Key.secureFileInfoId.rawValue: secureFileInfoId
        ]

        let resource = Resource(endpoint: Endpoint.getUploadLink.rawValue,
                                method: .post,
                                params: params,
                                contentFormat: ContentFormat.queryString,
                                needsAuthentication: true,
                                parser: GetUploadAuthenticationServiceParser(size: size))

        return try await resource.load(on: webservice)
    }
}

struct GetUploadAuthenticationServiceParser: ResponseParserProtocol {

    let size: UInt64

    init(size: UInt64) {
        self.size = size
    }

    func parse(data: Data) throws -> UploadAuthentication {
        do {
            let response = try JSONDecoder().decode(Response<UploadAuthentication>.self, from: data)
            return response.content
        } catch {
            if let error = try? JSONDecoder().decode(ServerError.self, from: data) {
                if error.isFileTooLarge {
                    throw GetUploadLinkServiceError(uploadedFileSize: size, serverError: error)
                }
                throw error
            }
            throw error
        }
    }
}

extension GetUploadLinkServiceError {
    public var isFileTooLarge: Bool {
        return self.serverError.isFileTooLarge
    }
}
