import Combine
import CorePersonalData
import CoreUserTracking
import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import UIKit
import VaultKit
import NotificationKit
import CoreFeature

@MainActor
final class VaultFlowViewModel: ObservableObject, SessionServicesInjecting, AutoFillDemoHandler {
    enum Action {
        case showAutofillDemo
        case showChecklist
        case addItemOfCategory(_ category: ItemCategory)
        case didSelectItem(_ item: VaultItem, selectVaultItem: UserEvent.SelectVaultItem)
        case addItem(displayMode: AddItemFlowViewModel.DisplayMode)
    }

        enum Mode {
                                case allItems(HomeViewModel)

                                case category(ItemCategory)

        var isShowingAllItems: Bool {
            switch self {
            case .allItems:
                return true
            default:
                return false
            }
        }
    }

    enum Step {
                                case list(HomeViewModel)

                                case category(VaultListViewModel)

                case detail(DetailView)

                case autofillDemoDummyFields(Credential)
    }

        let tag: Int = 0
    let id: UUID = .init()

    @Published
    var steps: [Step] = []

    @Published
    var navigationBarStyle: UIDelight.NavigationBarStyle = .default

    @Published
    var showAddItemFlow: Bool = false

    @Published
    var showAutofillFlow: Bool = false

    @Published
    var showOnboardingChecklist: Bool = false

    @Published
    var autofillDemoDummyFieldsCredential: Credential?

    lazy var viewController: UIViewController = {
        UIHostingController(
            rootView: NavigationView {
                VaultFlow(viewModel: self)
            }
            .navigationViewStyle(.stack)
            .navigationBarHidden(true)
        )
    }()

    private(set) var mode: Mode!

        let detailInformationValue: CurrentValueSubject<TabElementDetail, Never>? = .init(.text(""))
    let actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never> = .init()

    private var cancellables: Set<AnyCancellable> = []

        private let detailViewFactory: DetailView.Factory
    private let homeViewModelFactory: HomeViewModel.Factory
    private let vaultListViewModelFactory: VaultListViewModel.Factory
    let addItemFlowViewModelFactory: AddItemFlowViewModel.Factory
    let autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory
    let onboardingChecklistFlowViewModelFactory: OnboardingChecklistFlowViewModel.Factory

    var addItemFlowDisplayMode: AddItemFlowViewModel.DisplayMode?

        let sessionServices: SessionServicesContainer
    private let accessControl: AccessControlProtocol
    private let teamSpaceService: TeamSpacesService
    private let usageLogService: UsageLogServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol

        private let categoryCountQueue = DispatchQueue(label: "vaultCategoryCount", qos: .utility)

    init(
        itemCategory: ItemCategory? = nil,
        onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil,
        detailViewFactory: DetailView.Factory,
        homeViewModelFactory: HomeViewModel.Factory,
        vaultListViewModelFactory: VaultListViewModel.Factory,
        addItemFlowViewModelFactory: AddItemFlowViewModel.Factory,
        autofillOnboardingFlowViewModelFactory: AutofillOnboardingFlowViewModel.Factory,
        onboardingChecklistFlowViewModelFactory: OnboardingChecklistFlowViewModel.Factory,
        sessionServices: SessionServicesContainer,
        usageLogService: UsageLogServiceProtocol
    ) {
        self.detailViewFactory = detailViewFactory
        self.homeViewModelFactory = homeViewModelFactory
        self.vaultListViewModelFactory = vaultListViewModelFactory
        self.addItemFlowViewModelFactory = addItemFlowViewModelFactory
        self.autofillOnboardingFlowViewModelFactory = autofillOnboardingFlowViewModelFactory
        self.onboardingChecklistFlowViewModelFactory = onboardingChecklistFlowViewModelFactory

        self.sessionServices = sessionServices
        self.accessControl = sessionServices.accessControl
        self.usageLogService = usageLogService
        self.teamSpaceService = sessionServices.teamSpacesService
        self.activityReporter = sessionServices.activityReporter
        self.vaultItemsService = sessionServices.vaultItemsService

        start(with: itemCategory, onboardingChecklistViewAction: onboardingChecklistViewAction)
        setupPublishers()
    }

    private func start(
        with itemCategory: ItemCategory?,
        onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)?
    ) {
        switch (itemCategory, onboardingChecklistViewAction) {
        case (.none, .some(let handler)):
            start(with: handler)
        case (.some(let itemCategory), .none):
            start(with: itemCategory)
        default:
            assertionFailure("VaultFlowViewModel should always be initialized with either a ItemCategory or a OnboardingChecklistViewAction handler")
        }
    }

    private func start(with itemCategory: ItemCategory) {
        mode = .category(itemCategory)
        showCategoryDetail(itemCategory)
    }

    private func start(with onboardingChecklistViewAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void) {
        let homeViewModel = homeViewModelFactory.make(
            onboardingAction: onboardingChecklistViewAction,
            action: { self.handleHomeViewAction($0) }
        )
        mode = .allItems(homeViewModel)
        showListView(homeViewModel: homeViewModel)
    }

    private func setupPublishers() {
        actionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] action in
                switch action {
                case .showAutofillDemo(let credential):
                    self?.showAutofillDemo(for: credential)
                }
            }
            .store(in: &cancellables)

        if case let .category(category) = mode {
            vaultItemsService
                .itemsPublisher(for: category)
                .receive(on: categoryCountQueue)
                .filter(by: teamSpaceService.$selectedSpace)
                .map { $0.count }
                .receive(on: RunLoop.main)
                .sink { [weak self] count in
                    self?.detailInformationValue?.send(.text(String(count)))
                }
                .store(in: &cancellables)
        }
    }
}

extension VaultFlowViewModel {
    func handleHomeViewAction(_ action: VaultFlowViewModel.Action) {
        switch action {
        case .showAutofillDemo:
            showAutofillDemo()
        case .showChecklist:
            showChecklist()
        case let .didSelectItem(item, selectVaultItem):
            showDetail(for: item, selectVaultItem: selectVaultItem)
        case let .addItem(displayMode):
            showAddItemMenuView(displayMode: displayMode)
        default:
            break
        }
    }

    func handleAutofillDemoDummyFieldsAction(_ action: AutoFillDemoDummyFields.Completion) {
        switch action {
        case .back:
            if Device.isIpadOrMac {
                autofillDemoDummyFieldsCredential = nil
            } else {
                steps.removeLast()
            }
        case .setupAutofill:
            showAutofillDemo()
        }
    }

    func showCategoryDetail(_ category: ItemCategory) {
        let model = vaultListViewModelFactory.make(filter: category.vaultListFilter) { [weak self] completion in
            switch completion {
            case .addItem(let mode):
                self?.showAddItemMenuView(displayMode: mode)
            case let .enterDetail(item, selectVaultItem):
                self?.showDetail(for: item, selectVaultItem: selectVaultItem)
            }
        }

                steps.removeAll()
        steps.append(.category(model))
    }

    func showListView(homeViewModel: HomeViewModel) {
                steps.removeAll()
        steps.append(.list(homeViewModel))
    }

    func displaySearch(for query: String) {
        guard case let .allItems(homeViewModel) = mode else { return }
        homeViewModel.vaultListViewModel.searchViewModel.searchCriteria = query
        homeViewModel.vaultListViewModel.searchViewModel.isSearchActive = true
    }

    func showDetail(
        for item: VaultItem,
        selectVaultItem: UserEvent.SelectVaultItem,
        isEditing: Bool = false,
        origin: ItemDetailOrigin = .unknown
    ) {
        if let secureItem = item as? SecureItem, secureItem.secured {
            accessControl
                .requestAccess()
                .sink { [weak self] success in
                    if success {
                        self?.showItemDetail(
                            for: item,
                            selectVaultItem: selectVaultItem,
                            isEditing: isEditing,
                            origin: origin
                        )
                    }
                }
                .store(in: &cancellables)
        } else {
            showItemDetail(
                for: item,
                selectVaultItem: selectVaultItem,
                isEditing: isEditing,
                origin: origin
            )
        }
    }

    private func showItemDetail(
        for item: VaultItem,
        selectVaultItem: UserEvent.SelectVaultItem,
        isEditing: Bool,
        origin: ItemDetailOrigin
    ) {
        activityReporter.report(selectVaultItem)
        let viewType: ItemDetailViewType = isEditing ? .editing(item) : .viewing(item, actionPublisher: actionPublisher, origin: origin)
        let view: DetailView
        if item is SecureNote {
            view = detailViewFactory.make(itemDetailViewType: viewType, dismiss: .init { [weak self] in
                if self?.steps.isEmpty == false {
                    self?.steps.removeLast()
                }
            })
        } else {
            view = detailViewFactory.make(itemDetailViewType: viewType)
        }

        steps.append(.detail(view))
    }

    func showAddItemMenuView(displayMode: AddItemFlowViewModel.DisplayMode) {
        usageLogService.addItemLogger.logTapAddItem()

        addItemFlowDisplayMode = displayMode
        showAddItemFlow = true
    }

    func showAutofillDemo(for credential: Credential) {
        showAutofillDemo(
            for: credential,
            modal: { self.autofillDemoDummyFieldsCredential = credential },
            push: { self.steps.append(.autofillDemoDummyFields(credential)) }
        )
    }

    func showAutofillDemo() {
        showAutofillFlow = true
    }

    func showChecklist() {
        showOnboardingChecklist = true
    }
}

extension VaultFlowViewModel {
    func reportAddItemFlowDismissed() {
        switch steps.last {
        case .list(let viewModel):
            activityReporter.reportPageShown(viewModel.vaultListViewModel.activeFilter.page)
        case .category(let viewModel):
            activityReporter.reportPageShown(viewModel.activeFilter.page)
        default:
            break
        }
    }
}
