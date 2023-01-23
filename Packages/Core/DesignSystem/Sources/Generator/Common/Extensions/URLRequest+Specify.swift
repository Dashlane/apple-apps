import Foundation

extension URLRequest {
    enum SpecifyEndpoint {
        case colorTokens(UserInterfaceStyle)
        case iconTokens

        var url: URL {
            switch self {
            case .colorTokens(let userInterfaceStyle):
                return URL(string: "_\(userInterfaceStyle.rawValue)/design-tokens")!
            case .iconTokens:
                return URL(string: "_")!
            }
        }
    }

    static func makeSpecifyRequest(endpoint: SpecifyEndpoint, apiToken: String) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "POST"
        request.setValue(apiToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
