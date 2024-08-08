import CoreLocalization
import DashTypes
import DesignSystem
import SwiftUI

public struct AuthenticatorSunsetBanner: View {
  @StateObject
  var model: AuthenticatorSunsetBannerViewModel

  public init(model: @autoclosure @escaping () -> AuthenticatorSunsetBannerViewModel) {
    self._model = .init(wrappedValue: model())
  }

  public var body: some View {
    Infobox(
      CoreLocalization.L10n.Core.authenticatorSunsetBannerTitle(model.sunsetDate),
      description: model.isPairedWithAuthenticator()
        ? CoreLocalization.L10n.Core.authenticatorSunsetBannerRelocateDescription
        : CoreLocalization.L10n.Core.authenticatorSunsetBannerAccessDescription
    ) {

      Button(CoreLocalization.L10n.Core.authenticatorSunsetBannerLearnMore) {
        model.learnMore()
      }
      Button(CoreLocalization.L10n.Core.authenticatorSunsetBannerDismiss) {
        model.dismiss()
      }
    }
    .style(mood: .brand)
    .safariSheet(isPresented: $model.displayHelpCenter, url: DashlaneURLFactory.aboutAuthenticator)
  }
}

#Preview("AuthenticatorSunsetBanner") {
  AuthenticatorSunsetBanner(model: .mock)
}
