import Foundation
import VaultKit

enum NavigationStyle {
  case tabBar
  case sidebar
}

@MainActor
class SessionCoordinatorsContainer {

  let sessionServices: SessionServicesContainer

  private(set) var coordinators = [NavigationItem: TabCoordinator]()
  private var startedCoordinators = Set<UUID>()

  struct SectionItem {
    let title: String?
    let items: [NavigationItem]
  }

  init(sessionServices: SessionServicesContainer) {
    self.sessionServices = sessionServices
  }

  var tabBarElements: [NavigationItem] {
    [
      .home,
      .notifications,
      .passwordGenerator,
      .tools(nil),
      .settings,
    ]
  }

  var sidebarElements: [SectionItem] {
    [
      .init(
        title: nil,
        items: [.home, .notifications]),
      .init(
        title: L10n.Localizable.tabVaultTitle,
        items: vaultSectionNavigationItems(sessionServices: sessionServices)),
      .init(
        title: L10n.Localizable.sidebarToolsTitle,
        items: toolsNavigationItems(sessionServices: sessionServices)),
    ]
  }
}

@MainActor
extension SessionCoordinatorsContainer {
  private func makeCoordinator(for item: NavigationItem) -> TabCoordinator {
    switch item {
    case .home:
      return sessionServices.makeHomeFlowViewModel()
    case let .vault(item):
      return sessionServices.makeVaultFlowViewModel(itemCategory: item)
    case .contacts:
      return sessionServices.makeSharingToolsFlowViewModel()
    case let .tools(item):
      return sessionServices.makeToolsFlowViewModel(toolsItem: item)
    case .settings:
      return SettingsCoordinator(sessionServices: sessionServices)
    case .notifications:
      return sessionServices.makeNotificationsFlowViewModel(
        notificationCenterService: sessionServices.makeNotificationCenterService())
    case .passwordGenerator:
      return sessionServices.makePasswordGeneratorToolsFlowViewModel(
        pasteboardService: PasteboardService(userSettings: sessionServices.userSettings))
    }
  }

  func coordinator(for item: NavigationItem) -> TabCoordinator {
    if let coordinator = coordinators[item] {
      return coordinator
    }
    let coordinator = makeCoordinator(for: item)
    coordinators[item] = coordinator
    return coordinator
  }
}

@MainActor
extension SessionCoordinatorsContainer {
  func tabBarCoordinators() -> [TabCoordinator] {
    return
      tabBarElements
      .map {
        return self.coordinator(for: $0)
      }
  }
}

struct SidebarSectionCoordinators: Hashable {
  let id = UUID()
  let title: String?
  let coordinators: [TabCoordinator]

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: SidebarSectionCoordinators, rhs: SidebarSectionCoordinators) -> Bool {
    lhs.id == rhs.id
  }
}

@MainActor
extension SessionCoordinatorsContainer {
  func sidebarCoordinators() -> [SidebarSectionCoordinators] {
    let coordinators: [SidebarSectionCoordinators] = sidebarElements.map({
      (section) -> SidebarSectionCoordinators in
      let sidebarCoordinators = section.items.map {
        return self.coordinator(for: $0)
      }
      return .init(title: section.title, coordinators: sidebarCoordinators)
    })

    return coordinators
  }

  func startCoordinatorIfNeeded(_ coordinator: TabCoordinator) {
    if !startedCoordinators.contains(coordinator.id) {
      startedCoordinators.insert(coordinator.id)
      coordinator.start()
    }
  }
}

extension SessionCoordinatorsContainer {

  fileprivate func vaultSectionNavigationItems(sessionServices: SessionServicesContainer)
    -> [NavigationItem]
  {
    return vaultNavigationItems(sessionServices: sessionServices) + [.contacts]
  }

  fileprivate func vaultNavigationItems(sessionServices: SessionServicesContainer)
    -> [NavigationItem]
  {
    ItemCategory.allCases
      .filter({ $0.showable(sessionServices: sessionServices) })
      .map({ .vault($0) })
  }
}

extension SessionCoordinatorsContainer {
  fileprivate func toolsNavigationItems(sessionServices: SessionServicesContainer)
    -> [NavigationItem]
  {
    sessionServices.toolsService.availableNavigationToolItems().map({ .tools($0) })
  }
}
