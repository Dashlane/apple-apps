import SwiftUI
import Combine
import CorePersonalData
import CoreUserTracking
import CoreFeature
import DashlaneAppKit
import SwiftTreats
import CoreSettings
import DashTypes
import NotificationKit
import CorePremium
import ImportKit
import AutofillKit
import VaultKit

class HomeViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var showAutofillBanner: Bool = false

    @Published
    var shouldShowLastpassBanner: Bool

    @Published
    var shouldShowOnboardingBanner: Bool

    let action: (VaultFlowViewModel.Action) -> Void

    private let vaultItemsService: VaultItemsServiceProtocol
    private let autofillService: AutofillService
    private let brazeService: BrazeServiceProtocol
    private let featureService: FeatureServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "homeView", qos: .utility)
    private let premiumAnnouncementsViewModel: PremiumAnnouncementsViewModel
    private let isLastpassInstalled: Bool

    let autofillBannerViewModel: AutofillBannerViewModel
    let lastpassImportBannerViewModel: LastpassImportBannerViewModel
    let userSettings: UserSettings
    let onboardingChecklistViewModel: OnboardingChecklistViewModel?
    let vaultListViewModel: VaultListViewModel

    func makeHomeAnnouncementsViewModel() -> HomeBannersAnnouncementsViewModel {
        HomeBannersAnnouncementsViewModel(premiumAnnouncementsViewModel: premiumAnnouncementsViewModel,
                                          autofillBannerViewModel: autofillBannerViewModel,
                                          lastpassImportBannerViewModel: lastpassImportBannerViewModel,
                                          showAutofillBannerPublisher: $showAutofillBanner.eraseToAnyPublisher(),
                                          shouldShowLastpassBanner: shouldShowLastpassBanner,
                                          credentialsCount: vaultItemsService.credentials.count)
    }

    init(
        vaultItemsService: VaultItemsServiceProtocol,
        autofillService: AutofillService,
        userSettings: UserSettings,
        viewModelFactory: ViewModelFactory?,
        brazeService: BrazeServiceProtocol,
        syncedSettings: SyncedSettingsService,
        featureService: FeatureServiceProtocol,
        premiumService: CorePremium.PremiumServiceProtocol,
        deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        capabilityService: CapabilityServiceProtocol,
        abTestingService: ABTestingServiceProtocol,
        onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
        action: @escaping (VaultFlowViewModel.Action) -> Void,
        lastpassDetector: LastpassDetector,
        vaultListViewModelFactory: VaultListViewModel.Factory,
        premiumAnnouncementsViewModelFactory: PremiumAnnouncementsViewModel.Factory
    ) {
        self.featureService = featureService
        self.userSettings = userSettings
        self.brazeService = brazeService
        self.onboardingChecklistViewModel = viewModelFactory?.makeOnboardingChecklistViewModel(action: onboardingAction)
        self.autofillService = autofillService
        self.vaultItemsService = vaultItemsService

        self.premiumAnnouncementsViewModel = premiumAnnouncementsViewModelFactory.make(excludedAnnouncements: [])
        self.action = action
        self.autofillBannerViewModel = AutofillBannerViewModel {
            switch $0 {
            case .showAutofillDemo:
                action(.showAutofillDemo)
            }
        }
        self.lastpassImportBannerViewModel = .init(deeplinkingService: deepLinkingService,
                                                   userSettings: userSettings)
        self.vaultListViewModel = vaultListViewModelFactory.make(filter: .all) { completion in
            switch completion {
            case let .enterDetail(item, selectVaultItem, isEditing):
                action(.didSelectItem(item, selectVaultItem: selectVaultItem, isEditing: isEditing))
            case let.addItem(mode):
                action(.addItem(displayMode: mode))
            }
        }
        self.isLastpassInstalled = lastpassDetector.isLastpassInstalled

        self.shouldShowLastpassBanner = featureService.isEnabled(.lastpassImport) && self.userSettings[.lastpassImportPopupHasBeenShown] != true && isLastpassInstalled
        shouldShowOnboardingBanner = userSettings.shouldShowOnboardingChecklist

        setupPublishers()
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
            case .lastpassImportPopupHasBeenShown:
                self.shouldShowLastpassBanner = self.featureService.isEnabled(.lastpassImport) && self.userSettings[.lastpassImportPopupHasBeenShown] != true && self.isLastpassInstalled
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
            brazeService: BrazeService.mock,
            syncedSettings: .mock,
            featureService: .mock(),
            premiumService: CorePremium.PremiumServiceMock(),
            deepLinkingService: NotificationKitDeepLinkingServiceMock(),
            activityReporter: .fake,
            capabilityService: .mock(),
            abTestingService: ABTestingServiceMock.mock,
            onboardingAction: { _ in },
            action: { _ in },
            lastpassDetector: .mock,
            vaultListViewModelFactory: .init { _, _  in .mock },
            premiumAnnouncementsViewModelFactory: .init { .mock(announcements: Array($0)) }
        )
    }
}
