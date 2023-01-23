import Foundation
import CorePersonalData
import SwiftUI
import Combine
import DashlaneAppKit

public enum ItemCategory: CaseIterable, Identifiable {
    case credentials
    case secureNotes
    case payments
    case personalInfo
    case ids
    
    public var id: String {
        return title
    }

    public var title: String {
        switch self {
        case .credentials:
            return L10n.Localizable.mainMenuLoginsAndPasswords
        case .secureNotes:
            return L10n.Localizable.mainMenuNotes
        case .payments:
            return L10n.Localizable.mainMenuPayment
        case .personalInfo:
            return L10n.Localizable.mainMenuContact
        case .ids:
            return L10n.Localizable.mainMenuIDs
        }
    }

    public var placeholder: String {
        switch self {
        case .credentials:
            return L10n.Localizable.emptyPasswordsListText
        case .secureNotes:
            return L10n.Localizable.emptySecureNotesListText
        case .payments:
            return L10n.Localizable.emptyPaymentsListText
        case .personalInfo:
            return L10n.Localizable.emptyPersonalInfoListText
        case .ids:
            return L10n.Localizable.emptyConfidentialCardsListText
        }
    }

    public var placeholderCtaTitle: String {
        switch self {
        case .credentials:
            return L10n.Localizable.emptyPasswordsListCta
        case .secureNotes:
            return L10n.Localizable.emptySecureNotesListCta
        case .payments:
            return L10n.Localizable.emptyPaymentsListCta
        case .personalInfo:
            return L10n.Localizable.emptyPersonalInfoListCta
        case .ids:
            return L10n.Localizable.emptyConfidentialCardsListCta
        }
    }

    public var addTitle: String {
        switch self {
        case .credentials:
            return L10n.Localizable.kwadddatakwAuthentifiantIOS
        case .secureNotes:
            return L10n.Localizable.kwadddatakwSecureNoteIOS
        case .payments:
            return L10n.Localizable.kwEmptyPaymentsAddAction
        case .personalInfo:
            return L10n.Localizable.kwEmptyContactAddAction
        case .ids:
            return L10n.Localizable.kwEmptyIdsAddAction
        }
    }
    
    public var nativeMenuAddTitle: String {
        switch self {
        case .credentials:
            return L10n.Localizable.addPassword
        case .secureNotes:
            return L10n.Localizable.addSecureNote
        case .payments:
            return L10n.Localizable.addPayment
        case .personalInfo:
            return L10n.Localizable.addPersonalInfo
        case .ids:
            return L10n.Localizable.addID
        }
    }
}
