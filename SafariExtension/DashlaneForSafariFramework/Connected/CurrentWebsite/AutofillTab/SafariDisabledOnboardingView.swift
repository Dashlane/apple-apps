import SwiftUI

import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import DesignSystem

struct SafariDisabledOnboardingView: View {

    private let helpCenterURL: String = "_"

    var body: some View {
        VStack(spacing: 0) {
            image
            Spacer()
            informationText
            Spacer()
            helpCenterButton
        }
        .padding(.top, -8) 
    }

    @ViewBuilder
    private var image: some View {
        Image(asset: SharedAsset.safariDisabled)
            .frame(maxWidth: 400)
    }

    @ViewBuilder
    private var informationText: some View {
        VStack(spacing: 0) {
            Text(L10n.Localizable.onboardingSafariDisabledTitle)
                .multilineTextAlignment(.center)
                .font(DashlaneFont.custom(20, .medium).font)
                .foregroundColor(.ds.text.neutral.catchy)
                .padding(.bottom, 8)

            Text(attributedDescription)
                .multilineTextAlignment(.center)
                .font(.body.weight(.light))
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.bottom, 13)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }

    private var helpCenterButton: some View {
        Button(L10n.Localizable.onboardingSafariDisabledCta, action: openHelpCenter)
            .buttonStyle(DashlaneDefaultButtonStyle())
            .frame(height: 32)
            .padding(.bottom, 34)
            .font(.system(size: 13, weight: .medium))

    }

    private func openHelpCenter() {
        guard let url = URL(string: helpCenterURL) else { return }
        _ = NSWorkspace.shared.open(url)
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
        }

        return attributedString
    }

}

struct SafariDisabledOnboardingView_Previews: PreviewProvider {

    static var previews: some View {
                MultiContextPreview(deviceRange: .some([.iPadPro])) {
            SafariDisabledOnboardingView()
        }
    }
}
