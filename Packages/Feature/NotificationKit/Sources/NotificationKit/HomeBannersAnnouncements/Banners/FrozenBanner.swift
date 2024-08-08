import CoreLocalization
import DesignSystem
import SwiftUI

public struct FrozenBanner: View {
  @StateObject
  var model: FrozenBannerViewModel

  public init(model: @autoclosure @escaping () -> FrozenBannerViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    Infobox(L10n.Core.frozenAccountTitle, description: L10n.Core.frozenAccountMessage) {
      Button(L10n.Core.frozenAccountAction) {
        model.displayPaywall()
      }
    }
    .style(mood: .danger)
  }
}

#Preview("FrozenBanner") {
  FrozenBanner(model: .mock)
}
