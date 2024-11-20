import CoreLocalization
import CoreUserTracking
import DesignSystem
import SwiftUI

public struct AccountCreationSurveyView: View {
  var completion: ((Choice) -> Void)?

  public init(completion: ((Choice) -> Void)? = nil) {
    self.completion = completion
  }

  public enum Choice: CaseIterable, Identifiable, Sendable {
    case neverUsedPWM
    case alreadyUsedPWM
    case knowDashlane

    var question: String {
      switch self {
      case .neverUsedPWM:
        return L10n.Core.accountCreationSurveyChoiceNeverUsedPWM
      case .alreadyUsedPWM:
        return L10n.Core.accountCreationSurveyChoiceAlreadyUsedPWM
      case .knowDashlane:
        return L10n.Core.accountCreationSurveyChoiceKnowDashlane
      }
    }

    public var id: String {
      question
    }
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(L10n.Core.accountCreationSurveyTitle)
          .textStyle(.specialty.brand.small)
          .foregroundColor(.ds.text.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.leading, 16)
          .padding(.bottom, 16)
          .padding(.top, 52)
          .textCase(nil)

        ForEach(Choice.allCases) { choice in

          Button(
            action: {
              self.completion?(choice)
            },
            label: {
              Text(choice.question)
                .textStyle(.body.standard.regular)
                .multilineTextAlignment(.leading)
                .foregroundColor(.ds.text.neutral.standard)
                .padding(.vertical, 26)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                  RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color.ds.container.agnostic.neutral.supershy)
                )
                .padding(.horizontal)
                .padding(.vertical, 6)
            })
        }

        Spacer()
      }
    }
    .loginAppearance(backgroundColor: .ds.background.alternate)
    .reportPageAppearance(.userProfilingFamiliarityWithDashlane)
  }
}

struct AccountCreationSurveyView_Previews: PreviewProvider {
  static var previews: some View {
    AccountCreationSurveyView()
  }
}
