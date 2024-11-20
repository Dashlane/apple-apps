import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import Foundation
import LoginKit
import VaultKit

@MainActor
class AccessControlRequestViewModifierModel: ObservableObject, SessionServicesInjecting {

  @Published
  var userVerificationRequest: AccessControlService.UserVerificationRequest?

  var accessControl: AccessControlHandler {
    return accessControlService
  }

  private let accessControlService: AccessControlService
  private let accessControlViewModelFactory: AccessControlViewModel.Factory

  init(
    accessControlService: AccessControlService,
    accessControlViewModelFactory: AccessControlViewModel.Factory
  ) {
    self.accessControlService = accessControlService
    self.accessControlViewModelFactory = accessControlViewModelFactory
    accessControlService.$userVerificationRequest.assign(to: &$userVerificationRequest)
  }

  func makeAccessViewModel(request: AccessControlService.UserVerificationRequest)
    -> AccessControlViewModel
  {
    accessControlViewModelFactory.make(
      mode: request.initialAccessMode,
      reason: request.reason
    ) { [weak self] result in
      self?.userVerificationRequest = nil
      request.completion(result)
    }
  }
}

extension AccessControlRequestViewModifierModel {
  static func mock(mode: SecureLockMode) -> AccessControlRequestViewModifierModel {
    AccessControlRequestViewModifierModel(
      accessControlService: .init(session: .mock, secureLockModeProvider: mode),
      accessControlViewModelFactory: .init({ mode, reason, completion in
        AccessControlViewModel(mode: mode, reason: reason, completion: completion)
      }))
  }
}
