import Foundation

enum OnboardingFAQ: String {
  case whatIfDashlaneGetsHacked
  case canDashlaneSeeMyPassword
  case howDoesDashlaneMakeMoney
  case canILeaveAndTakeMyData
  case isDashlaneReallyMoreSecure

  var title: String {
    switch self {
    case .whatIfDashlaneGetsHacked:
      return L10n.Localizable.guidedOnboardingFAQDashlaneHackedTitle
    case .canDashlaneSeeMyPassword:
      return L10n.Localizable.guidedOnboardingFAQDashlaneSeePasswordTitle
    case .howDoesDashlaneMakeMoney:
      return L10n.Localizable.guidedOnboardingFAQDashlaneMakeMoneyTitle
    case .canILeaveAndTakeMyData:
      return L10n.Localizable.guidedOnboardingFAQLeaveAndTakeDataTitle
    case .isDashlaneReallyMoreSecure:
      return L10n.Localizable.guidedOnboardingFAQDashlaneMoreSecureTitle
    }
  }

  var description: String {
    switch self {
    case .whatIfDashlaneGetsHacked:
      return L10n.Localizable.guidedOnboardingFAQDashlaneHackedDescription
    case .canDashlaneSeeMyPassword:
      return L10n.Localizable.guidedOnboardingFAQDashlaneSeePasswordDescription
    case .howDoesDashlaneMakeMoney:
      return L10n.Localizable.guidedOnboardingFAQDashlaneMakeMoneyDescription
    case .canILeaveAndTakeMyData:
      return L10n.Localizable.guidedOnboardingFAQLeaveAndTakeDataDescription
    case .isDashlaneReallyMoreSecure:
      return L10n.Localizable.guidedOnboardingFAQDashlaneMoreSecureDescription
    }
  }
}

class OnboardingFAQService {

  let questions: [OnboardingFAQ] = [
    .whatIfDashlaneGetsHacked,
    .canDashlaneSeeMyPassword,
    .howDoesDashlaneMakeMoney,
    .canILeaveAndTakeMyData,
    .isDashlaneReallyMoreSecure,
  ]
}
