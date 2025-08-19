import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct PasswordGuidelineView: View {
  @ObservedObject
  var viewModel: PasswordGuidelineViewModel

  public init(viewModel: PasswordGuidelineViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    if Locale.current.isLatinBased {
      VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
        Text(viewModel.title)
          .textStyle(.title.block.medium)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .fixedSize(horizontal: false, vertical: true)

        MarkdownText(viewModel.list)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .textStyle(.body.standard.regular)

        story
      }
    }
  }

  @ViewBuilder
  var story: some View {
    viewModel.story.map {
      Text($0)
        .font(.subheadline)
        .foregroundStyle(Color.ds.text.neutral.catchy)
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
      CoreL10n.zxcvbnSuggestionDefaultCommonPhrases,
      CoreL10n.zxcvbnSuggestionDefaultPersonalInfo,
      CoreL10n.zxcvbnSuggestionDefaultPasswordLength,
      CoreL10n.zxcvbnSuggestionDefaultObviousSubstitutions,
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
