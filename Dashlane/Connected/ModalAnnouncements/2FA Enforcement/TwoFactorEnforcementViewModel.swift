import Foundation
import CoreSession
import CoreNetworking

@MainActor
class TwoFactorEnforcementViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var isTwoFAEnabled: Bool = false

    let accountAPIClient: AccountAPIClientProtocol
    let twoFASetupViewModelFactory: TwoFASetupViewModel.Factory
    let lockService: LockServiceProtocol
    let logout: () -> Void

    init(accountAPIClient: AccountAPIClientProtocol,
         lockService: LockServiceProtocol,
         twoFASetupViewModelFactory: TwoFASetupViewModel.Factory,
         logout: @escaping () -> Void) {
        self.accountAPIClient = accountAPIClient
        self.twoFASetupViewModelFactory = twoFASetupViewModelFactory
        self.lockService = lockService
        self.logout = logout
    }

    func fetch() async {
        do {
            let response = try await accountAPIClient.twoFAStatus()
            isTwoFAEnabled = response.twoFAType != nil
        } catch {}
    }
}

extension TwoFactorEnforcementViewModel {
    static var mock: TwoFactorEnforcementViewModel {
        .init(accountAPIClient: AccountAPIClient(apiClient: .fake),
              lockService: LockServiceMock(),
              twoFASetupViewModelFactory: .init({ .mock }),
              logout: {})
    }
}
