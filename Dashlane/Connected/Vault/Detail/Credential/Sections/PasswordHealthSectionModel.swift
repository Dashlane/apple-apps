import Combine
import CorePasswords
import CorePersonalData
import Foundation
import VaultKit

class PasswordHealthSectionModel: DetailViewModelProtocol, SessionServicesInjecting, MockVaultConnectedInjecting {

    @Published
    var reusedCount: Int?

    @Published
    var isCompromised: Bool = false

    var passwordStrength: PasswordStrength {
        passwordEvaluator.evaluate(item.password).strength
    }

    let service: DetailService<Credential>

    private let passwordEvaluator: PasswordEvaluatorProtocol
    private let identityDashboardService: IdentityDashboardServiceProtocol

    private var subscriptions: Set<AnyCancellable> = []

    init(
        service: DetailService<Credential>,
        passwordEvaluator: PasswordEvaluatorProtocol,
        identityDashboardService: IdentityDashboardServiceProtocol
    ) {
        self.service = service
        self.passwordEvaluator = passwordEvaluator
        self.identityDashboardService = identityDashboardService

        updatePasswordHealth()
        identityDashboardService
            .notificationManager
            .publisher(for: .securityDashboardDidRefresh)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePasswordHealth()
            }
            .store(in: &subscriptions)
    }

    func updatePasswordHealth() {
        guard !item.password.isEmpty else {
            reusedCount = nil
            isCompromised = false
            return
        }

        identityDashboardService.isCompromised(item) { isCompromised in
            self.isCompromised = isCompromised
        }

        identityDashboardService.numberOfTimesPasswordIsReused(of: item) { reusedCount in
            self.reusedCount =  reusedCount > 1 ? reusedCount : nil
        }
    }
}

extension PasswordHealthSectionModel {
    static func mock(service: DetailService<Credential>) -> PasswordHealthSectionModel {
        PasswordHealthSectionModel(
            service: service,
            passwordEvaluator: PasswordEvaluator.mock,
            identityDashboardService: IdentityDashboardService.mock
        )
    }
}
