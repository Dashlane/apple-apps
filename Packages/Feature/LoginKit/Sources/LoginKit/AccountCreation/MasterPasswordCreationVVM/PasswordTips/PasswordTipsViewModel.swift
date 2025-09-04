import CoreLocalization
import Foundation

class PasswordTipsViewModel {
  lazy var generalRules = PasswordGuidelineViewModel(
    title: CoreL10n.zxcvbnDefaultPopupTitle,
    list: generalRulesBulletPointList)
  lazy var simpleRules = PasswordGuidelineViewModel(
    title: CoreL10n.passwordTipsStoryMethodTitle,
    list: CoreL10n.passwordTipsStoryMethodDescription,
    story: CoreL10n.passwordTipsStoryMethodExample)
  lazy var difficultRules = PasswordGuidelineViewModel(
    title: CoreL10n.passwordTipsSeriesOfWordsMethodTitle,
    list: CoreL10n.passwordTipsSeriesOfWordsMethodDescription,
    story: CoreL10n.passwordTipsSeriesOfWordsMethodExample)
  lazy var advancedRules = PasswordGuidelineViewModel(
    title: CoreL10n.passwordTipsFirstCharactersMethodTitle,
    list: CoreL10n.passwordTipsFirstCharactersMethodDescription,
    story: CoreL10n.passwordTipsFirstCharactersMethodExample)

  private var generalRulesBulletPointList: String {
    return [
      CoreL10n.zxcvbnSuggestionDefaultCommonPhrases,
      CoreL10n.zxcvbnSuggestionDefaultPersonalInfo,
      CoreL10n.zxcvbnSuggestionDefaultPasswordLength,
      CoreL10n.zxcvbnSuggestionDefaultObviousSubstitutions,
    ]
    .map({ "• \($0)" }).joined(separator: "\n")
  }

}
