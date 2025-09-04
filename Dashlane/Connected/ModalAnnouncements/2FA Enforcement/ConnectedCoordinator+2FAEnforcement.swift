import Combine
import CoreNetworking
import CorePremium
import CoreSession
import CoreTypes
import Foundation
import SwiftUI

extension ConnectedCoordinator {

  func configure2FAEnforcement() {

    guard sessionServices.session.configuration.info.accountType == .masterPassword else {
      return
    }

    let otp2Enabled = sessionServices.session.configuration.info.loginOTPOption != nil
    sessionServices.premiumStatusProvider.statusPublisher.compactMap { status in
      guard let b2bStatus = status.b2bStatus, b2bStatus.statusCode == .inTeam else {
        return nil
      }
      return b2bStatus.currentTeam
    }
    .flatMap { [sessionServices] (team: CurrentTeam) -> AnyPublisher<Bool, Never> in
      let service = TwoFAEnforcementService(
        team: team,
        userApiClient: sessionServices.userDeviceAPIClient,
        otp2Enabled: otp2Enabled
      )
      return service.shouldPresent2FAEnforcement
    }
    .first(where: { $0 })
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
      guard let self = self, let navigationController = self.window.rootViewController else {
        assertionFailure()
        return
      }
      let model = self.sessionServices.viewModelFactory.makeTwoFactorEnforcementViewModel {
        [weak self] in
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
