import Foundation

public enum DomainIconFormat {
  case favicon
  case iOS(large: Bool)
  case macOS
  case legacyDesktop
}

extension DomainIconFormat {
  var parameterValue: String {
    switch self {
    case .favicon: return "crawled"
    case .iOS(large: false): return "_"
    case .iOS(large: true): return "_"
    case .macOS: return "_"
    case .legacyDesktop: return "xmd"
    }
  }
}
