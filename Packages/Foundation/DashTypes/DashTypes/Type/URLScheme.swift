import Foundation

public enum URLScheme: String {
    case dashlane = "dashlane:///"
    case authenticator = "dashlane-authenticator:///"
}

public extension URLScheme {
    var url: URL {
        URL(string: self.rawValue)!
    }
}
