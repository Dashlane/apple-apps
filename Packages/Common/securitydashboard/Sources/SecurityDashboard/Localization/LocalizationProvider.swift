import Foundation

public protocol LocalizationProvider {
  func localizedString(for key: LocalizationKey) -> String
}

public enum LocalizationKey {
  case popupDataLeakTitle
  case popupDataLeakNewTitle
  case popupDataLeakTitleNoDomainNoMatch
  case popupDataLeakHidden
  case popupDataLeakDescription
  case popupDataLeakHiddenDescription
  case popupRegularTitle
  case popupRegularDescription
  case popupBreachDetails
  case popupBreachDetailsEmails
  case popupBreachDetailsDomains
  case popupBreachDetailsUsernames
  case popupRecommendationYesSingle
  case popupRecommendationYesMultiple
  case popupRecommendationOnlyPII
  case popupRecommendationNoPassword

  case popupExplanationDataLeakTitle
  case popupExplanationDataLeakDescription

  case popupExplanationsDataLeakPremiumPlusUpsellDescription
  case popupExplanationsDataLeakPremiumPlusUpsellDescriptionOnlyPIIs

  case popupAffectedPasswords
  case popupAffectedPasswordsMatchingCredentialsRecommandation
  case popupRecommendationDataLeakNoDomainNoPassword

  case popupViewCTA
  case popupCloseCTA
  case popupCancelCTA
  case popupUpgradeCTA
  case popupLaterCTA
  case popupTakeActionCTA
  case popupDismissCTA
  case popupViewDetailsCTA

  case trayWhenJustNow
  case trayWhenToday
  case trayWhenYesterday
  case trayDataLeakTitle
  case trayDataLeakNewTitle
  case trayRegularTitle
  case trayDate
  case trayDataLeakDescription
  case trayDataLeakHiddenDescription
  case trayBreachDetails
  case trayBreachDetailsEmails
  case trayBreachDetailsDomains
  case trayBreachDetailsUsernames
  case trayRecommendationYesSingle
  case trayRecommendationYesMultiple
  case trayRecommendationOnlyPII
  case trayRecommendationNoPassword

  case trayRecommendationGoPremium

  case trayAffectedPasswords
  case trayAffectedPasswordsMatchingCredentialsRecommandation
  case trayRecommendationDataLeakNoDomainNoPassword

  case trayViewCTA
  case trayCloseCTA
  case trayUpgradeCTA
  case trayTakeActionCTA

  case dataTypeLogin
  case dataTypePasswords
  case dataTypeEmails
  case dataTypeCreditCard
  case dataTypePhoneNumber
  case dataTypeAddresses
  case dataTypeSocial
  case dataTypeSsn
  case dataTypeUsername
  case dataTypeIp
  case dataTypeGeolocation
  case dataTypePersonalInfo

}
