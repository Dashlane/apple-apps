import CoreLocalization
import DesignSystem
import SwiftUI
import UIDelight

public struct AutofillBanner: View {
  @ObservedObject
  var model: AutofillBannerViewModel

  public init(model: AutofillBannerViewModel) {
    self.model = model
  }

  public var body: some View {
    HStack {
      Image.ds.feature.autofill.outlined
        .resizable()
        .frame(width: 20, height: 20)
      titleView
        .font(.footnote.weight(.medium))
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity)
    .foregroundStyle(Color.ds.text.inverse.standard)
    .background(.ds.container.expressive.brand.catchy.idle)
    .onTapGesture(perform: model.showAutofillDemo)
    .fiberAccessibilityElement(children: .ignore)
    .fiberAccessibilityAddTraits(.isButton)
    .accessibilityIdentifier(CoreL10n.autofillBannerTitleNotActive)
    .fiberAccessibilityLabel(Text(CoreL10n.credentialProviderOnboardingIntroTitle))
  }

  @ViewBuilder
  var titleView: some View {
    HStack {
      Text(CoreL10n.autofillBannerTitleNotActive)
        .fixedSize(horizontal: false, vertical: true)
        .fiberAccessibilityRemoveTraits(.isStaticText)
      Spacer()
      Text(CoreL10n.autofillBannerTitleCta)
        .fixedSize()
        .fiberAccessibilityRemoveTraits(.isStaticText)
    }
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AutofillBanner(model: AutofillBannerViewModel.mock)
}
