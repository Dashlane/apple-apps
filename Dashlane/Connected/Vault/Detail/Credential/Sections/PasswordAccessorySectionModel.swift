import Combine
import CorePasswords
import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI
import VaultKit

class PasswordAccessorySectionModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

        var passwordStrength: TextFieldPasswordStrengthFeedback.Strength {
        passwordEvaluator.evaluate(item.password).textFieldPasswordStrengthFeedbackStrength
    }

    let service: DetailService<Credential>

    private let passwordEvaluator: PasswordEvaluatorProtocol

    init(
        service: DetailService<Credential>,
        passwordEvaluator: PasswordEvaluatorProtocol
    ) {
        self.service = service
        self.passwordEvaluator = passwordEvaluator
    }
}

private extension PasswordStrength {
    var textFieldPasswordStrengthFeedbackStrength: TextFieldPasswordStrengthFeedback.Strength {
        switch self {
        case .tooGuessable:
            return .weakest
        case .veryGuessable:
            return .weak
        case .somewhatGuessable:
            return .acceptable
        case .safelyUnguessable:
            return .good
        case .veryUnguessable:
            return .strong
        }
    }
}

extension PasswordAccessorySectionModel {
    static func mock(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
        PasswordAccessorySectionModel(
            service: service,
            passwordEvaluator: .mock()
        )
    }
}
