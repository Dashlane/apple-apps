import CoreLocalization

public enum ItemCategory: CaseIterable, Identifiable {
  case credentials
  case secureNotes
  case payments
  case personalInfo
  case ids
  case secrets
  case wifi

  public var id: String {
    return title
  }

  public var title: String {
    switch self {
    case .credentials:
      return CoreL10n.mainMenuLoginsAndPasswords
    case .secureNotes:
      return CoreL10n.mainMenuNotes
    case .payments:
      return CoreL10n.mainMenuPayment
    case .personalInfo:
      return CoreL10n.mainMenuContact
    case .ids:
      return CoreL10n.mainMenuIDs
    case .secrets:
      return CoreL10n.mainMenuSecrets
    case .wifi:
      return L10n.Core.WiFi.mainMenu
    }
  }

  public func sectionSingular(count: Int) -> String {
    switch self {
    case .credentials:
      return CoreL10n.login(count)
    case .secureNotes:
      return CoreL10n.secureNote(count)
    case .payments:
      return CoreL10n.payment(count)
    case .personalInfo:
      return CoreL10n.personalInfo(count)
    case .ids:
      return CoreL10n.id(count)
    case .secrets:
      return CoreL10n.secret(count)
    case .wifi:
      return L10n.Core.WiFi.Pluralized.singular(count)
    }
  }

  public func sectionPlural(count: Int) -> String {
    switch self {
    case .credentials:
      return CoreL10n.loginsPlural(count)
    case .secureNotes:
      return CoreL10n.secureNotesPlural(count)
    case .payments:
      return CoreL10n.paymentsPlural(count)
    case .personalInfo:
      return CoreL10n.personalInfoPlural(count)
    case .ids:
      return CoreL10n.idsPlural(count)
    case .secrets:
      return CoreL10n.secretsPlural(count)
    case .wifi:
      return L10n.Core.WiFi.Pluralized.plural(count)
    }
  }

  public var placeholderTitle: String {
    switch self {
    case .credentials:
      return CoreL10n.emptyPasswordsListTitle
    case .secureNotes:
      return CoreL10n.emptySecureNotesListTitle
    case .payments:
      return CoreL10n.emptyPaymentsListTitle
    case .personalInfo:
      return CoreL10n.emptyPersonalInfoListTitle
    case .ids:
      return CoreL10n.emptyIDsListTitle
    case .secrets:
      return CoreL10n.emptySecretsListTitle
    case .wifi:
      return CoreL10n.emptyWiFiListTitle
    }
  }

  public var placeholderDescription: String {
    switch self {
    case .credentials:
      return CoreL10n.emptyPasswordsListDescription
    case .secureNotes:
      return CoreL10n.emptySecureNotesListDescription
    case .payments:
      return CoreL10n.emptyPaymentsListDescription
    case .personalInfo:
      return CoreL10n.emptyPersonalInfoListDescription
    case .ids:
      return CoreL10n.emptyIDsListDescription
    case .secrets:
      return CoreL10n.emptySecretsListDescription
    case .wifi:
      return CoreL10n.emptyWiFiListDescription
    }
  }

  public var placeholderCTATitle: String {
    switch self {
    case .credentials:
      return CoreL10n.emptyPasswordsListCTA
    case .secureNotes:
      return CoreL10n.emptySecureNotesListCTA
    case .payments:
      return CoreL10n.emptyPaymentsListCTA
    case .personalInfo:
      return CoreL10n.emptyPersonalInfoListCTA
    case .ids:
      return CoreL10n.emptyIDsListCTA
    case .secrets:
      return CoreL10n.emptySecretsListCTA
    case .wifi:
      return CoreL10n.emptyWiFiListCTA
    }
  }

  public var addTitle: String {
    switch self {
    case .credentials:
      return CoreL10n.kwadddatakwAuthentifiantIOS
    case .secureNotes:
      return CoreL10n.kwadddatakwSecureNoteIOS
    case .payments:
      return CoreL10n.kwEmptyPaymentsAddAction
    case .personalInfo:
      return CoreL10n.kwEmptyContactAddAction
    case .ids:
      return CoreL10n.kwEmptyIdsAddAction
    case .secrets:
      return CoreL10n.addASecret
    case .wifi:
      return L10n.Core.WiFi.add
    }
  }

  public var nativeMenuAddTitle: String {
    switch self {
    case .credentials:
      return CoreL10n.addPassword
    case .secureNotes:
      return CoreL10n.addSecureNote
    case .payments:
      return CoreL10n.addPayment
    case .personalInfo:
      return CoreL10n.addPersonalInfo
    case .ids:
      return CoreL10n.addID
    case .secrets:
      return CoreL10n.addSecret
    case .wifi:
      return L10n.Core.WiFi.add
    }
  }
}
