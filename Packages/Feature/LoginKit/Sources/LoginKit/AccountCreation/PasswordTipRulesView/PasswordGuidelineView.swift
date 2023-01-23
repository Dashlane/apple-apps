import SwiftUI
import DesignSystem
import UIComponents
import UIDelight
import CoreLocalization

public struct PasswordGuidelineView: View {
    @ObservedObject
    var viewModel: PasswordGuidelineViewModel

    public init(viewModel: PasswordGuidelineViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
            Text(viewModel.title)
                .font(DashlaneFont.custom(17, .medium).font)
                .foregroundColor(.ds.text.neutral.quiet)
                .fixedSize(horizontal: false, vertical: true)

            MarkdownText(viewModel.list)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.ds.text.neutral.standard)

            story

        }.hidden(!Locale.current.isLatinBased)
    }

    @ViewBuilder
    var story: some View {
        viewModel.story.map {
            Text($0)
                .font(.subheadline)
                .foregroundColor(.ds.text.neutral.catchy)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(.ds.container.agnostic.neutral.supershy)
                .cornerRadius(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PasswordGuidelineView_Previews: PreviewProvider {

    static private var generalRulesBulletPointList: String {
        return [
            L10n.Core.zxcvbnSuggestionDefaultCommonPhrases,
            L10n.Core.zxcvbnSuggestionDefaultPersonalInfo,
            L10n.Core.zxcvbnSuggestionDefaultPasswordLength,
            L10n.Core.zxcvbnSuggestionDefaultObviousSubstitutions
            ].map({ "• \($0)" }).joined(separator: "\n")
    }

    static let viewModel = PasswordGuidelineViewModel(
        title: "The simplest method",
        list: generalRulesBulletPointList,
        story: "yooo")

    static var previews: some View {
        PasswordGuidelineView(viewModel: viewModel)
    }
}
