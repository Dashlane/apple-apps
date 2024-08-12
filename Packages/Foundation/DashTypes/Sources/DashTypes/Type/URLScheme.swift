import Foundation

public enum URLScheme: String {
  case dashlane = "dashlane:///"
  case authenticator = "dashlane-authenticator:///"
}

extension URLScheme {
  public var url: URL {
    URL(string: self.rawValue)!
  }
}
