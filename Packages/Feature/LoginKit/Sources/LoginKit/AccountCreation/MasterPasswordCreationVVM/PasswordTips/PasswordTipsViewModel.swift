import CoreLocalization
import Foundation

class PasswordTipsViewModel {
  lazy var generalRules = PasswordGuidelineViewModel(
    title: L10n.Core.zxcvbnDefaultPopupTitle,
    list: generalRulesBulletPointList)
  lazy var simpleRules = PasswordGuidelineViewModel(
    title: L10n.Core.passwordTipsStoryMethodTitle,
    list: L10n.Core.passwordTipsStoryMethodDescription,
    story: L10n.Core.passwordTipsStoryMethodExample)
  lazy var difficultRules = PasswordGuidelineViewModel(
    title: L10n.Core.passwordTipsSeriesOfWordsMethodTitle,
    list: L10n.Core.passwordTipsSeriesOfWordsMethodDescription,
    story: L10n.Core.passwordTipsSeriesOfWordsMethodExample)
  lazy var advancedRules = PasswordGuidelineViewModel(
    title: L10n.Core.passwordTipsFirstCharactersMethodTitle,
    list: L10n.Core.passwordTipsFirstCharactersMethodDescription,
    story: L10n.Core.passwordTipsFirstCharactersMethodExample)

  private var generalRulesBulletPointList: String {
    return [
      CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultCommonPhrases,
      CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultPersonalInfo,
      CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultPasswordLength,
      CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultObviousSubstitutions,
    ]
    .map({ "• \($0)" }).joined(separator: "\n")
  }

}
