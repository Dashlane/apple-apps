import Combine
import CorePremium
import CoreTypes
import Foundation
import SwiftUI

final class RememberMasterPasswordToggleViewModel: ObservableObject, SessionServicesInjecting {
  typealias Confirmed = Bool

  enum Alert {
    case keychainStoredMasterPassword(completion: (Confirmed) -> Void)
  }

  enum Action {
    case disableBiometricsAndPincode
  }

  let lockService: LockServiceProtocol
  let userSpacesService: UserSpacesService

  @Published
  var isToggleOn: Bool

  @Published
  var activeAlert: Alert?

  private let actionHandler: (Action) -> Void

  init(
    lockService: LockServiceProtocol,
    userSpacesService: UserSpacesService,
    actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void
  ) {
    self.lockService = lockService
    self.userSpacesService = userSpacesService
    self.actionHandler = actionHandler

    isToggleOn = lockService.secureLockConfigurator.isRememberMasterPasswordActivated
  }

  func useRememberMasterPassword(_ shouldEnable: Bool) {
    guard
      shouldEnable && !isRememberMasterPasswordActivated
        || !shouldEnable && isRememberMasterPasswordActivated
    else { return }
    guard lockService.secureLockConfigurator.canActivateRememberMasterPassword else { return }

    guard shouldEnable else {
      do {
        try disableRememberMasterPassword()
      } catch {
        assertionFailure(
          "Couldn't disable remember master password. [\(error.localizedDescription)]")
      }
      return
    }

    activeAlert = .keychainStoredMasterPassword(completion: { [weak self] confirmed in
      guard let self = self else { return }
      guard confirmed else {
        self.toggleWithAnimation(false)
        return
      }

      self.actionHandler(.disableBiometricsAndPincode)

      do {
        try self.enableRememberMasterPassword()
      } catch {
        assertionFailure(
          "Couldn't enable remember master password. [\(error.localizedDescription)]")
      }
    })
  }

  func disableRememberMasterPassword() throws {
    try lockService.secureLockConfigurator.disableRememberMasterPassword()
    toggleWithAnimation(false)
  }

  func enableRememberMasterPassword() throws {
    try lockService.secureLockConfigurator.enableRememberMasterPassword()
    toggleWithAnimation(true)
  }

  private func toggleWithAnimation(_ on: Bool) {
    withAnimation { isToggleOn = on }
  }
  private var isRememberMasterPasswordActivated: Bool {
    lockService.secureLockConfigurator.isRememberMasterPasswordActivated
  }
}

extension RememberMasterPasswordToggleViewModel {

  static var mock: RememberMasterPasswordToggleViewModel {
    RememberMasterPasswordToggleViewModel(
      lockService: LockServiceMock(),
      userSpacesService: .mock(),
      actionHandler: { _ in })
  }
}
