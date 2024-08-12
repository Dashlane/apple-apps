import NotificationKit
import SwiftUI
import UIDelight

struct ResetMasterPasswordNotificationRowView: View {
  let model: ResetMasterPasswordNotificationRowViewModel

  @State
  private var showResetMPFlow: Bool = false

  var body: some View {
    BaseNotificationRowView(
      icon: model.notification.icon,
      title: model.notification.title,
      description: model.notification.description
    ) {
      self.showResetMPFlow = true
    }
    .sheet(isPresented: $showResetMPFlow) {
      ResetMasterPasswordIntro(viewModel: model.resetMasterPasswordIntroViewModelFactory.make())
    }
  }
}

struct ResetMasterPasswordNotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ResetMasterPasswordNotificationRowView(
        model: ResetMasterPasswordNotificationRowViewModel.mock)
    }
  }
}
