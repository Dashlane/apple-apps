import Foundation
import Combine
import CorePersonalData
import DashlaneReportKit
import CoreFeature
import CoreUserTracking
import DashlaneAppKit
import CoreSettings
import VaultKit
import DashTypes
import CoreSharing

enum VaultListCompletion {
    case enterDetail(VaultItem, UserEvent.SelectVaultItem)
    case addItem(AddItemFlowViewModel.DisplayMode)
}

class VaultListViewModel: ObservableObject, SessionServicesInjecting {
    @Published
    var activeFilter: VaultListFilter {
        didSet {
            searchViewModel.activeFilter = activeFilter
        }
    }

    let completion: ((VaultListCompletion) -> Void)
    let searchViewModel: VaultSearchViewModel

    private let activityReporter: ActivityReporterProtocol
    private let userSettings: UserSettings
    private var subscriptions = Set<AnyCancellable>()

    @Published
    private var shouldShowOnboardingChecklist: Bool

    init(
        filter: VaultListFilter,
        activityReporter: ActivityReporterProtocol,
        userSettings: UserSettings,
        searchViewModelFactory: VaultSearchViewModel.Factory,
        completion: @escaping ((VaultListCompletion) -> Void)
    ) {
        self.activeFilter = filter
        self.activityReporter = activityReporter
        self.userSettings = userSettings
        self.completion = completion
        self.searchViewModel = searchViewModelFactory.make(activeFilter: filter, completion: completion)
        self.shouldShowOnboardingChecklist = userSettings.shouldShowOnboardingChecklist
        setup()
    }

    private func setup() {
        $activeFilter
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] filter in self?.activityReporter.reportPageShown(filter.page) }
            .store(in: &subscriptions)

        userSettings
            .settingsChangePublisher
            .sink { [weak self] key in
                guard let self else { return }
                switch key {
                case .hasUserDismissedOnboardingChecklist, .hasUserUnlockedOnboardingChecklist:
                    self.shouldShowOnboardingChecklist = self.userSettings.shouldShowOnboardingChecklist
                default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
}

extension VaultListViewModel {
    static var mock: VaultListViewModel {
        VaultListViewModel(
            filter: .all,
            activityReporter: .fake,
            userSettings: UserSettings(internalStore: InMemoryLocalSettingsStore()),
            searchViewModelFactory: .init { _, _ in .mock },
            completion: { _ in }
        )
    }
}
