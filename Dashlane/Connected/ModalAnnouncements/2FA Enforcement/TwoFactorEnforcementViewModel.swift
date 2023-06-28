import Foundation
import CoreSession
import CoreNetworking

@MainActor
class TwoFactorEnforcementViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var isTwoFAEnabled: Bool = false

    let userDeviceAPIClient: UserDeviceAPIClient
    let twoFASetupViewModelFactory: TwoFASetupViewModel.Factory
    let lockService: LockServiceProtocol
    let logout: () -> Void

    init(userDeviceAPIClient: UserDeviceAPIClient,
         lockService: LockServiceProtocol,
         twoFASetupViewModelFactory: TwoFASetupViewModel.Factory,
         logout: @escaping () -> Void) {
        self.userDeviceAPIClient = userDeviceAPIClient
        self.twoFASetupViewModelFactory = twoFASetupViewModelFactory
        self.lockService = lockService
        self.logout = logout
    }

    func fetch() async {
        do {
            let response = try await userDeviceAPIClient.authentication.get2FAStatus()
            isTwoFAEnabled = response.type.twoFAType != nil
        } catch {}
    }
}

extension TwoFactorEnforcementViewModel {
    static var mock: TwoFactorEnforcementViewModel {
        .init(userDeviceAPIClient: UserDeviceAPIClient.fake,
              lockService: LockServiceMock(),
              twoFASetupViewModelFactory: .init({ .mock }),
              logout: {})
    }
}
