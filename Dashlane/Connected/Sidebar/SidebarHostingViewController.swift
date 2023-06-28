import UIKit
import SwiftUI
import Combine
import DashlaneAppKit
import SwiftTreats
import VaultKit

class SidebarHostingViewController: UIHostingController<SidebarView> {
    private var sessionFlowsContainer: SessionFlowsContainer!
    private let model: SidebarViewModel
    var didSelectTabFlow: ((any TabFlow) -> Void)?
    var cancellables: Set<AnyCancellable> = []

    convenience init(sessionServices: SessionServicesContainer) {
        let model = sessionServices.makeSidebarViewModel()
        self.init(model: model)
    }

    init(model: SidebarViewModel) {
        let sidebarView = SidebarView(model: model)

        self.model = model
        super.init(rootView: sidebarView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

                let mixedListLayout =
        UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.headerMode = section == 0 ? .none : .supplementary
            configuration.showsSeparators = false

            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
        }

        let appearance = UICollectionView.appearance(whenContainedInInstancesOf: [SidebarHostingViewController.self])
        appearance.collectionViewLayout = mixedListLayout
        appearance.allowsFocus = false
        appearance.selectionFollowsFocus = false

        if model.selection == nil {
            model.selection = .home
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.disableSelectionOnFocus()
        }
    }

        private func disableSelectionOnFocus() {
                guard let collectionView = self.view.subviews.last?.subviews.last as? UICollectionView else {
            return
        }

        collectionView.allowsFocus = false
        collectionView.selectionFollowsFocus = false
    }
}

extension SidebarHostingViewController {
    func configure(with container: SessionFlowsContainer) {
        self.sessionFlowsContainer = container
        cancellables.removeAll()

        model.$selection.compactMap { $0 }.sink { [weak self] selection in
            self?.select(selection)
        }.store(in: &cancellables)

                let badgePublishers = sessionFlowsContainer.sidebarElements.flatMap(\.items)
            .compactMap { navItem -> AnyPublisher<(NavigationItem, String?), Never>? in
                guard let publisher = sessionFlowsContainer.flow(for: navItem).badgeValue else {
                    return nil
                }

                return publisher.map { (navItem, $0) }.eraseToAnyPublisher()
            }

        badgePublishers
            .combineLatest()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { values in
                var dict: [NavigationItem: String] = [:]
                for (item, value) in values {
                    dict[item] = value
                }
                return dict
            }
            .assign(to: &model.$badgeValues)
    }

    private func select(_ selection: NavigationItem) {
        guard let splitViewController else {
            return
        }
        let tabFlow = sessionFlowsContainer.flow(for: selection)

                splitViewController.setViewController(nil, for: .secondary)
        let viewController = tabFlow.viewController
        splitViewController.setViewController(viewController, for: .secondary)

        if viewIfLoaded?.window != nil {
                                    didSelectTabFlow?(tabFlow)
        }
    }
}

extension SidebarHostingViewController {
    func showSettings() {
        model.settingsDisplayed = true
    }

    func selectHome() {
        selectTab(.home, flow: sessionFlowsContainer.homeFlow())
    }
}

extension SidebarHostingViewController: TabSelectable {
    func selectTab(_ tab: ConnectedCoordinator.Tab) {
        guard let flow = defaultFlow(for: tab),
              let navigationItem = sessionFlowsContainer.flows.first(where: { $0.value.id == flow.id })?.key else {
            return
        }

        model.selection = navigationItem
    }

    func selectTab(_ tab: ConnectedCoordinator.Tab, flow: any TabFlow) {
        guard let navigationItem = sessionFlowsContainer.flows.first(where: { $0.value.id == flow.id })?.key else {
            return
        }

        model.selection = navigationItem
    }

    private func defaultFlow(for tab: ConnectedCoordinator.Tab) -> (any TabFlow)? {
        switch tab {
        case .home:
            return sessionFlowsContainer.flow(for: .home)
        case .vault:
            return sessionFlowsContainer.flow(for: .vault(.credentials))
        case .notifications:
            return sessionFlowsContainer.flow(for: .notifications)
        case .contacts:
            return sessionFlowsContainer.flow(for: .contacts)
        case .passwordGenerator:
            return sessionFlowsContainer.toolsFlow(for: .otherTool(.generator), and: .sidebar)?.flow
        case .tools:
            return sessionFlowsContainer.toolsFlow(for: .identityDashboard, and: .sidebar)?.flow
        case .settings:
            return sessionFlowsContainer.flow(for: .settings)
        }
    }
}
