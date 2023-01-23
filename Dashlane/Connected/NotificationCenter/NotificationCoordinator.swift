import UIKit
import Combine
import CoreFeature
import SwiftUI
import DashlaneAppKit
import LoginKit

final class NotificationCoordinator: TabCoordinator {
    private var navigator: DashlaneNavigationController? {
        viewController as? DashlaneNavigationController
    }

    let sessionServices: SessionServicesContainer
    let notificationCenterService: NotificationCenterService

    let tabBarImage = NavigationImageSet(image: FiberAsset.tabAlertOff,
                                         selectedImage: FiberAsset.tabAlertOn)

    let sidebarImage = NavigationImageSet(image: FiberAsset.sidebarNotification,
                                          selectedImage: FiberAsset.sidebarNotificationSelected)

    let title: String = L10n.Localizable.tabNotificationsTitle

    let tag: Int = ConnectedCoordinator.Tab.notifications.tabBarIndexValue
    let id = UUID()

    var viewController: UIViewController
    let notificationListViewModel: NotificationsListViewModel

    private var subscriptions = Set<AnyCancellable>()

    init(sessionServices: SessionServicesContainer) {
        let notificationCenterService = sessionServices.makeNotificationCenterService()
        self.notificationCenterService = notificationCenterService
        self.notificationListViewModel = sessionServices.viewModelFactory.makeNotificationsListViewModel(notificationCenterService: notificationCenterService)
        let rootView = NotificationsListView(model: self.notificationListViewModel)
        self.viewController = UIHostingController(rootView: rootView)
        self.sessionServices = sessionServices
    }

    func start() {
        self.notificationCenterService
            .$unreadNotificationsCount
            .receive(on: DispatchQueue.main)
            .map { $0 > 0 ? String($0) : nil }
            .assign(to: \.tabBarItem.badgeValue, on: self.viewController)
            .store(in: &subscriptions)
    }

    func display(category: NotificationCategory) {
        notificationListViewModel.display(category: category)
    }
}
