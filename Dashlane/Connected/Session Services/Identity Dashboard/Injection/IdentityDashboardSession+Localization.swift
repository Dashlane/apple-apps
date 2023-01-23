import Foundation
import SecurityDashboard
struct IdentityDashboardLocalizationProvider: LocalizationProvider {
    func localizedString(for key: LocalizationKey) -> String {
        return NSLocalizedString(key.rawValue, comment: "")
    }
}

extension LocalizationKey {
    var rawValue: String {
        switch self {
                        case .popupDataLeakTitle:
                return "SECURITY_BREACH_DARKWEB_ALERT_TITLE"
            case .popupDataLeakNewTitle:
                return "SECURITY_BREACH_DARKWEB_ALERT_TITLE_GENERIC"
            case .popupDataLeakTitleNoDomainNoMatch:
                return "SECURITY_BREACH_DARKWEB_ALERT_TITLE_NO_MATCH_NO_DOMAIN"
            case .popupDataLeakHidden:
                return "SECURITY_ALERT_UNRESOLVED_DARK_WEB_NEW_TITLE"
            case .popupDataLeakDescription:
                return "SECURITY_BREACH_DARKWEB_INFORMATION"
            case .popupRegularTitle:
                return "SECURITY_BREACH_REGULAR_ALERT_TITLE"
            case .popupRegularDescription:
                return "SECURITY_BREACH_REGULAR_INFORMATION"
            case .popupBreachDetails:
                return "SECURITY_BREACH_ALL_WHAT_INCLUDED"
            case .popupRecommendationYesSingle:
                return "SECURITY_BREACH_CHANGE_RECOMMENDATION_SINGLE_OBJECT_PARAMETER"
            case .popupRecommendationYesMultiple:
                return "SECURITY_BREACH_CHANGE_RECOMMENDATION_MULTIPLE_OBJECT_PARAMETER"
            case .popupRecommendationOnlyPII:
                return "SECURITY_BREACH_IDENTITY_STILL_AT_RISK"
            case .popupRecommendationNoPassword:
                return "SECURITY_BREACH_CHANGE_RECOMMENDATION_NO_PASSWORD"
            case .popupAffectedPasswordsMatchingCredentialsRecommandation:
                return "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_IS_MATCHING_CREDENTIALS"
            case .popupRecommendationDataLeakNoDomainNoPassword:
                return "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_NO_PASSWORD_LEAKED"
            case .popupViewCTA:
                return "SECURITY_ALERT_VIEW_BUTTON"
            case .popupCloseCTA:
                return "SECURITY_ALERT_LATER_BUTTON"
            case .popupDismissCTA:
                return "SECURITY_ALERT_DISMISS_BUTTON"
            case .popupViewDetailsCTA:
                return "SECURITY_ALERT_VIEW_DETAILS_BUTTON"
            
                        case .trayWhenJustNow:
                return "SECURITY_ALERT_UNRESOLVED_JUSTNOW"
            case .trayWhenToday:
                return "SECURITY_ALERT_UNRESOLVED_TODAY"
            case .trayWhenYesterday:
                return "SECURITY_ALERT_UNRESOLVED_YESTERDAY"
            case .trayDataLeakTitle:
                return "SECURITY_ALERTS_UNRESOLVED_DATALEAK_TITLE"
            case .trayRegularTitle:
                return "SECURITY_ALERTS_UNRESOLVED_REGULAR_TITLE"
            case .trayDate:
                return "SECURITY_ALERT_UNRESOLVED_DATE"
            case .trayDataLeakDescription:
                return "SECURITY_ALERTS_UNRESOLVED_DATALEAK_DESCRIPTION"
            case .trayBreachDetails:
                return "SECURITY_ALERT_UNRESOLVED_WHAT_INCLUDED"
            case .trayRecommendationYesSingle:
                return "SECURITY_BREACH_CHANGE_RECOMMENDATION_OBJECT_PARAMETER"
            case .trayRecommendationYesMultiple:
                return "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_MULTIPLE_OBJECT_PARAMETER"
            case .trayRecommendationOnlyPII:
                return "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_PIIS"
            case .trayRecommendationNoPassword:
                return "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_NO_PASSWORD"
            case .trayAffectedPasswordsMatchingCredentialsRecommandation:
                return "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_IS_MATCHING_CREDENTIALS"
            case .trayRecommendationDataLeakNoDomainNoPassword:
                return "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_NO_PASSWORD_LEAKED"
            case .trayViewCTA:
                return "SECURITY_ALERT_UNRESOLVED_VIEW"
            
                        case .dataTypeLogin: return "SECURITY_BREACH_LEAKED_LOGIN"
            case .dataTypePasswords: return "SECURITY_BREACH_LEAKED_PASSWORD"
            case .dataTypeEmails: return "SECURITY_BREACH_LEAKED_EMAIL"
            case .dataTypeCreditCard: return "SECURITY_BREACH_LEAKED_CREDIT_CARD"
            case .dataTypePhoneNumber: return "SECURITY_BREACH_LEAKED_PHONE_NUMBER"
            case .dataTypeAddresses: return "SECURITY_BREACH_LEAKED_ADDRESS"
            case .dataTypeSsn: return "SECURITY_BREACH_LEAKED_SSN"
            case .dataTypeUsername: return "SECURITY_BREACH_LEAKED_USERNAME"
            case .dataTypeIp: return "SECURITY_BREACH_LEAKED_IP"
            case .dataTypeGeolocation: return "SECURITY_BREACH_LEAKED_GEOLOCATION"
            case .dataTypePersonalInfo: return "SECURITY_BREACH_LEAKED_PERSONAL_INFO"
            case .dataTypeSocial: return "SECURITY_BREACH_LEAKED_SOCIAL"
            
            case .popupDataLeakHiddenDescription:
                return "SECURITY_BREACH_DARKWEB_HIDDEN_DESCRIPTION"
            case .popupBreachDetailsEmails:
                return "SECURITY_BREACH_IMPACTED_EMAILS_PARAMETERS"
            case .popupBreachDetailsDomains:
                return "SECURITY_BREACH_IMPACTED_DOMAINS_PARAMETERS"
            case .popupBreachDetailsUsernames:
                return "SECURITY_BREACH_IMPACTED_USERNAMES_PARAMETERS"
            case .popupAffectedPasswords:
                return "SECURITY_ALERT_DATA_LEAK_POPUP_AFFECTED_PASSWORDS"
            case .popupExplanationDataLeakTitle:
                return "SECURITY_BREACH_EXPLANATION_DATALEAK_TITLE"
            case .popupExplanationDataLeakDescription:
                return "SECURITY_BREACH_EXPLANATION_DATALEAK_DESCRIPTION"
            case .popupCancelCTA:
                return "SECURITY_BREACH_CANCEL_CTA"
            case .popupUpgradeCTA:
                return "SECURITY_BREACH_UPGRADE_CTA"
            case .popupLaterCTA:
                return "SECURITY_BREACH_LATER_CTA"
            case .popupTakeActionCTA:
                return "SECURITY_BREACH_TAKEACTION_CTA"
            case .trayDataLeakNewTitle:
                return "SECURITY_ALERT_UNRESOLVED_DARK_WEB_NEW_TITLE"
            case .trayDataLeakHiddenDescription:
                return "SECURITY_BREACH_DESCRIPTION"
            case .trayBreachDetailsEmails:
                return "SECURITY_ALERT_UNRESOLVED_IMPACTED_EMAILS_PARAMETERS"
            case .trayBreachDetailsDomains:
                return "SECURITY_ALERT_UNRESOLVED_IMPACTED_DOMAINS_PARAMETERS"
            case .trayBreachDetailsUsernames:
                return "SECURITY_ALERT_UNRESOLVED_IMPACTED_USERNAMES_PARAMETERS"
            case .trayAffectedPasswords:
                return "SECURITY_ALERT_DATA_LEAK_TRAY_AFFECTED_PASSWORDS"
            case .trayRecommendationGoPremium:
                return "SECURITY_ALERT_UNRESOLVED_GO_PREMIUM"
            case .trayCloseCTA:
                return "SECURITY_ALERT_UNRESOLVED_CLOSE_CTA"
            case .trayUpgradeCTA:
                return "SECURITY_ALERT_UNRESOLVED_UPGRADE_CTA"
            case .trayTakeActionCTA:
                return "SECURITY_ALERT_UNRESOLVED_TAKE_ACTION_CTA"
            case .popupExplanationsDataLeakPremiumPlusUpsellDescription:
                return "SECURITY_ALERT_DATA_LEAK_PREMIUMPLUS_UPSELL_DESCRIPTION"
            case .popupExplanationsDataLeakPremiumPlusUpsellDescriptionOnlyPIIs:
                return "SECURITY_ALERT_DATA_LEAK_PREMIUMPLUS_UPSELL_DESCRIPTION_ONLY_PIIS"
        }
    }
}
