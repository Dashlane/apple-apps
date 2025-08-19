import Foundation

public struct LogMessage: CustomStringConvertible, Sendable {

  #if DEBUG
    nonisolated(unsafe) public static var isPrivacyEnabled: Bool = false
  #else
    public static let isPrivacyEnabled: Bool = true

  #endif

  public var description: String { storage }
  private var storage: String = ""

  public init(stringLiteral value: String) {
    self.storage = value
  }
}
extension LogMessage: ExpressibleByStringInterpolation {
  public struct StringInterpolation: StringInterpolationProtocol {
    var output = ""

    public init(literalCapacity: Int, interpolationCount: Int) {
      output.reserveCapacity(literalCapacity + interpolationCount * 10)
    }

    mutating public func appendLiteral(_ literal: String) {
      output.append(literal)
    }

    public mutating func appendInterpolation(
      _ value: @autoclosure () -> String, privacy: Privacy = .private
    ) {
      append(with: privacy) { "\"\(value())\"" }
    }

    public mutating func appendInterpolation<T: Loggable>(_ value: T, privacy: Privacy = .public) {
      append(with: privacy) { "\(value.log())" }
    }

    public mutating func appendInterpolation<T: Numeric>(_ value: T, privacy: Privacy = .public) {
      append(with: privacy) { "\(value)" }
    }

    public mutating func appendInterpolation(_ value: Bool, privacy: Privacy = .public) {
      append(with: privacy) { "\(value)" }
    }

    public mutating func appendInterpolation(_ error: Error, privacy: Privacy? = nil) {
      if let error = error as? Loggable {
        append(with: privacy ?? .public) { "\(error.log())" }
      } else if type(of: error) is NSError.Type {
        append(with: privacy ?? .public) {
          let error = error as NSError
          let message: LogMessage =
            "NSError(domain: \(error.domain, privacy: .public), code: \(error.code), userInfo: \(error.userInfo, privacy: .private))"
          return "\(message)"
        }
      } else {
        append(with: privacy ?? .private) { "\(error)" }
      }
    }

    public mutating func appendInterpolation(_ value: Any, privacy: Privacy = .private) {
      append(with: privacy) { "\(value)" }
    }

    private mutating func append(with privacy: Privacy, value: () -> String) {
      guard isPrivacyEnabled else {
        output.append("\(value())")
        return
      }
      switch privacy {
      case .public:
        output.append("\(value())")
      case .private:
        output.append("<private>")
      }
    }

  }

  public init(stringInterpolation: StringInterpolation) {
    self.storage = stringInterpolation.output
  }
}
