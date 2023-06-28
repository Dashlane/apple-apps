import Foundation
import UIKit
import CoreSession
import DashlaneAppKit
import CoreUserTracking
import CorePasswords
import DashTypes
import CorePersonalData
import CoreNetworking
import LoginKit
import CoreFeature
import Combine
import CorePremium

@MainActor
final class SettingsAccountSectionViewModel: ObservableObject, SessionServicesInjecting {

    enum Alert {
        case privacyError
        case wrongMasterPassword
        case logOut
    }

    let session: Session
    private let featureService: FeatureServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let premiumService: PremiumServiceProtocol
    let deviceListViewModel: () -> DeviceListViewModel
    private let subscriptionCodeFetcher: SubscriptionCodeFetcherService
    private let activityReporter: ActivityReporterProtocol
    private let sessionLifeCycleHandler: SessionLifeCycleHandler?

    @Published
    var activeAlert: Alert?

    private let actionHandler: (MasterPasswordResetActivationViewModel.Action) -> Void

    let deepLinkPublisher: AnyPublisher<SettingsDeepLinkComponent, Never>

    let masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory
    let changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory
    let accountRecoveryKeyStatusViewModelFactory: AccountRecoveryKeyStatusViewModel.Factory

    init(session: Session,
         featureService: FeatureServiceProtocol,
         teamSpacesService: TeamSpacesService,
         premiumService: PremiumServiceProtocol,
         deviceListViewModel: @escaping () -> DeviceListViewModel,
         subscriptionCodeFetcher: SubscriptionCodeFetcherService,
         activityReporter: ActivityReporterProtocol,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         deepLinkingService: DeepLinkingServiceProtocol,
         masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory,
         changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory,
         accountRecoveryKeyStatusViewModelFactory: AccountRecoveryKeyStatusViewModel.Factory,
         actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) {
        self.session = session
        self.featureService = featureService
        self.teamSpacesService = teamSpacesService
        self.premiumService = premiumService
        self.deviceListViewModel = deviceListViewModel
        self.subscriptionCodeFetcher = subscriptionCodeFetcher
        self.activityReporter = activityReporter
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.actionHandler = actionHandler
        deepLinkPublisher = deepLinkingService.settingsComponentPublisher()
        self.masterPasswordResetActivationViewModelFactory = masterPasswordResetActivationViewModelFactory
        self.changeMasterPasswordFlowViewModelFactory = changeMasterPasswordFlowViewModelFactory
        self.accountRecoveryKeyStatusViewModelFactory = accountRecoveryKeyStatusViewModelFactory
    }

                                    var isChangeMasterPasswordAvailable: String? {
                guard featureService.isEnabled(.changeMasterPasswordIsAvailable) else {
            return nil
        }
        return session.authenticationMethod.userMasterPassword
    }

    var canShowAccountRecovery: Bool {
                if session.configuration.info.accountType == .invisibleMasterPassword {
            return true
        }
        guard featureService.isEnabled(.accountRecoveryKey) else {
            return false
        }
        return session.configuration.info.accountType == .masterPassword
    }

        var isResetMasterPasswordAvailable: String? {
        return session.authenticationMethod.userMasterPassword
    }

        func goToPrivacySettings() {
        subscriptionCodeFetcher.fetchPrivacySettingsURL { [weak self] result  in
            guard let self = self else { return }
            switch result {
            case let .success(url):
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            case .failure:
                self.activeAlert = .privacyError
            }
        }
    }

    func logOut() {
        activityReporter.report(UserEvent.Logout())
        if case .invisibleMasterPassword = session.authenticationMethod {
            sessionLifeCycleHandler?.logoutAndPerform(action: .deleteCurrentSessionLocalData)
        } else {
            sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
        }
    }

    func enableResetMasterPassword() {
        guard isResetMasterPasswordAvailable != nil else { return }
    }

    func makeAccountRecoveryKeyStatusViewModel() -> AccountRecoveryKeyStatusViewModel {
        return accountRecoveryKeyStatusViewModelFactory.make()
    }

    func makeMasterPasswordChallengeAlertViewModel(masterPassword: String, completion: @escaping (MasterPasswordChallengeAlertViewModel.Completion) -> Void ) -> MasterPasswordChallengeAlertViewModel {
        return MasterPasswordChallengeAlertViewModel(masterPassword: masterPassword, intent: .changeMasterPassword, completion: completion)
    }

    func makeMasterPasswordResetActivationViewModel(masterPassword: String) -> MasterPasswordResetActivationViewModel {
        masterPasswordResetActivationViewModelFactory.make(masterPassword: masterPassword, actionHandler: actionHandler)
    }
}

extension SettingsAccountSectionViewModel {

    static var mock: SettingsAccountSectionViewModel {
        SettingsAccountSectionViewModel(session: .mock,
                                        featureService: .mock(),
                                        teamSpacesService: .mock(),
                                        premiumService: PremiumServiceMock(),
                                        deviceListViewModel: { DeviceListViewModel.mock },
                                        subscriptionCodeFetcher: SubscriptionCodeFetcherService.mock,
                                        activityReporter: .fake,
                                        sessionLifeCycleHandler: nil,
                                        deepLinkingService: DeepLinkingService.fakeService,
                                        masterPasswordResetActivationViewModelFactory: .init({ _, _  in .mock }),
                                        changeMasterPasswordFlowViewModelFactory: .init({ .mock }),
                                        accountRecoveryKeyStatusViewModelFactory: .init({ .mock }),
                                        actionHandler: { _ in })
    }
}
