import Foundation
import DashTypes

public struct GetDownloadLinkService {

    private enum Endpoint: String {
        case commit = "_"
    }

    private enum Key: String {
        case key
        case secureFileInfoId
    }

    private let webservice: ProgressableNetworkingEngine

    public init(webservice: ProgressableNetworkingEngine) {
        self.webservice = webservice
    }

                                @discardableResult public func getLink(key: String, secureFileInfoId: String) async throws -> DownloadLink {
        let params: [String: Encodable] = [
            Key.secureFileInfoId.rawValue: secureFileInfoId,
            Key.key.rawValue: key
        ]
        let resource = Resource(endpoint: Endpoint.commit.rawValue,
                                method: .post,
                                params: params,
                                contentFormat: ContentFormat.queryString,
                                needsAuthentication: true,
                                parser: GetDownloadLinkServiceParser())

        return try await resource.load(on: webservice)
    }
}

struct GetDownloadLinkServiceParser: ResponseParserProtocol {

    func parse(data: Data) throws -> DownloadLink {
        do {
            let response = try JSONDecoder().decode(Response<DownloadLink>.self, from: data)
            return response.content
        } catch {
            if let error = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw error
            }
            throw error
        }
    }
}
