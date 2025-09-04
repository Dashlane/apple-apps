import Combine
import CoreLocalization
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import UserTrackingFoundation

@MainActor
public class AccessControlRequestViewModifierModel: ObservableObject {

  @Published
  var userVerificationRequest: AccessControlService.UserVerificationRequest?

  public var accessControl: AccessControlHandler {
    return accessControlService
  }

  private let accessControlService: AccessControlService
  private let userSettings: UserSettings

  public init(
    accessControlService: AccessControlService,
    userSettings: UserSettings
  ) {
    self.accessControlService = accessControlService
    self.userSettings = userSettings
    self.accessControlService.userVerificationRequest = nil
    accessControlService.$userVerificationRequest.assign(to: &$userVerificationRequest)
  }

  func makeAccessViewModel(request: AccessControlService.UserVerificationRequest)
    -> AccessControlViewModel
  {
    AccessControlViewModel(
      mode: request.initialAccessMode, reason: request.reason, userSettings: userSettings
    ) { [weak self] result in
      self?.userVerificationRequest = nil
      request.completion(result)
    }
  }
}

extension AccessControlRequestViewModifierModel {
  static func mock(mode: SecureLockMode) -> AccessControlRequestViewModifierModel {
    AccessControlRequestViewModifierModel(
      accessControlService: .init(
        session: .mock, secureLockModeProvider: mode, userSettings: .mock), userSettings: .mock)
  }
}
