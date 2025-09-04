import Combine
import CoreKeychain
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import StateMachine
import SwiftTreats
import UIKit
import UserTrackingFoundation

@MainActor
public class BiometryViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {
  public let login: Login
  public let biometryType: Biometry
  public let manualLockOrigin: Bool

  var canShowPromptAfterAppBecomeActive: Bool = true

  private var cancellables = Set<AnyCancellable>()
  private let context: LoginUnlockContext
  private let completion: (Session?) -> Void

  @Published public var stateMachine: BiometryUnlockStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    login: Login,
    biometryType: Biometry,
    manualLockOrigin: Bool = false,
    context: LoginUnlockContext,
    biometryUnlockStateMachine: BiometryUnlockStateMachine,
    completion: @escaping (Session?) -> Void
  ) {
    self.login = login
    self.biometryType = biometryType
    self.manualLockOrigin = manualLockOrigin
    self.context = context
    self.completion = completion
    self.stateMachine = biometryUnlockStateMachine

    NotificationCenter
      .default
      .didBecomeActiveNotificationPublisher()?
      .sink { [weak self] _ in
        guard let self = self else {
          return
        }
        Task {
          guard !self.isPerformingEvent && self.canShowPromptAfterAppBecomeActive else {
            return
          }
          await self.validateBiometry()

        }
      }.store(in: &cancellables)

    NotificationCenter
      .default
      .publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink { [weak self] _ in
        guard let self = self else {
          return
        }
        self.canShowPromptAfterAppBecomeActive = true
      }.store(in: &cancellables)
  }

  public func willPerform(_ event: BiometryUnlockStateMachine.Event) async {
    switch event {
    case .startBiometryValidation:
      canShowPromptAfterAppBecomeActive = false
    case .cancel:
      break
    }
  }

  public func update(
    for event: BiometryUnlockStateMachine.Event, from oldState: BiometryUnlockStateMachine.State,
    to newState: BiometryUnlockStateMachine.State
  ) async {
    switch (newState, event) {
    case (.initial, _):
      break
    case (.biometryFailed, _):
      self.completion(nil)
    case (.biometryCancelled, _):
      break
    case (let .masterKeyValidationSucceeded(session), _):
      completion(session)
    case (.masterKeyValidationFailed, _):
      completion(nil)
    case (.cancelled, _):
      self.completion(nil)
    }
  }

  public func validateBiometry() async {
    if !context.localLoginContext.isExtension {
      guard UIApplication.shared.applicationState == .active else { return }
    }

    await self.perform(.startBiometryValidation)
  }
}

extension BiometryViewModel {
  static func mock(type: Biometry) -> BiometryViewModel {
    BiometryViewModel(
      login: Login(""),
      biometryType: type,
      context: LoginUnlockContext(
        verificationMode: .emailToken, origin: .login, localLoginContext: .passwordApp),
      biometryUnlockStateMachine: .mock,
      completion: { _ in })
  }
}
