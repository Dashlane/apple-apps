import Foundation
import CorePersonalData
import DashlaneAppKit
import DashTypes
import VaultKit

enum VaultDeeplink {
        case list(_ category: ItemCategory?)
        case fetchAndShow(VaultDeepLinkIdentifier, useEditMode: Bool)
        case show(VaultItem, useEditMode: Bool, origin: ItemDetailOrigin)
        case create(VaultDeepLinkComponent)
}

enum VaultDeepLinkComponent: String {
    case credential = "passwords"
    case secureNote = "notes"
    case bankAccount = "bank-accounts"
    case creditCard = "credit-cards"
    case payments
    case identity = "identities"
    case email = "emails"
    case phone = "phones"
    case address = "addresses"
    case company = "companies"
    case personalWebsite = "websites"
    case personalInfo = "personal-info"
    case paypal = "paypal-accounts"
    case identityCards = "id-cards"
    case passports = "passports"
    case driverLicense = "driver-licenses"
    case socialSecurityNumber = "social-security-numbers"
    case idDocuments = "id-documents"
    case fiscal
    case receipts
    case passwordManager = "password-manager"
    case items
    case wallet

    var type: VaultItem.Type {
        switch self {
        case .credential: return Credential.self
        case .secureNote: return SecureNote.self
        case .bankAccount: return BankAccount.self
        case .creditCard: return CreditCard.self
        case .identity: return Identity.self
        case .email: return Email.self
        case .phone: return Phone.self
        case .address: return Address.self
        case .company: return Company.self
        case .personalWebsite: return PersonalWebsite.self
        case .identityCards: return IDCard.self
        case .passports: return Passport.self
        case .driverLicense: return DrivingLicence.self
        case .socialSecurityNumber: return SocialSecurityInformation.self
        case .fiscal: return FiscalInformation.self
        default: return Credential.self
        }
    }
}

private extension VaultItem {
    var component: VaultDeepLinkComponent {
        switch self {
        case is Credential: return .credential
        case is SecureNote: return .secureNote
        case is BankAccount: return .bankAccount
        case is CreditCard: return .creditCard
        case is Identity: return .identity
        case is CorePersonalData.Email: return .email
        case is Phone: return .phone
        case is Address: return .address
        case is Company: return .company
        case is PersonalWebsite: return .personalWebsite
        case is IDCard: return .identityCards
        case is Passport: return .passports
        case is DrivingLicence: return .driverLicense
        case is SocialSecurityInformation: return .socialSecurityNumber
        case is FiscalInformation: return .fiscal
        default: return .credential
        }
    }
}

enum ItemActionDeepLinkComponent: String {
    case edit
    case create = "new"
}

extension VaultDeepLinkComponent {
    var category: ItemCategory? {
        switch self {
        case .credential, .passwordManager:
            return .credentials
        case .secureNote:
            return .secureNotes
        case .bankAccount, .creditCard, .payments, .wallet:
            return .payments
        case .identity, .email, .phone, .address, .company, .personalWebsite, .personalInfo:
            return .personalInfo
        case .identityCards, .passports, .driverLicense, .fiscal, .socialSecurityNumber, .idDocuments:
            return .ids
        default:
            return nil
        }
    }

    var isCategory: Bool {
        switch self {
        case .payments, .personalInfo, .idDocuments: return true
        default: return false
        }
    }
}

struct VaultDeepLinkIdentifier {
    let component: VaultDeepLinkComponent
    let rawIdentifier: String

    init(rawIdentifier: String,
         component: VaultDeepLinkComponent) {
        self.rawIdentifier = rawIdentifier
        self.component = component
    }

    init(identifier: Identifier,
         component: VaultDeepLinkComponent) {
        self.init(rawIdentifier: identifier.rawValue, component: component)
    }
}

extension VaultItem {
    var deepLinkIdentifier: VaultDeepLinkIdentifier {
        switch self.enumerated {
            case let .credential(item):
                return .init(identifier: item.id, component: .credential)
            case let .secureNote(item):
                return .init(identifier: item.id, component: .secureNote)
            case let .bankAccount(item):
                return .init(identifier: item.id, component: .bankAccount)
            case let .creditCard(item):
                return .init(identifier: item.id, component: .creditCard)
            case let .identity(item):
                return .init(identifier: item.id, component: .identity)
            case let .email(item):
                return .init(identifier: item.id, component: .email)
            case let .phone(item):
                return .init(identifier: item.id, component: .phone)
            case let .address(item):
                return .init(identifier: item.id, component: .address)
            case let .company(item):
                return .init(identifier: item.id, component: .company)
            case let .personalWebsite(item):
                return .init(identifier: item.id, component: .personalWebsite)
            case let .passport(item):
                return .init(identifier: item.id, component: .passports)
            case let .idCard(item):
                return .init(identifier: item.id, component: .identityCards)
            case let .fiscalInformation(item):
                return .init(identifier: item.id, component: .fiscal)
            case let .socialSecurityInformation(item):
                return .init(identifier: item.id, component: .socialSecurityNumber)
            case let .drivingLicence(item):
                return .init(identifier: item.id, component: .driverLicense)
        }
    }
}

private extension ItemCategory {
    var component: VaultDeepLinkComponent {
        switch self {
        case .credentials: return .credential
        case .ids: return .identity
        case .payments: return .payments
        case .secureNotes: return .secureNote
        case .personalInfo: return .personalInfo
        }
    }
}

extension VaultDeeplink {
    var rawDeeplink: String {
        switch self {
        case let .create(component):
            return "\(component.rawValue)/new"
        case let .fetchAndShow(identifier, editMode):
            let edit = editMode ? "/edit": ""
            return "\(identifier.component.rawValue)/\(identifier.rawIdentifier.trimCurlyBraces())\(edit)"
        case let .list(category):
            let component = category?.component ?? .credential
            return "\(component.rawValue)"
        case let .show(item, useEditMode, _):
            let edit = useEditMode ? "/edit": ""
                return "\(item)\(item.id.bracketLessIdentifier.rawValue)\(edit)"
        }
    }
}
