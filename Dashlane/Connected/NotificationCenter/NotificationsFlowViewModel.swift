import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
class NotificationsFlowViewModel: ObservableObject, SessionServicesInjecting {

    let notificationListViewModel: NotificationsListViewModel
    let badgeValues: CurrentValueSubject<String?, Never>? = .init("")
    let deeplinkService: AnyPublisher<NotificationCategory, Never>

    private let notificationCenterService: NotificationCenterServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        notificationCenterService: NotificationCenterServiceProtocol,
        deeplinkService: DeepLinkingServiceProtocol,
        notificationsListViewModelFactory: NotificationsListViewModel.Factory
    ) {
        self.notificationCenterService = notificationCenterService
        self.deeplinkService = deeplinkService.notificationsDeeplinkPublisher()
        self.notificationListViewModel = notificationsListViewModelFactory.make(notificationCenterService: notificationCenterService)

        notificationCenterService
            .$unreadNotificationsCount
            .receive(on: DispatchQueue.main)
            .map { $0 > 0 ? String($0) : nil }
            .sink { [weak self] value in
                self?.badgeValues?.send(value)
            }
            .store(in: &cancellables)
    }

    func display(category: NotificationCategory) {
        notificationListViewModel.display(category: category)
    }
}

extension NotificationsFlowViewModel {
    static func mock() -> NotificationsFlowViewModel {
        .init(
            notificationCenterService: NotificationCenterService.mock,
            deeplinkService: DeepLinkingService.fakeService,
            notificationsListViewModelFactory: .init { _ in .mock }
        )
    }
}
