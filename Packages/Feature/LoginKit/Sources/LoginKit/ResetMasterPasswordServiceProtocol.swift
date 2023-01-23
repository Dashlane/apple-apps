import Foundation
import Combine

public protocol ResetMasterPasswordServiceProtocol {
    var isActive: Bool { get }
    var needsReactivation: Bool { get }

    func activate(using masterPassword: String) throws -> Void
    func deactivate() throws -> Void
    func activationStatusPublisher() -> AnyPublisher<Bool, Never>

    func storedMasterPassword() throws -> String
    func update(masterPassword: String) throws -> Void
}
