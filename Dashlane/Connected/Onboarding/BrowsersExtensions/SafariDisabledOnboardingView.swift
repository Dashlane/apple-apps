#if targetEnvironment(macCatalyst)
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import DesignSystem
import CoreLocalization

struct SafariDisabledOnboardingView: View {

    let completion: () -> Void

    private let helpCenterURL: String = "_"

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            image
            informationText
            Spacer()
            helpCenterButton
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: completion, title: CoreLocalization.L10n.Core.kwButtonClose)
                    .foregroundColor(.ds.text.brand.standard)
            }
        }
    }

    @ViewBuilder
    private var image: some View {
        Image(asset: FiberAsset.safariDisabled)
            .frame(maxWidth: 480)
            .padding(.horizontal, 16)
            .padding(.bottom, 56)
    }

    @ViewBuilder
    private var informationText: some View {
        VStack(spacing: 0) {
            Text(L10n.Localizable.onboardingSafariDisabledTitle)
                .multilineTextAlignment(.center)
                .font(DashlaneFont.custom(28, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .padding(.bottom, 8)

            Text(attributedDescription)
                .multilineTextAlignment(.center)
                .font(.body.weight(.light))
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: 480)
    }

    private var helpCenterButton: some View {
        RoundedButton(L10n.Localizable.onboardingSafariDisabledCta, action: openHelpCenter)
            .roundedButtonLayout(.fill)
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
            .frame(maxWidth: 320)
    }

    private func openHelpCenter() {
        guard let url = URL(string: helpCenterURL) else { return }
        UIApplication.shared.open(url)
    }
}

private extension SafariDisabledOnboardingView {

    var attributedDescription: AttributedString {
        let troubleshootString = L10n.Localizable.onboardingSafariDisabledSubtitleLink
        let troubleshootURL = URL(string: helpCenterURL)!
        let descriptionString = L10n.Localizable.onboardingSafariDisabledSubtitle

        return attributedString(for: descriptionString, hyperlinks: [troubleshootString: troubleshootURL])
    }

    private func attributedString(for string: String, hyperlinks: [String: URL]) -> AttributedString {
        var defaultAttributes = AttributeContainer()
        defaultAttributes.foregroundColor = .ds.text.neutral.standard

        var attributedString = AttributedString(string, attributes: defaultAttributes)

        for (text, url) in hyperlinks {
            guard let range = attributedString.range(of: text) else { continue }
            attributedString[range].link = url
            attributedString[range].underlineStyle = .single
            attributedString[range].underlineColor = .ds.text.neutral.standard
        }

        return attributedString
    }

}

struct SafariDisabledOnboardingView_Previews: PreviewProvider {

    static var previews: some View {
                MultiContextPreview(deviceRange: .some([.iPadPro])) {
            SafariDisabledOnboardingView(completion: { })
        }
    }
}
#endif
