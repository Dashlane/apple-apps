import AuthenticatorKit
import Combine
import CoreKeychain
import CoreSession
import DashTypes
import Foundation
import LoginKit
import SwiftTreats
import UIKit

class UnlockViewModel: Identifiable, ObservableObject, AuthenticatorServicesInjecting {

  let login: Login

  @Published
  var mode: AuthenticationMode

  @Published
  var error: UnlockError?
  let keychainService: AuthenticationKeychainServiceProtocol
  let sessionContainer: SessionsContainerProtocol
  let loginOTPOption: ThirdPartyOTPOption?
  let validateMasterKey:
    (CoreKeychain.MasterKey, Login, AuthenticationMode, ThirdPartyOTPOption?) async throws ->
      PairedServicesContainer
  let completion: (PairedServicesContainer) -> Void

  @Published
  var showOnboarding: Bool

  @Published
  var show2faOnboarding: Bool

  var sharedDefault = SharedUserDefault<Bool?, String>(
    key: AuthenticatorUserDefaultKey.showPwdAppOnboarding.rawValue)
  var show2FAOnboardingSharedDefault = SharedUserDefault<Bool?, String>(
    key: AuthenticatorUserDefaultKey.show2FAOnboarding.rawValue)

  init(
    login: Login,
    authenticationMode: AuthenticationMode,
    loginOTPOption: ThirdPartyOTPOption?,
    keychainService: AuthenticationKeychainServiceProtocol,
    sessionContainer: SessionsContainerProtocol,
    validateMasterKey: @escaping (
      CoreKeychain.MasterKey, Login, AuthenticationMode, ThirdPartyOTPOption?
    ) async throws -> PairedServicesContainer,
    completion: @escaping (PairedServicesContainer) -> Void
  ) {
    self.login = login
    self.mode = authenticationMode
    self.keychainService = keychainService
    self.sessionContainer = sessionContainer
    self.completion = completion
    self.loginOTPOption = loginOTPOption
    self.validateMasterKey = validateMasterKey
    showOnboarding = sharedDefault.wrappedValue == true
    show2faOnboarding = show2FAOnboardingSharedDefault.wrappedValue == true
    RootviewModel.mode.compactMap { $0 }.assign(to: &$mode)
  }

  func validateMasterKey(_ masterKey: CoreKeychain.MasterKey) async throws
    -> PairedServicesContainer
  {
    return try await self.validateMasterKey(masterKey, login, mode, loginOTPOption)
  }

  @MainActor
  func makeBiometryUnlockViewModel(
    biometryType: Biometry, completion: @escaping (PairedServicesContainer) -> Void
  ) -> BiometryUnlockViewModel {
    return BiometryUnlockViewModel(
      login: login,
      biometryType: biometryType,
      keychainService: keychainService,
      validateMasterKey: validateMasterKey,
      completion: completion)
  }

  @MainActor
  func makePinUnlockViewModel(
    pin: String, pinCodeAttempts: PinCodeAttempts, masterKey: CoreKeychain.MasterKey,
    completion: @escaping (PairedServicesContainer) -> Void
  ) -> PinUnlockViewModel {
    return PinUnlockViewModel(
      login: login,
      pin: pin,
      pinCodeAttempts: pinCodeAttempts,
      masterKey: masterKey,
      validateMasterKey: validateMasterKey,
      completion: completion)
  }

  @MainActor
  func makeBiometryAndPinUnlockViewModel(
    pin: String, pinCodeAttempts: PinCodeAttempts, masterKey: CoreKeychain.MasterKey,
    biometryType: Biometry, completion: @escaping (PairedServicesContainer) -> Void
  ) -> BiometryAndPinUnlockViewModel {
    return BiometryAndPinUnlockViewModel(
      login: login,
      pin: pin,
      pinCodeAttempts: pinCodeAttempts,
      masterKey: masterKey,
      biometryType: biometryType,
      validateMasterKey: validateMasterKey,
      completion: completion)
  }

  func didFinishOnboarding() {
    sharedDefault.wrappedValue = false
    showOnboarding = false
  }

  func didFinish2FAOnboarding() {
    show2FAOnboardingSharedDefault.wrappedValue = false
    show2faOnboarding = false
    UIApplication.shared.open(.passwordApp)
  }
}

enum UnlockError {
  case wrongPin
}

extension CoreKeychain.MasterKey {
  func coreSessionMasterKey(withServerKey serverKey: String?) -> CoreSession.MasterKey {
    switch self {
    case .masterPassword(let password):
      return .masterPassword(password, serverKey: serverKey)
    case .key(let data):
      return .ssoKey(data)
    }
  }
}
