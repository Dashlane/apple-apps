import Combine
import MacrosKit
import SwiftUI
import UIDelight

@ViewInit
struct NotificationsFlow: View {
  @StateObject
  var viewModel: NotificationsFlowViewModel

  var body: some View {
    NotificationsListView(model: viewModel.notificationListViewModel)
      .badge(viewModel.unreadNotificationsCount)
  }
}
