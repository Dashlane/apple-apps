import Foundation

public enum URLScheme: String {
  case dashlane = "dashlane:///"
}

extension URLScheme {
  public var url: URL {
    URL(string: self.rawValue)!
  }
}
