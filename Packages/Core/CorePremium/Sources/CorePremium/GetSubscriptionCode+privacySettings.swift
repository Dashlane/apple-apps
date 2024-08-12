import DashTypes
import DashlaneAPI
import Foundation

extension UserDeviceAPIClient.Premium {
  public enum PrivacySettingsError: Swift.Error {
    case invalidSubscriptionCodeReceived
  }

  public func fetchPrivacySettingsURL() async throws -> URL {
    let code = try await getSubscriptionCode().subscriptionCode

    var components = URLComponents(
      url: DashlaneURLFactory.Endpoint.privacySettings.url, resolvingAgainstBaseURL: false)!
    let parameters = [
      URLQueryItem(name: "utm_source", value: "app"),
      URLQueryItem(name: "subCode", value: code),
    ]
    components.queryItems = parameters
    guard let settingsUrl = components.url else {
      throw PrivacySettingsError.invalidSubscriptionCodeReceived
    }

    return settingsUrl
  }
}
