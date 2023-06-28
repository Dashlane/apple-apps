import Foundation
import DashTypes

public struct DeleteFileService {

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

                                public func delete(key: String, secureFileInfoId: String) async throws -> Quota {
        let params: [String: Encodable] = [
            Key.secureFileInfoId.rawValue: secureFileInfoId,
            Key.key.rawValue: key
            ]
        let resource = Resource(endpoint: Endpoint.commit.rawValue,
                                method: .post,
                                params: params,
                                contentFormat: ContentFormat.queryString,
                                needsAuthentication: true,
                                parser: DeleteFileServiceParser())

        return try await resource.load(on: webservice)
    }
}

struct DeleteFileServiceParser: ResponseParserProtocol {

    func parse(data: Data) throws -> Quota {
        do {
            let response = try JSONDecoder().decode(Response<Quota>.self, from: data)
            return response.content
        } catch {
            if let error = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw error
            }
            throw error
        }
    }
}
