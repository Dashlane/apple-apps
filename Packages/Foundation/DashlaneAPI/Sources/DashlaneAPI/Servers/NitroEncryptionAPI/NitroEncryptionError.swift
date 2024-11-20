import Foundation

public struct NitroEncryptionError: Error, Codable, Equatable, Sendable {
  public typealias Code = String
  public let requestId: String
  public let errors: [APIError.Error]

  public init(requestId: String, errors: [APIError.Error]) {
    self.requestId = requestId
    self.errors = errors
  }

  public func has(_ code: Code) -> Bool {
    return errors.contains { error in
      error.code.lowercased() == code
    }
  }
}

extension NitroEncryptionError {
  public static func mock(code: any RawRepresentable<String>) -> NitroEncryptionError {
    NitroEncryptionError(
      requestId: "id",
      errors: [
        APIError.Error(code: code.rawValue, message: "moked message for \(code)", type: "mock")
      ])
  }
}
