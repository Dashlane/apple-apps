import Foundation
import CorePersonalData
import DashTypes
import CoreSession
import CoreNetworking
import TOTPGenerator
import UIKit
import LoginKit
import Combine

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
    let nonAuthenticatedUKIBasedWebService: LegacyWebService

    let sessionLifeCycleHandler: SessionLifeCycleHandler?

    let twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory
    let twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory
    let twoFASetupViewModelFactory: TwoFASetupViewModel.Factory
    let twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory
    let reachability: NetworkReachability
    private var subcription: AnyCancellable?

    init(login: Login,
         loginOTPOption: ThirdPartyOTPOption?,
         userAPIClient: UserDeviceAPIClient,
         nonAuthenticatedUKIBasedWebService: LegacyWebService,
         logger: Logger,
         isTwoFAEnforced: Bool,
         reachability: NetworkReachability,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         twoFADeactivationViewModelFactory: TwoFADeactivationViewModel.Factory,
         twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory,
         twoFASetupViewModelFactory: TwoFASetupViewModel.Factory,
         twoFactorEnforcementViewModelFactory: TwoFactorEnforcementViewModel.Factory) {
        self.login = login
        self.userAPIClient = userAPIClient
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

        subcription = reachability.$isConnected
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
        return twoFADeactivationViewModelFactory.make(isTwoFAEnforced: isTwoFAEnforced,
                                               recover2faWebService: Recover2FAWebService(webService: nonAuthenticatedUKIBasedWebService, login: login))
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
        } else {
            sheet = .activation
        }
    }
}

extension TwoFASettingsViewModel {
    static var mock: TwoFASettingsViewModel {
        return TwoFASettingsViewModel(login: Login("_"),
                                      loginOTPOption: nil,
                                      userAPIClient: .fake,
                                      nonAuthenticatedUKIBasedWebService: LegacyWebServiceMock(response: ""),
                                      logger: LoggerMock(),
                                      isTwoFAEnforced: true,
                                      reachability: NetworkReachability(isConnected: true),
                                      sessionLifeCycleHandler: nil,
                                      twoFADeactivationViewModelFactory: .init({ _, _ in .mock() }),
                                      twoFAActivationViewModelFactory: .init({ .mock }),
                                      twoFASetupViewModelFactory: .init({ .mock }),
                                      twoFactorEnforcementViewModelFactory: .init({ _ in .mock }))
    }
}
