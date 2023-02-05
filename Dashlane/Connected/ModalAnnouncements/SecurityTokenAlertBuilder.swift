import Foundation
import DashTypes
import CoreNetworking
import UIKit

struct SecurityTokenAlertBuilder {

    struct FetchTokenError: Error {}

    let legacyWebService: LegacyWebService
    let log: Logger

    func buildAlertController(with token: String?, completion: @escaping (UIViewController) -> Void) {
        if let token = token, !token.isEmpty {
            completion(alertController(for: token))
            return
        }
        fetchSecurityToken(using: legacyWebService) { (tokenResult) in
            do {
                try completion(self.alertController(for: tokenResult.get()))
            } catch {
                self.log.error("Impossible to Fetch the Security Token (Verification Code)")
            }
        }
    }

    func parse(data: Data) throws -> String {

        guard let token = String(data: data, encoding: .utf8) else {
            throw FetchTokenError()
        }
        return token
    }

    private func alertController(for token: String) -> UIViewController {
        let title = L10n.Localizable.kwTokenPlaceholderText

        let fontSize: CGFloat = 42.0

                let attributedMessage = NSMutableAttributedString(string: "\n\n") 

        let attributedToken = NSMutableAttributedString(string: token, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize),
            .kern: 4.0
        ])
        attributedToken.addAttributes([.kern: 15.0],
                                        range: NSRange(location: token.count/2-1, length: 1))

        attributedMessage.insert(attributedToken, at: 1)

                let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)

        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: L10n.Localizable.kwButtonOk, style: .default, handler: nil))

        return alert
    }

    let fetchTokenEndpoint = "_"
    private func fetchSecurityToken(using legacyWebService: LegacyWebService, completion: @escaping (Result<String, Error>) -> Void) {
        legacyWebService.sendRequest(to: fetchTokenEndpoint,
                                     using: .post,
                                     params: [:],
                                     contentFormat: .queryString,
                                     needsAuthentication: true,
                                     responseParser: SecurityTokenFetcherResponseParser(),
                                     completion: completion)
    }
}

private struct SecurityTokenFetcherResponseParser: ResponseParserProtocol {
    struct Response: Decodable {
        let content: Content
    }
    struct Content: Decodable {
        let token: String
    }
    func parse(data: Data) throws -> String {
        return try JSONDecoder().decode(Response.self, from: data).content.token
    }
}
