import Combine
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import SwiftUI
import TOTPGenerator
import UIKit

@MainActor
class TwoFASettingsViewModel: SessionServicesInjecting, ObservableObject {
  enum Status {
    case loading
    case loaded
    case error
    case noInternet
  }

  @Published
  var selectedCountry: CountryCodeNamePair?

  @Published
  var status: Status = .loaded

  @Published
  var isTFAEnabled: Bool = false

  @Published
  var sheet: TwoFASettingsView.NextPossibleActionSheet?

  @Published
  var showDeactivationAlert = false

  var currentOTP: Dashlane2FAType? {
    didSet {
      if currentOTP == nil {
        isTFAEnabled = false
      } else {
        isTFAEnabled = true
      }
    }
  }

  let login: Login
  let userAPIClient: UserDeviceAPIClient
  let logger: Logger
  let isTwoFAEnforced: Bool

  let sessionLifeCycleHandler: SessionLifeCycleHandler?

  let twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory
  let twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory
  let reachability: NetworkReachabilityProtocol
  private var subcription: AnyCancellable?

  var twoFASettingsMessage: String {
    if isTwoFAEnforced {
      if currentOTP == .otp2 {
        return L10n.Localizable.twofaSettingsEnforcedMessageOtp2
      } else {
        return L10n.Localizable.twofaSettingsEnforcedMessageOtp1
      }
    }
    return L10n.Localizable.twofaSettingsMessage
  }

  init(
    login: Login,
    loginOTPOption: ThirdPartyOTPOption?,
    userAPIClient: UserDeviceAPIClient,
    logger: Logger,
    isTwoFAEnforced: Bool,
    reachability: NetworkReachabilityProtocol,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory,
    twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory
  ) {
    self.login = login
    self.userAPIClient = userAPIClient
    self.currentOTP = loginOTPOption != nil ? .otp2 : nil
    self.isTFAEnabled = currentOTP == nil ? false : true
    self.logger = logger
    self.isTwoFAEnforced = isTwoFAEnforced
    self.sessionLifeCycleHandler = sessionLifeCycleHandler
    self.twoFADeactivationViewModelFactory = twoFADeactivationViewModelFactory
    self.twoFactorEnforcementViewModelFactory = twoFactorEnforcementViewModelFactory
    self.reachability = reachability
    Task {
      await fetch()
    }
  }

  func fetch() async {
    status = .loading
    do {
      let response = try await userAPIClient.authentication.get2FAStatus()
      self.currentOTP = response.type.twoFAType
      self.status = .loaded
    } catch {
      status = self.reachability.isConnected ? .error : .noInternet
      fetchWhenInternetConnectionRestores()
    }
  }

  private func fetchWhenInternetConnectionRestores() {
    guard !self.reachability.isConnected else {
      return
    }

    subcription = reachability.isConnectedPublisher
      .receive(on: DispatchQueue.main)
      .filter { $0 }.sink { [weak self] _ in
        Task {
          await self?.fetch()
        }
      }
  }

  func updateState() async {
    await fetch()
    if !isTFAEnabled && isTwoFAEnforced {
      sheet = .twoFAEnforced
    }
  }

  func makeTwoFADeactivationViewModel(currentOtp: Dashlane2FAType) -> TwoFADeactivationViewModel {
    return twoFADeactivationViewModelFactory.make(isTwoFAEnforced: isTwoFAEnforced)
  }

  func makeTwoFactorEnforcementViewModel() -> TwoFactorEnforcementViewModel {
    twoFactorEnforcementViewModelFactory.make { [weak self] in
      self?.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
    }
  }

  func update() {
    if let currentOTP = currentOTP, isTwoFAEnforced {
      sheet = .deactivation(currentOTP)
    } else if currentOTP != nil {
      showDeactivationAlert = true
    }
  }

  func checkTFA() -> Binding<Bool> {
    return Binding {
      self.isTFAEnabled
    } set: { value in
      if value {
        assertionFailure("The toggle can't be turned on via UI.")
      } else {
        self.update()
      }
    }
  }
}

extension TwoFASettingsViewModel {
  static var mock: TwoFASettingsViewModel {

    return TwoFASettingsViewModel(
      login: Login("_"),
      loginOTPOption: nil,
      userAPIClient: .fake,
      logger: .mock,
      isTwoFAEnforced: true,
      reachability: .mock(),
      sessionLifeCycleHandler: nil,
      twoFADeactivationViewModelFactory: .init({ _ in .mock() }),
      twoFactorEnforcementViewModelFactory: .init({ _ in .mock }))
  }
}
