import CoreTypes
import LoginKit
import SwiftUI
import UIDelight

@ViewInit
struct ConnectedRootView: View {
  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  @StateObject
  var model: ConnectedRootViewModel

  let onLoginLockPlaceholder: Image

  var body: some View {
    connectedView
      .modifier(
        ConnectedEnvironmentViewModifier(model: model.connectedEnvironmentModelFactory.make())
      )
      .modifier(AccessControlRequestViewModifier(model: model.accessControlModelFactory.make()))
      .modifier(SecurityAuthTokenAlertModifier(model: model.securityAuthTokenAlertModel.make()))
      .modifier(BreachPopupAlertModifier(model: model.breachPopupAlertModelFactory.make()))
      .modifier(OnLoginUnlockAnimationModifier(onLoginLockPlaceholder: onLoginLockPlaceholder))
      .tint(.ds.accentColor)
  }

  @ViewBuilder
  var connectedView: some View {
    switch horizontalSizeClass {
    case .regular:
      ConnectedIpadMacRootView(model: model.ipadMacRootViewModelFactory.make())
    default:
      ConnectedIphoneRootView(model: model.iphoneRootViewModelFactory.make())
    }
  }
}
