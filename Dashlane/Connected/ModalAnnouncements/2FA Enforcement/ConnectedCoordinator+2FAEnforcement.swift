import Foundation
import CoreSession
import DashTypes
import Combine
import CorePremium
import CoreNetworking
import SwiftUI

extension ConnectedCoordinator {

    func configure2FAEnforcement() {

        guard sessionServices.featureService.isEnabled(.enforce2FA) else {
            return
        }

        let otp2Enabled = sessionServices.session.configuration.info.loginOTPOption != nil
        let accountAPIClient = AuthenticatedAccountAPIClient(apiClient: sessionServices.userDeviceAPIClient)
        sessionServices.teamSpacesService.$businessTeamsInfo.compactMap {
            $0.availableBusinessTeam?.space
        }
        .removeDuplicates()
        .flatMap { space -> AnyPublisher<Bool, Never> in
            let service = TwoFAEnforcementService(space: space,
                                                  accountAPIClient: accountAPIClient,
                                                  otp2Enabled: otp2Enabled)
            return service.shouldPresent2FAEnforcement
        }
        .ignoreError()
        .first(where: { $0 })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self = self, let navigationController = self.window.rootViewController else {
                assertionFailure()
                return
            }
            let model = self.sessionServices.viewModelFactory.makeTwoFactorEnforcementViewModel(accountAPIClient: AccountAPIClient(apiClient: self.sessionServices.userDeviceAPIClient)) { [weak self] in
                self?.sessionServices.appServices.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
            }
            let view = TwoFactorEnforcementView(model: model)
            navigationController.modalPresentationStyle = .fullScreen
            let viewController = UIHostingController(rootView: view)
            viewController.isModalInPresentation = true
            navigationController.present(viewController, animated: false)
        }.store(in: &subscriptions)
    }
}
