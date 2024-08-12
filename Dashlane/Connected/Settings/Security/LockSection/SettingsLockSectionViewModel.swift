import DashTypes
import Foundation
import SwiftUI
import VaultKit

final class SettingsLockSectionViewModel: ObservableObject, SessionServicesInjecting {

  enum AutoLockOption: TimeInterval, CaseIterable, Identifiable {
    case never = 0
    case tenSeconds = 10
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300
    case tenMinutes = 600

    var id: AutoLockOption { self }
  }

  @Published
  var autoLockSelectedOption: AutoLockOption

  @Published
  var isLockOnExitEnabled: Bool

  @Published
  var showBusinessEnforcedAlert = false

  private let lockService: LockServiceProtocol
  private let accessControl: AccessControlProtocol

  init(lockService: LockServiceProtocol, accessControl: AccessControlProtocol) {
    self.lockService = lockService
    self.accessControl = accessControl

    autoLockSelectedOption =
      AutoLockOption(rawValue: lockService.locker.screenLocker?.setting.lockTimeInterval ?? 0)
      ?? .never
    isLockOnExitEnabled = lockService.locker.screenLocker?.lockOnExitState != .disabled
  }

  func updateAutoLockTimeout() {
    lockService.locker.screenLocker?.setting.lockTimeInterval = autoLockSelectedOption.rawValue
  }

  func updateLockOnExitStatus() {
    let isBusinessEnforced = lockService.locker.screenLocker?.lockOnExitState == .businessEnforced

    if !isLockOnExitEnabled, isBusinessEnforced {
      showBusinessEnforcedAlert = true
      return
    }

    if isLockOnExitEnabled {
      lockService.locker.screenLocker?.setting.lockOnExit = true
    } else {
      accessControl.requestAccess(forReason: .lockOnExit) { [weak self] accessGranted in
        guard accessGranted else {
          withAnimation { self?.isLockOnExitEnabled = true }
          return
        }
        self?.lockService.locker.screenLocker?.setting.lockOnExit = false
      }
    }
  }
}

extension SettingsLockSectionViewModel {

  static var mock: SettingsLockSectionViewModel {
    SettingsLockSectionViewModel(
      lockService: LockServiceMock(), accessControl: FakeAccessControl(accept: true))
  }
}
