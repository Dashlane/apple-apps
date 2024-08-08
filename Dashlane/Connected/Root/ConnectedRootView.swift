import DashTypes
import MacrosKit
import SwiftUI

@ViewInit
struct ConnectedRootView: View {
  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  @StateObject
  var model: ConnectedRootViewModel

  var body: some View {
    Group {
      switch horizontalSizeClass {
      case .regular:
        ConnectedIpadMacRootView(model: model.ipadMacRootViewModelFactory.make())
      default:
        ConnectedIphoneRootView(model: model.iphoneRootViewModelFactory.make())
      }
    }
    .modifier(
      ConnectedEnvironmentViewModifier(model: model.connectedEnvironmentModelFactory.make()))
  }
}
