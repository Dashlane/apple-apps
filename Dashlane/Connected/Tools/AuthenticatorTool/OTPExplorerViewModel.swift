import AuthenticatorKit
import Combine
import CorePersonalData
import CoreTypes
import Foundation
import VaultKit

class OTPExplorerViewModel: ObservableObject, SessionServicesInjecting {

  enum Action {
    case setupAuthentication(Credential?)
    case addNewLogin
  }

  enum ViewState {
    case loading
    case intro
    case ready
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

  @Published
  var viewState: ViewState = .loading

  var cancellables = Set<AnyCancellable>()

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

    vaultItemsStore
      .$credentials
      .receive(on: DispatchQueue.main)
      .sink { [weak self] credentialsList in
        guard let self else {
          return
        }

        if credentialsList.isEmpty {
          self.viewState = .intro
        } else {
          self.viewState = .ready
        }
      }
      .store(in: &cancellables)

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
      vaultStateService: .mock(),
      deeplinkingService: DeepLinkingService.fakeService,
      otpSupportedDomainsRepository: OTPSupportedDomainsRepository(),
      rowModelFactory: .init { item, _, _ in .mock(item: item) },
      actionHandler: { _ in }
    )
  }
}
