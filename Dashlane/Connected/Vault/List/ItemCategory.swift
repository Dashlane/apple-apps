import Foundation
import DashlanePersonalData
import SwiftUI

enum ItemCategory {
    case credentials
    case secureNotes
    case payments
    case personalInfo
    case ids

    var title: String {
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

    var icon: SwiftUI.Image {
        switch self {
        case .credentials:
            return FiberAsset.menuIconPasswords.swiftUIImage
        case .secureNotes:
            return FiberAsset.menuIconNotes.swiftUIImage
        case .payments:
            return FiberAsset.menuIconPaymentmeans.swiftUIImage
        case .personalInfo:
            return FiberAsset.menuIconPersonalinfos.swiftUIImage
        case .ids:
            return FiberAsset.menuIconConfidentialcards.swiftUIImage
        }
    }

    func count(personalDataService: PersonalDataService) -> Int {
        switch self {
        case .credentials:
            return (try? personalDataService.count(for: Credential.self)) ?? 0
        case .secureNotes:
            return (try? personalDataService.count(for: SecureNote.self)) ?? 0
        case .payments:
            let creditCardsCount = (try? personalDataService.count(for: CreditCard.self)) ?? 0
            let bankAccountsCount = (try? personalDataService.count(for: BankAccount.self)) ?? 0
            return creditCardsCount + bankAccountsCount
        case .personalInfo:
            let identitiesCount = (try? personalDataService.count(for: Identity.self)) ?? 0
            let emailsCount = (try? personalDataService.count(for: Email.self)) ?? 0
            let phonesCount = (try? personalDataService.count(for: Phone.self)) ?? 0
            let addressesCount = (try? personalDataService.count(for: Address.self)) ?? 0
            let companiesCount = (try? personalDataService.count(for: Company.self)) ?? 0
            let personalWebsitesCount = (try? personalDataService.count(for: PersonalWebsite.self)) ?? 0
            return [identitiesCount, emailsCount, phonesCount, addressesCount, companiesCount, personalWebsitesCount].reduce(0, +)
        case .ids:
            let passportsCount = (try? personalDataService.count(for: Passport.self)) ?? 0
            let drivingLicensesCount = (try? personalDataService.count(for: DrivingLicence.self)) ?? 0
            let socialSecuritiesCount = (try? personalDataService.count(for: SocialSecurityInformation.self)) ?? 0
            let idCardsCount = (try? personalDataService.count(for: IDCard.self)) ?? 0
            let fiscalInfoCount = (try? personalDataService.count(for: FiscalInformation.self)) ?? 0
            return [passportsCount, drivingLicensesCount, socialSecuritiesCount, idCardsCount, fiscalInfoCount].reduce(0, +)
        }
    }

    func makeViewModel(from sessionServices: SessionServicesContainer,
                       completion: @escaping ((VaultListCompletion) -> Void)) -> VaultListViewModel {
        switch self {
        case .credentials:
            return sessionServices.viewModelFactory.makeCredentialsListViewModel(completion: completion)
        case .secureNotes:
            return sessionServices.viewModelFactory.makeSecureNotesListViewModel(completion: completion)
        case .payments:
            return sessionServices.viewModelFactory.makePaymentsListViewModel(completion: completion)
        case .personalInfo:
            return sessionServices.viewModelFactory.makePersonalInfoListViewModel(completion: completion)
        case .ids:
            return sessionServices.viewModelFactory.makeIdsListViewModel(completion: completion)
        }
    }

    var placeholder: String {
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

    var placeholderCtaTitle: String? {
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

    var placeholderIcon: SwiftUI.Image {
        switch self {
        case .credentials:
            return FiberAsset.emptyPasswords.swiftUIImage
        case .secureNotes:
            return FiberAsset.emptyNotes.swiftUIImage
        case .payments:
            return FiberAsset.emptyPayments.swiftUIImage
        case .personalInfo:
            return FiberAsset.emptyPersonalInfo.swiftUIImage
        case .ids:
            return FiberAsset.emptyConfidentialCards.swiftUIImage
        }
    }

    var addTitle: String {
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

    var itemTypes: [PersonalDataItem.Type] {
        switch self {
        case .credentials:
            return [Credential.self]
        case .secureNotes:
            return [SecureNote.self]
        case .payments:
            return [CreditCard.self, BankAccount.self]
        case .personalInfo:
            return [Identity.self, Email.self, Phone.self, Address.self, Company.self, PersonalWebsite.self]
        case .ids:
            return [Passport.self, DrivingLicence.self, SocialSecurityInformation.self, IDCard.self, FiscalInformation.self]
        }
    }
}
