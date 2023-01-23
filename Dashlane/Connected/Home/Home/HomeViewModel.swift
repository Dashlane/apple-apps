import SwiftUI
import Combine
import CorePersonalData
import DashlaneReportKit
import CoreUserTracking
import CoreFeature
import DashlaneAppKit
import SwiftTreats
import CoreSettings
import DashTypes
import NotificationKit
import CorePremium

class HomeViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var showAutofillBanner: Bool = false

    @Published
    var shouldShowOnboardingBanner: Bool

    let action: (VaultFlowViewModel.Action) -> Void

    private let vaultItemsService: VaultItemsServiceProtocol
    private let autofillService: AutofillService
    private let usageLogService: UsageLogServiceProtocol
    private let brazeService: BrazeServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "homeView", qos: .utility)
    private let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel

    let autofillBannerViewModel: AutofillBannerViewModel
    let userSettings: UserSettings
    let onboardingChecklistViewModel: OnboardingChecklistViewModel?
    let vaultListViewModel: VaultListViewModel

    var shouldDisplayEmptyVaultPlaceholder: Bool {
        Device.isMac && vaultItemsService.credentials.isEmpty
    }

    var homeAnnouncementsViewModel: HomeBannersAnnouncementsViewModel {
        HomeBannersAnnouncementsViewModel(premiumAnnouncementsViewModel: premiumAnnouncementsViewModel,
                                          autofillBannerViewModel: autofillBannerViewModel,
                                          showAutofillBanner: showAutofillBanner)
    }

    let modalAnnouncementsViewModel: HomeModalAnnouncementsViewModel

    init(
        vaultItemsService: VaultItemsServiceProtocol,
        autofillService: AutofillService,
        userSettings: UserSettings,
        viewModelFactory: ViewModelFactory?,
        usageLogService: UsageLogServiceProtocol,
        brazeService: BrazeServiceProtocol,
        syncedSettings: SyncedSettingsService,
        premiumService: CorePremium.PremiumServiceProtocol,
        deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        capabilityService: CapabilityServiceProtocol,
        lockService: LockServiceProtocol,
        abTestingService: ABTestingServiceProtocol,
        onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
        action: @escaping (VaultFlowViewModel.Action) -> Void,
        homeModalAnnouncementsViewModelFactory: HomeModalAnnouncementsViewModel.Factory,
        vaultListViewModelFactory: VaultListViewModel.Factory,
        premiumAnnouncementsViewModelFactory: PremiumAnnouncementsViewModel.Factory
    ) {
        self.usageLogService = usageLogService
        self.userSettings = userSettings
        self.brazeService = brazeService
        self.onboardingChecklistViewModel = viewModelFactory?.makeOnboardingChecklistViewModel(
            logsService: .init(usageLogService: usageLogService),
            action: onboardingAction)
        self.autofillService = autofillService
        self.vaultItemsService = vaultItemsService

        self.modalAnnouncementsViewModel = homeModalAnnouncementsViewModelFactory.make()
        self.premiumAnnouncementsViewModel = premiumAnnouncementsViewModelFactory.make(excludedAnnouncements: [])
        self.action = action
        self.autofillBannerViewModel = AutofillBannerViewModel {
            switch $0 {
            case .showAutofillDemo:
                action(.showAutofillDemo)
            }
        }
        self.vaultListViewModel = vaultListViewModelFactory.make(filter: .all) { completion in
            switch completion {
            case let .enterDetail(item, selectVaultItem):
                action(.didSelectItem(item, selectVaultItem: selectVaultItem))
            case let.addItem(mode):
                action(.addItem(displayMode: mode))
            }
        }

        shouldShowOnboardingBanner = userSettings.shouldShowOnboardingChecklist

        setupPublishers()

        lockService.locker.screenLocker?
            .$lock
            .filter { $0 == nil }
            .sink { [weak self] _ in
                self?.modalAnnouncementsViewModel.trigger.send(.sessionUnlocked)
            }.store(in: &subscriptions)
    }

    func setupPublishers() {
        autofillService
            .$activationStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                if !Device.isMac {
                    self.showAutofillBanner = !(status.isEnabled ?? true)
                }
            }
            .store(in: &subscriptions)

        userSettings.settingsChangePublisher.sink { [weak self] key in
            guard let self = self else { return }
            switch key {
            case .hasUserDismissedOnboardingChecklist, .hasUserUnlockedOnboardingChecklist:
                self.shouldShowOnboardingBanner = self.userSettings.shouldShowOnboardingChecklist
            default:
                break
            }
        }.store(in: &subscriptions)
    }
}

extension UserSettings {
    var shouldShowOnboardingChecklist: Bool {
        let hasUserDismissedOnboardingChecklist = self[.hasUserDismissedOnboardingChecklist] ?? false
        let hasUserUnlockedOnboardingChecklist = self[.hasUserUnlockedOnboardingChecklist] ?? false

        return !hasUserDismissedOnboardingChecklist && hasUserUnlockedOnboardingChecklist && !Device.isMac
    }
}

extension HomeViewModel {
    static var mock: HomeViewModel {
        HomeViewModel(
            vaultItemsService: MockServicesContainer().vaultItemsService,
            autofillService: AutofillService(vaultItemsService: MockServicesContainer().vaultItemsService),
            userSettings: .mock,
            viewModelFactory: nil,
            usageLogService: UsageLogService.fakeService,
            brazeService: BrazeService.mock,
            syncedSettings: .mock,
            premiumService: CorePremium.PremiumServiceMock(),
            deepLinkingService: NotificationKitDeepLinkingServiceMock(),
            activityReporter: .fake,
            capabilityService: CapabilityServiceMock(),
            lockService: LockServiceMock(),
            abTestingService: ABTestingServiceMock.mock,
            onboardingAction: { _ in },
            action: { _ in },
            homeModalAnnouncementsViewModelFactory: .init { .mock },
            vaultListViewModelFactory: .init { _, _  in .mock },
            premiumAnnouncementsViewModelFactory: .init { .mock(announcements: Array($0)) }
        )
    }
}
