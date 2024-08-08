import CorePremium
import MacrosKit
import SwiftUI
import VaultKit

@ViewInit
struct ConnectedEnvironmentViewModifier: ViewModifier {
  @StateObject
  var model: ConnectedEnvironmentModel

  func body(content: Content) -> some View {
    content
      .environment(\.enabledFeatures, model.enabledFeaturesAtLogin)
      .environment(\.capabilities, model.capabilities)
      .environment(\.report, model.reportAction)
      .environment(\.richIconsEnabled, model.richIconsEnabled)
      .environment(\.spacesConfiguration, model.spacesConfiguration)
  }
}

extension EnvironmentValues {
  @EnvironmentValue
  var spacesConfiguration: UserSpacesService.SpacesConfiguration = .init()
}
