import Foundation

extension URLRequest {
  enum SpecifyEndpoint {
    case colorTokens(UserInterfaceStyle)
    case iconTokens
    case typographyTokens

    var url: URL {
      URL.specifyRepository(named: repositoryName)
    }

    private var repositoryName: String {
      switch self {
      case .colorTokens(let userInterfaceStyle):
        return "colorset-product-\(userInterfaceStyle.rawValue)"
      case .iconTokens:
        return "iconset-universal"
      case .typographyTokens:
        return "typeset-apple"
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
