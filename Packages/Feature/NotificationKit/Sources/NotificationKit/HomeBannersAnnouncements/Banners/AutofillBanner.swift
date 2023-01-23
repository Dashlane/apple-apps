import SwiftUI
import UIDelight
import DesignSystem
import CoreLocalization

public struct AutofillBanner: View {
    @ObservedObject
    var model: AutofillBannerViewModel

    public init(model: AutofillBannerViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            Image(asset: Asset.activateAutofillIcon)
                .resizable()
                .frame(width: 20, height: 20)
            titleView
                .font(.footnote.weight(.medium))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .foregroundColor(.ds.text.inverse.standard)
        .background(.ds.container.expressive.brand.catchy.idle)
        .onTapGesture(perform: model.showAutofillDemo)
        .fiberAccessibilityElement(children: .ignore)
        .fiberAccessibilityAddTraits(.isButton)
        .accessibilityIdentifier(L10n.Core.autofillBannerTitleNotActive)
        .fiberAccessibilityLabel(Text(L10n.Core.credentialProviderOnboardingIntroTitle))
    }

    @ViewBuilder
    var titleView: some View {
        HStack {
            Text(L10n.Core.autofillBannerTitleNotActive)
                .fixedSize(horizontal: false, vertical: true)
                .fiberAccessibilityRemoveTraits(.isStaticText)
            Spacer()
            Text(L10n.Core.autofillBannerTitleCta)
                .fixedSize()
                .fiberAccessibilityRemoveTraits(.isStaticText)
        }
    }
}

struct AutofillBanner_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AutofillBanner(model: AutofillBannerViewModel.mock)
                .previewLayout(.sizeThatFits)
        }
    }
}
