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

  @Published
  var unreadNotificationsCount: Int = 0

  convenience init(
    notificationCenterService: NotificationCenterService.Factory,
    deeplinkService: DeepLinkingServiceProtocol,
    notificationsListViewModelFactory: NotificationsListViewModel.Factory
  ) {
    self.init(
      notificationCenterService: notificationCenterService.make(),
      deeplinkService: deeplinkService,
      notificationsListViewModelFactory: notificationsListViewModelFactory)
  }

  init(
    notificationCenterService: NotificationCenterServiceProtocol,
    deeplinkService: DeepLinkingServiceProtocol,
    notificationsListViewModelFactory: NotificationsListViewModel.Factory
  ) {
    self.notificationCenterService = notificationCenterService
    self.deeplinkService = deeplinkService.notificationsDeeplinkPublisher()
    self.notificationListViewModel = notificationsListViewModelFactory.make(
      notificationCenterService: notificationCenterService)

    notificationCenterService
      .$unreadNotificationsCount
      .receive(on: DispatchQueue.main)
      .assign(to: &$unreadNotificationsCount)
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
