import Foundation
import UIKit
import CoreSession
import DashlaneReportKit
import DashlaneAppKit
import CoreUserTracking
import CorePasswords
import DashTypes
import CorePersonalData
import CoreNetworking
import LoginKit
import CoreFeature
import Combine

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
    private let usageLogService: UsageLogServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let sessionLifeCycleHandler: SessionLifeCycleHandler?

    @Published
    var activeAlert: Alert?

    private let actionHandler: (MasterPasswordResetActivationViewModel.Action) -> Void

    let deepLinkPublisher: AnyPublisher<SettingsDeepLinkComponent, Never>

    let masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory
    let changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory

    init(session: Session,
         featureService: FeatureServiceProtocol,
         teamSpacesService: TeamSpacesService,
         premiumService: PremiumServiceProtocol,
         deviceListViewModel: @escaping () -> DeviceListViewModel,
         subscriptionCodeFetcher: SubscriptionCodeFetcherService,
         usageLogService: UsageLogServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         deepLinkingService: DeepLinkingServiceProtocol,
         masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory,
         changeMasterPasswordFlowViewModelFactory: ChangeMasterPasswordFlowViewModel.Factory,
         actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) {
        self.session = session
        self.featureService = featureService
        self.teamSpacesService = teamSpacesService
        self.premiumService = premiumService
        self.deviceListViewModel = deviceListViewModel
        self.subscriptionCodeFetcher = subscriptionCodeFetcher
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.actionHandler = actionHandler
        deepLinkPublisher = deepLinkingService.settingsComponentPublisher()
        self.masterPasswordResetActivationViewModelFactory = masterPasswordResetActivationViewModelFactory
        self.changeMasterPasswordFlowViewModelFactory = changeMasterPasswordFlowViewModelFactory
    }

                                    var isChangeMasterPasswordAvailable: Bool {
                guard featureService.isEnabled(.changeMasterPasswordIsAvailable) else {
            return false
        }
        return !teamSpacesService.isSSOUser
    }

        var isResetMasterPasswordAvailable: Bool {
        return !teamSpacesService.isSSOUser
    }

        private(set) lazy var masterPasswordResetActivationViewModel: MasterPasswordResetActivationViewModel = {
        return masterPasswordResetActivationViewModelFactory.make(actionHandler: actionHandler)
    }()

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
        usageLogService.post(UsageLogCode35UserActionsMobile(type: "settings", action: "goToPrivacySettings"))
    }

    func logOut() {
        activityReporter.report(UserEvent.Logout())
        sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
    }

    func enableResetMasterPassword() {
        guard isResetMasterPasswordAvailable else { return }
        masterPasswordResetActivationViewModel.isToggleOn = true
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
                                        usageLogService: UsageLogService.fakeService,
                                        activityReporter: .fake,
                                        sessionLifeCycleHandler: nil,
                                        deepLinkingService: DeepLinkingService.fakeService,
                                        masterPasswordResetActivationViewModelFactory: .init({ _ in .mock }),
                                        changeMasterPasswordFlowViewModelFactory: .init({ .mock }),
                                        actionHandler: { _ in })
    }
}
