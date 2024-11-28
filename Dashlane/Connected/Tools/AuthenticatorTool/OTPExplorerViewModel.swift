import AuthenticatorKit
import Combine
import CoreFeature
import CorePersonalData
import DashTypes
import Foundation
import VaultKit

class OTPExplorerViewModel: ObservableObject, SessionServicesInjecting {

  enum Action {
    case setupAuthentication(Credential?)
    case addNewLogin
  }

  private let vaultItemsStore: VaultItemsStore
  private let deeplinkingService: DeepLinkingServiceProtocol
  private let rowModelFactory: ActionableVaultItemRowViewModel.Factory
  private let actionHandler: (Action) -> Void

  @Published
  var otpNotConfiguredCredentials: [Credential] = []

  @Published
  var otpSupportedCredentials: [Credential] = []

  @Published
  private var vaultState: VaultState = .default

  init(
    vaultItemsStore: VaultItemsStore,
    vaultStateService: VaultStateServiceProtocol,
    deeplinkingService: DeepLinkingServiceProtocol,
    otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
    rowModelFactory: ActionableVaultItemRowViewModel.Factory,
    actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
  ) {
    self.vaultItemsStore = vaultItemsStore
    self.deeplinkingService = deeplinkingService
    self.rowModelFactory = rowModelFactory
    self.actionHandler = actionHandler

    vaultItemsStore.$credentials.map {
      $0.filter {
        guard let domain = $0.url?.domain?.name else {
          return false
        }
        return otpSupportedDomainsRepository.isOTPSupported(domain: domain)
      }
    }.assign(to: &$otpSupportedCredentials)

    vaultItemsStore.$credentials.map {
      $0.filter {
        guard let domain = $0.url?.domain?.name else {
          return false
        }

        return otpSupportedDomainsRepository.isOTPSupported(domain: domain) && $0.otpURL == nil
      }
    }.assign(to: &$otpNotConfiguredCredentials)

    vaultStateService
      .vaultStatePublisher()
      .assign(to: &$vaultState)
  }

  func startAddCredentialFlow() {
    guard vaultState != .frozen else {
      deeplinkingService.handleLink(
        .premium(.planPurchase(initialView: .paywall(trigger: .frozenAccount))))
      return
    }
    actionHandler(.addNewLogin)
  }

  func startSetupOTPFlow(for credential: Credential? = nil) {
    actionHandler(.setupAuthentication(credential))
  }

  func makeRowViewModel(credential: Credential) -> ActionableVaultItemRowViewModel {
    rowModelFactory.make(
      item: credential,
      isSuggested: false,
      origin: .vault)
  }

}

extension OTPExplorerViewModel {
  static var mock: OTPExplorerViewModel {
    return OTPExplorerViewModel(
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      vaultStateService: .mock,
      deeplinkingService: DeepLinkingService.fakeService,
      otpSupportedDomainsRepository: OTPSupportedDomainsRepository(),
      rowModelFactory: .init { item, _, _ in .mock(item: item) },
      actionHandler: { _ in }
    )
  }
}
