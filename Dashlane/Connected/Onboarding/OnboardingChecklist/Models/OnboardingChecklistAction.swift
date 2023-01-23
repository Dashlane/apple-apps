import Foundation
import UIComponents

enum OnboardingChecklistAction: String, Identifiable {
    var id: String {
        return title
    }

    case addFirstPasswordsManually
    case importFromBrowser 
    case fixBreachedAccounts 
    case seeScanResult 
    case activateAutofill
    case m2d

    var title: String {
        switch self {
        case .addFirstPasswordsManually:
            return L10n.Localizable.onboardingChecklistV2ActionTitleAddAccounts
        case .importFromBrowser:
            return L10n.Localizable.onboardingChecklistV2ActionTitleImportFromBrowser
        case .fixBreachedAccounts:
            return L10n.Localizable.dwmOnboardingChecklistItemTitle
        case .seeScanResult:
            return L10n.Localizable.dwmOnboardingChecklistItemTitle
        case .activateAutofill:
            return L10n.Localizable.onboardingChecklistV2ActionTitleActivateAutofill
        case .m2d:
            return L10n.Localizable.onboardingChecklistV2ActionTitleM2D
        }
    }

    var caption: String {
        switch self {
        case .addFirstPasswordsManually:
            return L10n.Localizable.onboardingChecklistV2ActionCaptionAddAccounts
        case .importFromBrowser:
            return L10n.Localizable.onboardingChecklistV2ActionCaptionImportFromBrowser
        case .fixBreachedAccounts:
            return L10n.Localizable.dwmOnboardingChecklistItemCaption
        case .seeScanResult:
            return L10n.Localizable.dwmOnboardingChecklistItemCaption
        case .activateAutofill:
            return L10n.Localizable.onboardingChecklistV2ActionCaptionActivateAutofill
        case .m2d:
            return L10n.Localizable.onboardingChecklistV2ActionCaptionM2D
        }
    }

    var actionText: String {
        switch self {
        case .addFirstPasswordsManually:
            return L10n.Localizable.onboardingChecklistV2ActionButtonAddAccounts
        case .importFromBrowser:
            return L10n.Localizable.onboardingChecklistV2ActionButtonImportFromBrowser
        case .fixBreachedAccounts:
            return L10n.Localizable.darkWebMonitoringOnboardingChecklistSeeScanResult
        case .seeScanResult:
            return L10n.Localizable.darkWebMonitoringOnboardingChecklistSeeScanResult
        case .activateAutofill:
            return L10n.Localizable.onboardingChecklistV2ActionButtonActivateAutofill
        case .m2d:
            return L10n.Localizable.onboardingChecklistV2ActionButtonM2D
        }
    }

        var index: Int {
        switch self {
        case .addFirstPasswordsManually:
            return 1
        case .importFromBrowser:
            return 1
        case .fixBreachedAccounts:
            return 1
        case .seeScanResult:
            return 1
        case .activateAutofill:
            return 2
        case .m2d:
            return 3
        }
    }

            var animationAsset: LottieAsset {
        switch self {
        case .addFirstPasswordsManually,
                .importFromBrowser,
                .fixBreachedAccounts,
                .seeScanResult:
            return .onboardingVault
        case .activateAutofill:
            return .onboardingAutofill
        case .m2d:
            return .onboardingM2d
        }
    }
}
