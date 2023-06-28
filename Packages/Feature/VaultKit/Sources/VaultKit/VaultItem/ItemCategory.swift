import Foundation
import CorePersonalData
import SwiftUI
import Combine
import CoreLocalization

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
            return L10n.Core.mainMenuLoginsAndPasswords
        case .secureNotes:
            return L10n.Core.mainMenuNotes
        case .payments:
            return L10n.Core.mainMenuPayment
        case .personalInfo:
            return L10n.Core.mainMenuContact
        case .ids:
            return L10n.Core.mainMenuIDs
        }
    }

    public var placeholder: String {
        switch self {
        case .credentials:
            return L10n.Core.emptyPasswordsListText
        case .secureNotes:
            return L10n.Core.emptySecureNotesListText
        case .payments:
            return L10n.Core.emptyPaymentsListText
        case .personalInfo:
            return L10n.Core.emptyPersonalInfoListText
        case .ids:
            return L10n.Core.emptyConfidentialCardsListText
        }
    }

    public var placeholderCtaTitle: String {
        switch self {
        case .credentials:
            return L10n.Core.emptyPasswordsListCta
        case .secureNotes:
            return L10n.Core.emptySecureNotesListCta
        case .payments:
            return L10n.Core.emptyPaymentsListCta
        case .personalInfo:
            return L10n.Core.emptyPersonalInfoListCta
        case .ids:
            return L10n.Core.emptyConfidentialCardsListCta
        }
    }

    public var addTitle: String {
        switch self {
        case .credentials:
            return L10n.Core.kwadddatakwAuthentifiantIOS
        case .secureNotes:
            return L10n.Core.kwadddatakwSecureNoteIOS
        case .payments:
            return L10n.Core.kwEmptyPaymentsAddAction
        case .personalInfo:
            return L10n.Core.kwEmptyContactAddAction
        case .ids:
            return L10n.Core.kwEmptyIdsAddAction
        }
    }

    public var nativeMenuAddTitle: String {
        switch self {
        case .credentials:
            return L10n.Core.addPassword
        case .secureNotes:
            return L10n.Core.addSecureNote
        case .payments:
            return L10n.Core.addPayment
        case .personalInfo:
            return L10n.Core.addPersonalInfo
        case .ids:
            return L10n.Core.addID
        }
    }
}
