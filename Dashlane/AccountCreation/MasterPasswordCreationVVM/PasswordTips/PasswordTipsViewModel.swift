import Foundation
import LoginKit
import CoreLocalization

class PasswordTipsViewModel {
    lazy var generalRules = PasswordGuidelineViewModel(title: L10n.Localizable.zxcvbnDefaultPopupTitle,
                                                       list: generalRulesBulletPointList)
    lazy var simpleRules = PasswordGuidelineViewModel(title: L10n.Localizable.passwordTipsStoryMethodTitle,
                                                      list: L10n.Localizable.passwordTipsStoryMethodDescription,
                                                      story: L10n.Localizable.passwordTipsStoryMethodExample)
    lazy var difficultRules = PasswordGuidelineViewModel(title: L10n.Localizable.passwordTipsSeriesOfWordsMethodTitle,
                                                         list: L10n.Localizable.passwordTipsSeriesOfWordsMethodDescription,
                                                         story: L10n.Localizable.passwordTipsSeriesOfWordsMethodExample)
    lazy var advancedRules = PasswordGuidelineViewModel(title: L10n.Localizable.passwordTipsFirstCharactersMethodTitle,
                                                        list: L10n.Localizable.passwordTipsFirstCharactersMethodDescription,
                                                         story: L10n.Localizable.passwordTipsFirstCharactersMethodExample)

    private var generalRulesBulletPointList: String {
        return [
            CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultCommonPhrases,
            CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultPersonalInfo,
            CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultPasswordLength,
            CoreLocalization.L10n.Core.zxcvbnSuggestionDefaultObviousSubstitutions
            ]
            .map({ "• \($0)" }).joined(separator: "\n")
    }

}
