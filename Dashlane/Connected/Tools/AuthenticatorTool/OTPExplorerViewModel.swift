import Foundation
import Combine
import AuthenticatorKit
import CorePersonalData
import DashTypes
import VaultKit

class OTPExplorerViewModel: ObservableObject, SessionServicesInjecting {

    enum Action {
        case setupAuthentication(Credential?)
        case addNewLogin
    }

    private let vaultItemsService: VaultItemsServiceProtocol
    private let vaultItemRowModelFactory: VaultItemRowModel.Factory
    private let actionHandler: (Action) -> Void

    @Published
    var otpNotConfiguredCredentials: [Credential] = []

    @Published
    var otpSupportedCredentials: [Credential] = []

    init(
        vaultItemsService: VaultItemsServiceProtocol,
        otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
        vaultItemRowModelFactory: VaultItemRowModel.Factory,
        actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
    ) {
        self.vaultItemsService = vaultItemsService
        self.vaultItemRowModelFactory = vaultItemRowModelFactory
        self.actionHandler = actionHandler

        vaultItemsService.$credentials.map {
            $0.filter {
                guard let domain = $0.url?.domain?.name else {
                    return false
                }
                return otpSupportedDomainsRepository.isOTPSupported(domain: domain)
            }
        }.assign(to: &$otpSupportedCredentials)

        vaultItemsService.$credentials.map {
            $0.filter {
                guard let domain = $0.url?.domain?.name else {
                    return false
                }

                return otpSupportedDomainsRepository.isOTPSupported(domain: domain) && $0.otpURL == nil
            }
        }.assign(to: &$otpNotConfiguredCredentials)
  }

    func startAddCredentialFlow() {
        actionHandler(.addNewLogin)
    }

    func startSetupOTPFlow(for credential: Credential? = nil) {
        actionHandler(.setupAuthentication(credential))
    }

    func makeItemRowViewModel(credential: Credential) -> VaultItemRowModel {
        vaultItemRowModelFactory.make(
            configuration: .init(
                item: credential,
                isSuggested: false
            ),
            additionalConfiguration: .init(
                origin: .vault,
                quickActionsEnabled: false
            )
        )
    }

}

extension OTPExplorerViewModel {
    static var mock: OTPExplorerViewModel {
        let container = MockServicesContainer()
        return OTPExplorerViewModel(
            vaultItemsService: container.vaultItemsService,
            otpSupportedDomainsRepository: OTPSupportedDomainsRepository(),
            vaultItemRowModelFactory: .init { .mock(configuration: $0, additionalConfiguration: $1) },
            actionHandler: { _ in }
        )
    }
}
