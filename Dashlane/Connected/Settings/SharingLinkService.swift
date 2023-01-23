import Foundation
import Combine
import DashTypes
import DashlaneAppKit

struct SharingLinkService: Mockable {

    private struct SharingIdResult: Decodable {
        let result: String
        let sharingId: String
    }

    private struct SharingIdResponseParser: ResponseParserProtocol {
        func parse(data: Data) throws -> String? {
            let response = try JSONDecoder().decode(SharingIdResult.self, from: data)
            return response.sharingId
        }
    }

    let networkEngine: LegacyWebService

    public func getSharingLink(forEmail email: String, completion: @escaping (String?) -> Void) {
        networkEngine.sendRequest(
            to: "_",
            using: .post,
            params: ["login": email],
            contentFormat: .queryString,
            needsAuthentication: true,
            responseParser: SharingIdResponseParser()) { result in
                completion(try? result.get())
            }
    }
}

private struct SharingLinkServiceMock: SharingLinkServiceProtocol {
    func getSharingLink(forEmail email: String, completion: @escaping (String?) -> Void) {
        completion("_")
    }
}

extension SharingLinkService {
    static var mock: SharingLinkServiceProtocol {
        SharingLinkServiceMock()
    }
}
