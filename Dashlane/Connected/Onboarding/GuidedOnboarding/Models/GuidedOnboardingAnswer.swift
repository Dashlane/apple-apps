import Foundation
import UIComponents

enum GuidedOnboardingAnswer: Int, CaseIterable, Hashable, Equatable {
    case autofill
    case storeAccountsSecurely
    case protectMyAccounts
    case memorizePasswords
    case browser
    case anotherPasswordManager
    case somethingElse
    case syncAcrossDevices
    case warnMeAboutHacks

    var title: String {
        switch self {
        case .autofill:
            return L10n.Localizable.guidedOnboardingAutofillTitle
        case .storeAccountsSecurely:
            return L10n.Localizable.guidedOnboardingStoreAccountsSecurelyTitle
        case .protectMyAccounts:
            return L10n.Localizable.guidedOnboardingProtectAccountsTitle
        case .memorizePasswords:
            return L10n.Localizable.guidedOnboardingMemorizePasswordsTitle
        case .browser:
            return L10n.Localizable.guidedOnboardingBrowserTitle
        case .anotherPasswordManager:
            return L10n.Localizable.guidedOnboardingAnotherManagerTitle
        case .somethingElse:
            return L10n.Localizable.guidedOnboardingSomethingElseTitle
        case .syncAcrossDevices:
            return L10n.Localizable.guidedOnboardingSyncPasswordsTitle
        case .warnMeAboutHacks:
            return L10n.Localizable.guidedOnboardingWarnAboutHacksTitle
        }
    }

    var description: String {
        switch self {
        case .autofill:
            return L10n.Localizable.guidedOnboardingAutofillDescription
        case .storeAccountsSecurely:
            return L10n.Localizable.guidedOnboardingStoreAccountsSecurelyDescription
        case .protectMyAccounts:
            return L10n.Localizable.guidedOnboardingProtectAccountsDescription
        case .memorizePasswords:
            return L10n.Localizable.guidedOnboardingMemorizePasswordsDescription
        case .browser:
            return L10n.Localizable.guidedOnboardingBrowserDescription
        case .anotherPasswordManager:
            return L10n.Localizable.guidedOnboardingAnotherManagerDescription
        case .somethingElse:
            return L10n.Localizable.guidedOnboardingSomethingElseDescription
        case .syncAcrossDevices:
            return L10n.Localizable.guidedOnboardingSyncPasswordsDescription
        case .warnMeAboutHacks:
            return L10n.Localizable.guidedOnboardingWarnAboutHacksDescription
        }
    }

    var altActionTitle: String? {
        switch self {
        case .memorizePasswords:
            return L10n.Localizable.guidedOnboardingMemorizePasswordsAltAction
        case .browser:
            return L10n.Localizable.guidedOnboardingBrowserAltAction
        case .anotherPasswordManager:
            return L10n.Localizable.guidedOnboardingAnotherManagerAltAction
        case .somethingElse:
            return L10n.Localizable.guidedOnboardingSomethingElseAltAction
        default:
            return nil
        }
    }

    var faq: OnboardingFAQ? {
        switch self {
        case .memorizePasswords, .somethingElse:
            return .whatIfDashlaneGetsHacked
        case .browser, .anotherPasswordManager:
            return .isDashlaneReallyMoreSecure
        default:
            return nil
        }
    }

    var animationAsset: LottieAsset? {
        switch self {
        case .autofill:
            return .guidedOnboarding01Autofill
        case .memorizePasswords:
            return .guidedOnboarding05Vault
        case .browser:
            return .guidedOnboarding07Pwimport
        case .somethingElse, .syncAcrossDevices:
            return .guidedOnboarding08Devices
        case .warnMeAboutHacks:
            return .guidedOnboarding03Breach
        default:
            return nil
        }
    }
}
