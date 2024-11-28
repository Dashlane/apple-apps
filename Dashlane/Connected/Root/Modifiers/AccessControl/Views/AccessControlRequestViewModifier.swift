import DashTypes
import LoginKit
import MacrosKit
import SwiftUI

@ViewInit
struct AccessControlRequestViewModifier: ViewModifier {
  @StateObject var model: AccessControlRequestViewModifierModel

  func body(content: Content) -> some View {
    content
      .overFullScreen(item: $model.userVerificationRequest, mode: .topMost) { request in
        AccessControlView(model: model.makeAccessViewModel(request: request))
      }
      .environment(\.accessControl, model.accessControl)
  }
}

extension EnvironmentValues {
  @EnvironmentValue
  var accessControl: AccessControlHandler = .default
}
