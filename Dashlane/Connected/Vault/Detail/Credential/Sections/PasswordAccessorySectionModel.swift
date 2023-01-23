import Combine
import CorePasswords
import CorePersonalData
import Foundation
import SwiftUI

class PasswordAccessorySectionModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    var passwordStrength: PasswordStrength {
        passwordEvaluator.evaluate(item.password).strength
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

extension PasswordAccessorySectionModel {
    static func mock(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
        PasswordAccessorySectionModel(
            service: service,
            passwordEvaluator: PasswordEvaluator.mock
        )
    }
}
