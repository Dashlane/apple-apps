import Combine
import CorePersonalData
import CoreSettings
import CoreUserTracking
import DashTypes
import Foundation
import SwiftUI
import TOTPGenerator
import VaultKit

class CredentialMainSectionModel: DetailViewModelProtocol, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  @Published
  var totpCode: String = ""

  @Published
  var totpProgress: CGFloat = 0

  private let totpPeriod: CGFloat
  private var totpTimer: Timer?

  @Binding
  var isAutoFillDemoModalShown: Bool

  @Binding
  var isAdd2FAFlowPresented: Bool

  var emailsSuggestions: [String] {
    vaultItemsStore.emails.map(\.value).sorted()
  }

  let passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory

  let service: DetailService<Credential>

  private var sharingService: SharedVaultHandling {
    service.sharingService
  }

  private var vaultItemsStore: VaultItemsStore {
    service.vaultItemsStore
  }

  init(
    service: DetailService<Credential>,
    isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>,
    passwordAccessorySectionModelFactory: PasswordAccessorySectionModel.Factory
  ) {
    self.service = service
    self._isAutoFillDemoModalShown = isAutoFillDemoModalShown
    self._isAdd2FAFlowPresented = isAdd2FAFlowPresented
    self.passwordAccessorySectionModelFactory = passwordAccessorySectionModelFactory

    switch service.item.otpConfiguration?.type {
    case .totp(let period):
      totpPeriod = period
    default:
      totpPeriod = 30
    }
  }

  func startTotpUpdates() {
    guard item.otpConfiguration != nil else {
      return
    }

    totpTimer?.invalidate()

    totpUpdate()

    totpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      DispatchQueue.main.async {
        self.totpUpdate()
      }
    }
    totpTimer?.tolerance = 0.2
  }

  private func totpUpdate() {
    guard let info = item.otpConfiguration else {
      totpTimer?.invalidate()
      return
    }
    let remainingTime = TOTPGenerator.timeRemaining(in: totpPeriod)
    self.totpProgress = CGFloat((totpPeriod - remainingTime) / totpPeriod)
    self.totpCode = TOTPGenerator.generate(
      with: info.type, for: Date(), digits: info.digits, algorithm: info.algorithm,
      secret: info.secret)
  }

}

extension Credential {
  var otpConfiguration: OTPConfiguration? {
    guard let otpURL = otpURL else {
      return nil
    }
    return try? OTPConfiguration(otpURL: otpURL)
  }
}

extension CredentialMainSectionModel {
  static func mock(
    service: DetailService<Credential>,
    isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>
  ) -> CredentialMainSectionModel {
    CredentialMainSectionModel(
      service: service,
      isAutoFillDemoModalShown: isAutoFillDemoModalShown,
      isAdd2FAFlowPresented: isAdd2FAFlowPresented,
      passwordAccessorySectionModelFactory: .init { .mock(service: $0) }
    )
  }
}
