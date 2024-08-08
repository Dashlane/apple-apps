import CoreLocalization
import DashTypes
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct AuthenticatorSunsetView: View {

  @State
  private var isLearnMoreDisplayed: Bool = false

  let cardContent = [
    CoreLocalization.L10n.Core.authenticatorSunsetRelocateStep1,
    CoreLocalization.L10n.Core.authenticatorSunsetRelocateStep2,
    CoreLocalization.L10n.Core.authenticatorSunsetRelocateStep3,
  ]

  public init() {
  }

  public var body: some View {
    VStack(alignment: .leading) {
      ScrollView {
        VStack(alignment: .leading, spacing: 48) {
          header
            .padding(.trailing)

          InstructionsCardView(cardContent: cardContent)
            .frame(maxWidth: .infinity)
        }
      }
      Spacer()
      buttons
        .padding(.bottom)
    }
    .padding(.horizontal, 24)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    .safariSheet(isPresented: $isLearnMoreDisplayed, url: DashlaneURLFactory.aboutAuthenticator)
    .toolbar(.hidden, for: .tabBar)
    .navigationTitle(CoreLocalization.L10n.Core.authenticatorSunsetRelocatePage)
  }

  var header: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(CoreLocalization.L10n.Core.authenticatorSunsetRelocateTitle)
        .font(.largeTitle)
        .foregroundColor(.ds.text.neutral.catchy)
      Text(CoreLocalization.L10n.Core.authenticatorSunsetRelocateSubtitle)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)

    }
    .padding(.top, 16)
  }

  var buttons: some View {
    VStack(spacing: 24) {
      Button(
        action: { UIApplication.shared.open(URL(string: "dashlane:///settings/security")!) },
        label: {
          Text(CoreLocalization.L10n.Core.authenticatorSunsetRelocateActionOpenSettings)
            .frame(maxWidth: .infinity)
        })

      Button(
        action: { isLearnMoreDisplayed.toggle() },
        label: {
          Text(CoreLocalization.L10n.Core.authenticatorSunsetRelocateActionLearnMore)
            .frame(maxWidth: .infinity)
        }
      )
      .style(intensity: .supershy)
    }
    .buttonStyle(.designSystem(.titleOnly))
  }
}

#Preview("AuthenticatorSunsetView") {
  MultiContextPreview(dynamicTypePreview: true) {
    AuthenticatorSunsetView()
  }
}
