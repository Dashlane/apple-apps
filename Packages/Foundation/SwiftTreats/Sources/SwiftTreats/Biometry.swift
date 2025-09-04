import Foundation
import LocalAuthentication

public enum Biometry: String, Sendable {
  case touchId = "Touch ID"
  case faceId = "Face ID"
  case opticId = "Optic ID"

  public var displayableName: String {
    return rawValue
  }
}

public protocol BiometryValidatorProtocol: Sendable {
  func authenticate(using context: LAContext, reasonTitle: String, fallbackTitle: String)
    async throws
}

public struct BiometryValidator: BiometryValidatorProtocol {
  public init() {}

  public func authenticate(
    using context: LAContext = LAContext(), reasonTitle: String, fallbackTitle: String
  ) async throws {
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      if let error = error as Error? {
        throw error
      } else {
        throw LAError(.biometryNotAvailable)
      }
    }
    context.localizedFallbackTitle = fallbackTitle
    try await context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonTitle)
  }
}

public final class BiometryValidatorMock: BiometryValidatorProtocol, Sendable {
  public init() {}

  public func authenticate(using context: LAContext, reasonTitle: String, fallbackTitle: String)
    async throws
  {
  }
}
