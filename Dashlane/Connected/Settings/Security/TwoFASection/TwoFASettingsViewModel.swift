import Foundation
import CorePersonalData
import DashTypes
import CoreSession
import CoreNetworking
import TOTPGenerator
import UIKit
import LoginKit

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
    let accountAPIClient: AccountAPIClientProtocol
    let logger: Logger
    let isTwoFAEnforced: Bool
    let nonAuthenticatedUKIBasedWebService: LegacyWebService

    let sessionLifeCycleHandler: SessionLifeCycleHandler?

    let twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory
    let twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory
    let twoFASetupViewModelFactory: TwoFASetupViewModel.Factory
    let twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory

    init(login: Login,
         loginOTPOption: ThirdPartyOTPOption?,
         authenticatedAPIClient: DeprecatedCustomAPIClient,
         nonAuthenticatedUKIBasedWebService: LegacyWebService,
         logger: Logger,
         isTwoFAEnforced: Bool,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory,
         twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory,
         twoFASetupViewModelFactory: TwoFASetupViewModel.Factory,
         twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory) {
        self.login = login
        self.accountAPIClient = AccountAPIClient(apiClient: authenticatedAPIClient)
        self.currentOTP = loginOTPOption != nil ? .otp2 : nil
        self.isTFAEnabled = currentOTP == nil ? false : true
        self.logger = logger
        self.isTwoFAEnforced = isTwoFAEnforced
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.twoFADeactivationViewModelFactory = twoFADeactivationViewModelFactory
        self.twoFAActivationViewModelFactory = twoFAActivationViewModelFactory
        self.twoFASetupViewModelFactory = twoFASetupViewModelFactory
        self.twoFactorEnforcementViewModelFactory = twoFactorEnforcementViewModelFactory

        Task {
            await fetch()
        }
    }

    func fetch() async {
        status = .loading
        do {
            let response = try await accountAPIClient.twoFAStatus()
            self.currentOTP = response.twoFAType
            self.status = .loaded
        } catch {
            self.status = .error
        }
    }

    func updateState() async {
        await fetch()
        if !isTFAEnabled && isTwoFAEnforced {
            sheet = .twoFAEnforced
        }
    }

    func makeTwoFADeactivationViewModel(currentOtp: Dashlane2FAType) -> TwoFADeactivationViewModel {
        return twoFADeactivationViewModelFactory.make(isTwoFAEnforced: isTwoFAEnforced,
                                               recover2faWebService: Recover2FAWebService(webService: nonAuthenticatedUKIBasedWebService, login: login))
    }

    func makeTwoFactorEnforcementViewModel() -> TwoFactorEnforcementViewModel {
        twoFactorEnforcementViewModelFactory.make(accountAPIClient: accountAPIClient) { [weak self] in
            self?.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
        }
    }

    func update() {
        if let currentOTP = currentOTP, isTwoFAEnforced {
            sheet = .deactivation(currentOTP)
        } else if currentOTP != nil {
            showDeactivationAlert = true
        } else {
            sheet = .activation
        }
    }
}

extension TwoFASettingsViewModel {
    static var mock: TwoFASettingsViewModel {
        return TwoFASettingsViewModel(login: Login("_"),
                                      loginOTPOption: nil,
                                      authenticatedAPIClient: .fake,
                                      nonAuthenticatedUKIBasedWebService: LegacyWebServiceMock(response: ""),
                                      logger: LoggerMock(),
                                      isTwoFAEnforced: true,
                                      sessionLifeCycleHandler: nil,
                                      twoFADeactivationViewModelFactory: .init({ _, _ in .mock() }),
                                      twoFAActivationViewModelFactory: .init({ .mock }),
                                      twoFASetupViewModelFactory: .init({ .mock }),
                                      twoFactorEnforcementViewModelFactory: .init({ _, _ in .mock }))
    }
}
