import SwiftUI
import CorePersonalData
import VaultKit
import DesignSystem
import UIDelight
import UIComponents

struct CredentialLinkingView: View {

    let model: CredentialLinkingViewModel

    @ScaledMetric
    var titleFontSize: CGFloat = 26
    @ScaledMetric
    var messageFontSize: CGFloat = 15

    var body: some View {
        VStack {
            Spacer()

            Text(titleString)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(DashlaneFont.custom(titleFontSize, .medium).font)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.top)
                .padding(.bottom, 6)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.01)

            Text(messageString)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(DashlaneFont.custom(messageFontSize, .regular).font)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.01)

            credentialBlock

            Spacer()

            RoundedButton(L10n.Localizable.tachyonLinkingCredentialCtaLink, action: model.link)
                .padding(.top, 15)
                .roundedButtonLayout(.fill)

            RoundedButton(L10n.Localizable.tachyonLinkingCredentialCtaIgnore, action: model.ignore)
                .padding(.bottom, 20)
                .style(mood: .neutral, intensity: .supershy)
        }
        .padding(.horizontal, 20)
        .bottomSheetBackground(.ds.background.alternate)
    }

    var credentialBlock: some View {
        VStack(spacing: 5) {
            VaultItemIconView(isListStyle: true, model: model.makeIconViewModel())
                .padding(.bottom, 5)

            if !model.credential.displayTitle.isEmpty {
                Text(model.credential.displayTitle)
                    .foregroundColor(.ds.text.neutral.catchy)
            }
            if !model.credential.email.isEmpty {
                Text(model.credential.email)
                    .foregroundColor(.ds.text.neutral.standard)
                    .font(.system(.footnote))
            }
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 22)
        .background(.ds.container.agnostic.neutral.supershy)
        .cornerRadius(8.0)
    }

    private var titleString: AttributedString {
        var markdownLabel = L10n.Localizable.tachyonLinkingCredentialTitle(model.visitedWebsite)
        markdownLabel = markdownLabel.replacingOccurrences(of: model.visitedWebsite, with: "**\(model.visitedWebsite)**")
        return (try? AttributedString(markdown: markdownLabel)) ?? AttributedString(markdownLabel)
    }

    private var messageString: AttributedString {
        var markdownLabel = L10n.Localizable.tachyonLinkingCredentialMessage(model.credential.displayTitle, model.visitedWebsite)
        for boldString in [model.credential.displayTitle, model.visitedWebsite] {
            markdownLabel = markdownLabel.replacingOccurrences(of: boldString, with: "**\(boldString)**")
        }
        return (try? AttributedString(markdown: markdownLabel)) ?? AttributedString(markdownLabel)
    }
}
