import SwiftUI
import UIDelight
import Combine

struct NotificationsFlow: TabFlow {
        let tag: Int = ConnectedCoordinator.Tab.notifications.tabBarIndexValue
    let id: UUID = .init()
    let title: String = L10n.Localizable.tabNotificationsTitle
    let tabBarImage: NavigationImageSet = NavigationImageSet(
        image: .ds.notification.outlined,
        selectedImage: .ds.notification.filled
    )

    let badgeValue: CurrentValueSubject<String?, Never>?

    @ObservedObject
    var viewModel: NotificationsFlowViewModel

    init(viewModel: NotificationsFlowViewModel) {
        self.viewModel = viewModel
        self.badgeValue = viewModel.badgeValues
    }

    var body: some View {
        NotificationsListView(model: viewModel.notificationListViewModel)
        .onReceive(viewModel.deeplinkService) { category in
            self.viewModel.display(category: category)
        }
    }
}
