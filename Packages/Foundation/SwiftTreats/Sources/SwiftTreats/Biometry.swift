import Foundation
import LocalAuthentication

public enum Biometry: String {
    case touchId = "Touch ID"
    case faceId = "Face ID"

    public var displayableName: String {
        return rawValue
    }
}

public extension Biometry {
    static func authenticate(using context: LAContext = LAContext(), reasonTitle: String, fallbackTitle: String) async throws {
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error as Error? {
                throw error
            } else {
                throw LAError(.biometryNotAvailable)
            }
        }
        context.localizedFallbackTitle = fallbackTitle
        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonTitle)
    }
}
