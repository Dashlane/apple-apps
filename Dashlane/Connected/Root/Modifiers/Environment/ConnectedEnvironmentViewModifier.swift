import CorePremium
import CoreSession
import SwiftUI
import UIDelight
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
      .environment(\.copy, model.copyAction)
      .environment(\.authenticationMethod, model.session.authenticationMethod)
  }
}

extension EnvironmentValues {
  @Entry var spacesConfiguration: UserSpacesService.SpacesConfiguration = .init()
  @Entry var copy: (String) -> Void = UIPasteboard.general.copy
}
