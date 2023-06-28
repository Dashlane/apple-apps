import Foundation
import BrazeKit
import DashTypes
import CoreSettings
import CoreFeature

extension BrazeService {

        public func registerLogin(_ login: Login,
                              using userSettings: UserSettings,
                              webservice: LegacyWebService,
                              featureService: FeatureServiceProtocol) async {
        guard shouldLinkBrazeToUser(featureService: featureService) else {
            return
        }

        guard let publicUserId: String = userSettings[.publicUserId] else {
            do {
                let publicUserId = try await fetchPublicId(using: webservice)
                userSettings[.publicUserId] = publicUserId
                updateUser(login: login, publicUserId: publicUserId)
            } catch {
                            }
            return
        }
        updateUser(login: login, publicUserId: publicUserId)

    }

    private func updateUser(login: Login, publicUserId: String) {
#if DEBUG
                if login.isTest {
            braze.changeUser(userId: login.email)
        } else {
            braze.changeUser(userId: publicUserId)
        }
#else
        braze.changeUser(userId: publicUserId)
#endif
    }

        private func fetchPublicId(using webservice: LegacyWebService) async throws -> String {
        let fetchAccountInfoEndpoint = "_"

        let response: String = try await webservice.sendRequest(to: fetchAccountInfoEndpoint,
                                                                using: .post,
                                                                params: [:],
                                                                contentFormat: .queryString,
                                                                needsAuthentication: true,
                                                                responseParser: AccountInfoResponseParser())
        return response

    }
}

private struct AccountInfoResponseParser: ResponseParserProtocol {
    struct Response: Decodable {
        let content: Content
    }
    struct Content: Decodable {
        let publicUserId: String
    }
    func parse(data: Data) throws -> String {
        return try JSONDecoder().decode(Response.self, from: data).content.publicUserId
    }
}
