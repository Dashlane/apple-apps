import Foundation

struct AppEnvironment {
  private struct Keys {
    static let debugLogPrefix = "DEBUG_LOG_"
  }

  static func debugLogTags() -> [String] {
    let debugKeys = ProcessInfo().environment.keys.filter { $0.hasPrefix(Keys.debugLogPrefix) }

    return debugKeys.compactMap { $0.split(separator: "_").last?.lowercased() }
  }
}
