import CoreLocalization
import DesignSystem
import SwiftUI

public struct FrozenBanner: View {
  @StateObject
  var model: FrozenBannerViewModel
  @Environment(\.openURL) var openURL

  public init(model: @autoclosure @escaping () -> FrozenBannerViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    Infobox(CoreL10n.frozenAccountTitle, description: CoreL10n.frozenAccountMessage) {
      Button(CoreL10n.frozenAccountAction) {
        model.displayPaywall()
      }

      Button {
        openURL(URL(string: "_")!)
      } label: {
        Label(CoreL10n.FrozenBanner.learnMoreButton, icon: .ds.action.openExternalLink.outlined)
      }
      .buttonStyle(.designSystem(.iconTrailing))
    }
    .style(mood: .danger)
  }
}

#Preview("FrozenBanner") {
  FrozenBanner(model: .mock)
}
