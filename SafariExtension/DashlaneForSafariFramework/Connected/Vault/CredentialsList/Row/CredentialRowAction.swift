import Foundation
import CoreLocalization

enum CopyCredentialAction: MenuItem {
    case email
    case login
    case secondaryLogin
    case password(limited: Bool)
    case oneTimePassword
    case note
    
    var menuTitle: String {
        L10n.Localizable.menuCopyItem(title.lowercased())
    }
    
    var title: String {
        switch self {
        case .email: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.email
        case .login: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.login
        case .secondaryLogin: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.secondaryLogin
        case .password: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.password
        case .oneTimePassword: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.otp
        case .note: return CoreLocalization.L10n.Core.KWAuthentifiantIOS.note
        }
    }
    
    var canPerformAction: Bool {
        switch self {
        case let .password(limited):
            return !limited
        default:
            return true
        }
    }
    
    func copyFeedback(forWebsite website: String) -> String {
        switch self {
        case .email: return L10n.Localizable.copyEmailFeedback(website)
        case .login: return L10n.Localizable.copyLoginFeedback(website)
        case .secondaryLogin: return L10n.Localizable.copySecondaryLoginFeedback(website)
        case .password: return L10n.Localizable.copyPasswordFeedback(website)
        case .oneTimePassword: return L10n.Localizable.copySecurityCodeFeedback(website)
        case .note: return L10n.Localizable.copyNoteFeedback(website)
        }
    }
}

enum CredentialRowAction {
    case copy(CopyCredentialAction)
    case goToWebsite
}

