import UIKit
import SwiftUI
import Combine
import DashlaneAppKit
import SwiftTreats

class SidebarViewController: UIViewController {

    private lazy var collectionView: UICollectionView = setupCollectionView()
    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!
    private var tabCoordinators: [SidebarSectionCoordinators] = []
    private var settingsCoordinator: TabCoordinator!
    private var lastSectionSelected: IndexPath?
    private var sessionCoordinatorsContainer: SessionCoordinatorsContainer!

    private var cancellables = Set<AnyCancellable>()

    var didSelectTabCoordinator: ((TabCoordinator) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Dashlane"

        navigationController?.navigationBar.prefersLargeTitles = true
        configureDataSource()
        configureContent()

        selectHome()

                                collectionView.setContentOffset(.init(x: 0, y: -150), animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenForDetailsChangesOnTabs()
    }

    private func listenForDetailsChangesOnTabs() {
        tabCoordinators.forEach { tabCoordinator in
            tabCoordinator.coordinators.forEach { coordinator in
                coordinator.detailInformationValue?
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] value in
                        self?.refreshDetailForItemHaving(tabCoordinator: coordinator, detail: value)
                    }).store(in: &cancellables)
            }
        }
    }

}

extension SidebarViewController {
    func configure(with container: SessionCoordinatorsContainer) {
        self.sessionCoordinatorsContainer = container
        self.tabCoordinators = container.sidebarCoordinators()
        self.settingsCoordinator = container.coordinator(for: .settings)
        let settingsItem = UIBarButtonItem(image: settingsCoordinator.sidebarImage.image.image,
                                           style: .done,
                                           target: self,
                                           action: #selector(showSettings))
        settingsItem.accessibilityLabel = settingsCoordinator.title
        navigationItem.rightBarButtonItem = settingsItem
    }

    @objc func showSettings() {
        sessionCoordinatorsContainer.startCoordinatorIfNeeded(settingsCoordinator)
        if settingsCoordinator.viewController.parent != nil {
            settingsCoordinator.viewController.removeFromParent()
        }

        if Device.isMac {
                                                let container = ContainerViewController()
            container.controller = settingsCoordinator.viewController
            container.modalPresentationStyle = .formSheet
            if let navigator = settingsCoordinator.viewController as? UINavigationController {
                navigator.popToRootViewController(animated: false)
            }
            present(container, animated: true, completion: nil)
        } else {
            settingsCoordinator.viewController.modalPresentationStyle = .formSheet
            if let navigator = settingsCoordinator.viewController as? UINavigationController {
                navigator.popToRootViewController(animated: false)
            }
            present(settingsCoordinator.viewController, animated: true, completion: nil)
        }
        settingsCoordinator.restore()
    }
}

extension SidebarViewController {

    private func setupCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.accessibilityIdentifier = "Sidebar"
        view.addSubview(collectionView)
        return collectionView
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .firstItemInSection
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = -3
            return section
        }
        return layout
    }
}

extension SidebarViewController {

    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in

            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            cell.contentConfiguration = contentConfiguration
            cell.tintColor = .ds.text.neutral.standard
        }

        let rowRegistration = UICollectionView.CellRegistration<SidebarCollectionCell, SidebarItem> { (cell, _, item) in
            cell.item = item
            cell.accessibilityIdentifier = item.title
        }

        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in

            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
            }
        }

    }

    private func configureContent() {
        for tab in tabCoordinators {
            var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
            let section = SidebarSection(tabCoordinator: tab)

            if let title = tab.title {
                let header = SidebarItem.header(title: title, id: tab.id)
                snapshot.append([header])
                snapshot.expand([header])
                tab.coordinators.forEach {
                    let item = SidebarItem.row(tab: $0)
                    snapshot.append([item], to: header)
                }
            } else {
                tab.coordinators.forEach {
                    let item = SidebarItem.row(tab: $0)
                    snapshot.append([item])
                }
            }
            dataSource.apply(snapshot, to: section)
        }
    }

    func refreshDetailForItemHaving(tabCoordinator: TabCoordinator, detail: TabElementDetail) {
        var snapshot = dataSource.snapshot()
        guard let item = snapshot.itemIdentifiers.first(where: { $0.tabCoordinator === tabCoordinator }) else {
            return
        }
        guard item.detail != detail else { return }
        item.detail = detail
        guard let section = snapshot.sectionIdentifier(containingItem: item) else { return }
        guard let item = snapshot.itemIdentifiers(inSection: section).first(where: { $0.id == item.id }) else {
            assertionFailure()
            return
        }
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
}

extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath), let tabCoordinator = sidebarItem.tabCoordinator else { return }
        guard let splitViewController = splitViewController else {
            assertionFailure("We should have a splitviewcontroller.")
            return
        }

        guard lastSectionSelected != indexPath else {
            return
        }

        sessionCoordinatorsContainer.startCoordinatorIfNeeded(tabCoordinator)

                splitViewController.setViewController(nil, for: .secondary)
        splitViewController.setViewController(tabCoordinator.viewController, for: .secondary)

        tabCoordinator.restore()

        lastSectionSelected = indexPath
        if viewIfLoaded?.window != nil {
                                    didSelectTabCoordinator?(tabCoordinator)
        }
    }
}

extension SidebarViewController: TabSelectable {

    func selectHome() {
        selectTab(.home, coordinator: sessionCoordinatorsContainer.homeCoordinator())
    }

    func selectTab(_ tab: ConnectedCoordinator.Tab, coordinator: TabCoordinator?) {

        guard let targetCoordinator = coordinator ?? defaultCoordinator(fot: tab) else {
            return
        }

        guard let sectionIndex = self.tabCoordinators.firstIndex(where: { tabCoordinator in tabCoordinator.coordinators.contains(where: { $0 === targetCoordinator })}) else {
            return
        }
        let tabCoordinator = self.tabCoordinators[sectionIndex]
        guard let rowIndex = tabCoordinator.coordinators.firstIndex(where: { $0 === targetCoordinator }) else {
            return
        }

        let indexPath: IndexPath

        if tabCoordinator.coordinators.count == 1 {
            indexPath = IndexPath(row: 0, section: sectionIndex)
        } else if tabCoordinator.title == nil {
            indexPath = IndexPath(row: rowIndex, section: sectionIndex)
        } else {
            indexPath = IndexPath(row: rowIndex + 1, section: sectionIndex)
        }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        collectionView(collectionView, didSelectItemAt: indexPath)
    }

    private func defaultCoordinator(fot tab: ConnectedCoordinator.Tab) -> TabCoordinator? {
        switch tab {
        case .home:
            return sessionCoordinatorsContainer.coordinator(for: .home)
        case .vault:
            return sessionCoordinatorsContainer.coordinator(for: .vault(.credentials))
        case .notifications:
            return sessionCoordinatorsContainer.coordinator(for: .notifications)
        case .contacts:
            return sessionCoordinatorsContainer.contactsCoordinator()
        case .passwordGenerator:
            return sessionCoordinatorsContainer.toolsCoordinator(for: .otherTool(.generator), and: .sidebar)?.coordinator
        case .tools:
            return sessionCoordinatorsContainer.toolsCoordinator(for: .identityDashboard, and: .sidebar)?.coordinator
        case .settings:
            return sessionCoordinatorsContainer.settingsCoordinator()
        }
    }
}
