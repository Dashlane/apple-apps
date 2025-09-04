import Foundation

public struct SSOCallbackInfos: Hashable, Sendable {
  public let ssoToken: String
  public let serviceProviderKey: String
  public let exists: Bool

  public init?(url: URL) {
    if let fragments = url.fragments(),
      let ssoToken = fragments["ssoToken"],
      let key = fragments["key"],
      let exists = fragments["exists"]?.boolValue
    {
      self.ssoToken = ssoToken
      self.serviceProviderKey = key
      self.exists = exists
    } else {
      guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
        let ssoToken = queryItems.filter({ $0.name == "ssoToken" }).first?.value,
        let serviceProviderKey = queryItems.filter({ $0.name == "key" }).first?.value
      else {
        return nil
      }
      self.ssoToken = ssoToken
      self.serviceProviderKey = serviceProviderKey
      self.exists = queryItems.filter({ $0.name == "exists" }).first?.value?.boolValue ?? false
    }
  }

  public init(ssoToken: String, serviceProviderKey: String, exists: Bool) {
    self.ssoToken = ssoToken
    self.serviceProviderKey = serviceProviderKey
    self.exists = exists
  }
}

extension URL {
  func fragments() -> [String: String]? {
    var result = [String: String]()
    guard let fragments = self.fragment?.components(separatedBy: "&") else {
      return nil
    }
    for fragment in fragments {
      let keyValueFragment = fragment.components(separatedBy: "=")
      if keyValueFragment.count == 2 {
        result[keyValueFragment[0]] = keyValueFragment[1].removingPercentEncoding
      }
    }
    return result
  }
}
