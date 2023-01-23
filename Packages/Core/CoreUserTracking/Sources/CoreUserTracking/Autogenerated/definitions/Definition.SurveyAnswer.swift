import Foundation

extension Definition {

public enum `SurveyAnswer`: String, Encodable {
case `autofillDidntWorkAsExpected` = "autofill_didnt_work_as_expected"
case `dashlaneDoesntHaveTheFeaturesINeed` = "dashlane_doesnt_have_the_features_i_need"
case `dashlaneIsTooExpensive` = "dashlane_is_too_expensive"
case `thereWereTooManyTechnicalIssues` = "there_were_too_many_technical_issues"
}
}