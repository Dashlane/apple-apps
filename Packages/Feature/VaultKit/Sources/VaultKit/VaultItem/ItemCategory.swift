import Combine
import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI

public enum ItemCategory: CaseIterable, Identifiable {
  case credentials
  case secureNotes
  case payments
  case personalInfo
  case ids
  case secrets

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
    case .secrets:
      return L10n.Core.mainMenuSecrets
    }
  }

  public func sectionSingular(count: Int) -> String {
    switch self {
    case .credentials:
      return L10n.Core.login(count)
    case .secureNotes:
      return L10n.Core.secureNote(count)
    case .payments:
      return L10n.Core.payment(count)
    case .personalInfo:
      return L10n.Core.personalInfo(count)
    case .ids:
      return L10n.Core.id(count)
    case .secrets:
      return L10n.Core.secret(count)
    }
  }

  public func sectionPlural(count: Int) -> String {
    switch self {
    case .credentials:
      return L10n.Core.loginsPlural(count)
    case .secureNotes:
      return L10n.Core.secureNotesPlural(count)
    case .payments:
      return L10n.Core.paymentsPlural(count)
    case .personalInfo:
      return L10n.Core.personalInfoPlural(count)
    case .ids:
      return L10n.Core.idsPlural(count)
    case .secrets:
      return L10n.Core.secretsPlural(count)
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
    case .secrets:
      return L10n.Core.emptySecretsListText
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
    case .secrets:
      return L10n.Core.emptySecretsListCta
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
    case .secrets:
      return L10n.Core.addASecret
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
    case .secrets:
      return L10n.Core.addSecret
    }
  }
}
