import CorePersonalData
import Combine
import DashlaneAppKit
import VaultKit

extension VaultItemsService {
    public func allItemsPublisher() -> AnyPublisher<[VaultItem], Never> {
        ItemCategory.allCases.map {
            itemsPublisher(for: $0)
        }
        .combineLatest()
        .map { items in
            return items.flatMap { $0 }
        }.eraseToAnyPublisher()
    }

    public func itemsPublisher(for category: ItemCategory?) -> AnyPublisher<[VaultItem], Never> {
        guard let category = category else {
            return allItemsPublisher()
        }
        switch category {
        case .credentials:
            return credentialsPublisher()
        case .secureNotes:
            return secureNotesPublisher()
        case .payments:
            return paymentsPublisher()
        case .personalInfo:
            return personalInfoPublisher()
        case .ids:
            return idsPublisher()
        }
    }

    private func credentialsPublisher() -> AnyPublisher<[VaultItem], Never> {
        self.$credentials
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
    }

    private func secureNotesPublisher() -> AnyPublisher<[VaultItem], Never> {
        self.$secureNotes
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
    }

    private func paymentsPublisher() -> AnyPublisher<[VaultItem], Never> {
        let creditCards = self.$creditCards
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let bankAccounts = self.$bankAccounts
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()

        return [creditCards, bankAccounts]
            .combineLatest()
            .map { items in
                items.flatMap { $0 }
        }.eraseToAnyPublisher()
    }

    private func personalInfoPublisher() -> AnyPublisher<[VaultItem], Never> {
        let identities = $identities
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let emails = $emails
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let phones = $phones
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let addresses = $addresses
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let companies = $companies
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let websites = $websites
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()

        return [identities,
                emails,
                phones,
                addresses,
                companies,
                websites]
            .combineLatest()
            .map { items in
                items.flatMap { $0 }
        }.eraseToAnyPublisher()
    }

    private func idsPublisher() -> AnyPublisher<[VaultItem], Never> {
        let passports = $passports
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let drivingLicenses = $drivingLicenses
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let socialSecurityInfo = $socialSecurityInformation
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let idCards = $idCards
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        let fiscalInfo = $fiscalInformation
            .map { $0 as [VaultItem] }
            .eraseToAnyPublisher()
        return [passports,
                drivingLicenses,
                socialSecurityInfo,
                idCards,
                fiscalInfo]
            .combineLatest()
            .map { items in
                items.flatMap { $0 }
        }.eraseToAnyPublisher()
    }
}
