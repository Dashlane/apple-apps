import Foundation
import CoreSession
import DashTypes
import CoreNetworking
import SwiftTreats

class SubscriptionCodeFetcherService {

    private enum Error: Swift.Error {
        case invalidSubscriptionCodeReceived
        case failedToBuildUrl
    }

    let session: Session
    let engine: LegacyWebService

    init(session: Session, engine: LegacyWebService) {
        self.session = session
        self.engine = engine
    }

    private func fetchSubscriptionCode(callback: @escaping Completion<String>) {
        let requestParams = ["login": session.login.email]
        engine.sendRequest(
            to: "/3/premium/getSubscriptionCode",
            using: .post,
            params: requestParams,
            contentFormat: .queryString,
            needsAuthentication: true,
            responseParser: JSONResponseParser<[String: String]>()) {

                let receivedCode = $0.flatMap { (receivedDictionary) -> Result<String, Swift.Error> in
                    guard let subscriptionCode = receivedDictionary["subscriptionCode"] else {
                        return .failure(Error.failedToBuildUrl)
                    }
                    return .success(subscriptionCode)
                }
                callback(receivedCode)
        }
    }

        func fetchPrivacySettingsURL(callback: @escaping Completion<URL>) {
        fetchSubscriptionCode {
            switch $0 {
            case let .success(receivedCode):

                var components = URLComponents(url: DashlaneURLFactory.Endpoint.privacySettings.url, resolvingAgainstBaseURL: false)!
                let parameters = [
                    URLQueryItem(name: "utm_source", value: "app"),
                    URLQueryItem(name: "subCode", value: receivedCode)
                ]
                components.queryItems = parameters
                if let settingsUrl = components.url {
                    callback(.success(settingsUrl))
                } else {
                    callback(.failure(Error.invalidSubscriptionCodeReceived))
                }
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

    static var mock: SubscriptionCodeFetcherService {
        return .init(session: .mock, engine: LegacyWebServiceMock(response: ""))
    }
}
