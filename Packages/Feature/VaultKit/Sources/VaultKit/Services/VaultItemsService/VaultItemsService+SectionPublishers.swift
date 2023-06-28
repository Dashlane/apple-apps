import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSettings
import Foundation
import SwiftUI

public enum VaultItemsSection: Int, Equatable, Identifiable, CaseIterable {
    case all
    case credentials
    case secureNotes
    case payments
    case personalInfo
    case ids

    public var id: Int {
        return rawValue
    }
}

extension ItemCategory {
    public var section: VaultItemsSection {
        switch self {
        case .credentials:
            return .credentials
        case .ids:
            return .ids
        case .payments:
            return .payments
        case .personalInfo:
            return .personalInfo
        case .secureNotes:
            return .secureNotes
        }
    }
}

extension VaultItemsSection {
    public var category: ItemCategory? {
        switch self {
        case .all:
            return nil
        case .credentials:
            return .credentials
        case .ids:
            return .ids
        case .payments:
            return .payments
        case .personalInfo:
            return .personalInfo
        case .secureNotes:
            return .secureNotes
        }
    }
}

extension VaultItemsServiceProtocol {
            public func itemsPublisherForSection(
        _ section: VaultItemsSection,
        teamSpacesService: TeamSpacesServiceProtocol
    ) -> AnyPublisher<[DataSection], Never> {
        switch section {
        case .all:
            return allItemsPublisher()
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .map { $0.alphabeticallyGrouped() }
                .eraseToAnyPublisher()
        case .credentials:
            guard featureService.isEnabled(.passkeysVault) else {
                return $credentials
                    .map { $0.alphabeticallyGrouped() }
                    .filter(by: teamSpacesService.selectedSpacePublisher)
                    .eraseToAnyPublisher()
            }
            let credentialsPublisher = $credentials
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()
            let passkeysPublisher = $passkeys
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()

            let result = [credentialsPublisher, passkeysPublisher]
                .combineLatest()
                .map { $0.flatMap { $0 } }
                .map { $0.alphabeticallyGrouped() }
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .eraseToAnyPublisher()
            return result
        case .secureNotes:
            return $secureNotes
                .map { $0.alphabeticallyGrouped() }
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .eraseToAnyPublisher()
        case .payments:
            let creditCardsPublisher = $creditCards
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let bankAccountsPublisher = $bankAccounts
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            return [creditCardsPublisher, bankAccountsPublisher]
                .combineLatest()
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .eraseToAnyPublisher()
        case .personalInfo:
            let identities = $identities
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let emails = $emails
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let phones = $phones
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let addresses = $addresses
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let companies = $companies
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()
            let websites = $websites
                .map { $0.alphabeticallySorted() }
                .map(DataSection.init)
                .eraseToAnyPublisher()

            return [identities,
                    emails,
                    phones,
                    addresses,
                    companies,
                    websites]
                .combineLatest()
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .eraseToAnyPublisher()

        case .ids:
            let passports = $passports
                .map { $0.alphabeticallySorted() }
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()
            let drivingLicenses = $drivingLicenses
                .map { $0.alphabeticallySorted() }
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()
            let socialSecurities = $socialSecurityInformation
                .map { $0.alphabeticallySorted() }
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()
            let idCards = $idCards
                .map { $0.alphabeticallySorted() }
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()
            let fiscalInfo = $fiscalInformation
                .map { $0.alphabeticallySorted() }
                .map { $0 as [VaultItem] }
                .eraseToAnyPublisher()

            return [passports,
                    drivingLicenses,
                    socialSecurities,
                    idCards,
                    fiscalInfo]
                .combineLatest()
                .map { $0.flatMap { $0 } }
                .filter(by: teamSpacesService.selectedSpacePublisher)
                .map { items in
                    [DataSection(name: L10n.Core.itemsTitle, items: items)]
                }
                .eraseToAnyPublisher()
        }

    }
}
