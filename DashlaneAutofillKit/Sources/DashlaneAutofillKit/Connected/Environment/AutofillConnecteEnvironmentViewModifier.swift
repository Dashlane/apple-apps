import SwiftUI
import UIDelight

@ViewInit
struct AutofillConnectedEnvironmentViewModifier: ViewModifier {
  @StateObject
  var model: AutofillConnectedEnvironmentModel

  func body(content: Content) -> some View {
    content
      .environment(\.enabledFeatures, model.enabledFeaturesAtLogin)
      .environment(\.capabilities, model.capabilities)
      .environment(\.report, model.reportAction)
      .environment(\.richIconsEnabled, model.richIconsEnabled)
  }
}
