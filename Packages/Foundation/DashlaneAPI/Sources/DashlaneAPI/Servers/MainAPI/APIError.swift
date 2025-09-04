import Foundation

public struct APIError: Error, Codable, Equatable, Sendable {
  public let requestId: String
  public let errors: [Error]

  public init(requestId: String, errors: [Error]) {
    self.requestId = requestId
    self.errors = errors
  }

  public func has(_ code: Code) -> Bool {
    return errors.contains { error in
      error.code.lowercased() == code
    }
  }
}
extension APIError {
  public typealias Code = String

  public struct Error: Swift.Error, Codable, Equatable, Sendable {
    public let code: Code
    public let message: String
    public let type: String

    public init(code: String, message: String, type: String) {
      self.code = code
      self.message = message
      self.type = type
    }
  }
}

extension APIError {
  public static func mock(code: any RawRepresentable<String>) -> APIError {
    APIError(
      requestId: "id",
      errors: [
        APIError.Error(code: code.rawValue, message: "mocked message for \(code)", type: "mock")
      ])
  }
}
