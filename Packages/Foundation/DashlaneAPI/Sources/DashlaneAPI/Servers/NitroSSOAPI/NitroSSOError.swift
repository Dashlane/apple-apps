import Foundation

struct NitroSSOError: Error, Codable, Equatable, Sendable {
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

extension NitroSSOError {
  public typealias Code = String

  public struct Error: Swift.Error, Codable, Equatable, Sendable {
    public let code: Code
    public let status: String
    public let message: String

    public init(code: String, status: String, message: String) {
      self.code = code
      self.status = status
      self.message = message
    }
  }
}
