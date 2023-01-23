import Foundation
import CorePersonalData
import Combine
import SwiftUI
import DashlaneAppKit
import CoreSettings
import VaultKit
import CorePremium

enum VaultItemsSection {
    case credentials(sort: AnyPublisher<VaultItemSorting, Never>) 
    case secureNotes(sort: AnyPublisher<VaultItemSorting, Never>)
    case payments
    case personalInfo
    case ids
    case all
}

extension VaultItemsServiceProtocol {
            func itemsPublisherForSection(_ section: VaultItemsSection,
                                   teamSpacesService: TeamSpacesService) -> AnyPublisher<[DataSection], Never> {
        switch section {
        case .all:
            return allItemsPublisher()
                .filter(by: teamSpacesService.$selectedSpace)
                .map { $0.alphabeticallyGrouped() }
                .eraseToAnyPublisher()
        case let .credentials(sort):
            return $credentials
                .sort(using: sort)
                .filter(by: teamSpacesService.$selectedSpace)
                .eraseToAnyPublisher()
        case let .secureNotes(sort):
            return $secureNotes
                .sort(using: sort)
                .filter(by: teamSpacesService.$selectedSpace)
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
                .filter(by: teamSpacesService.$selectedSpace)
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
                .filter(by: teamSpacesService.$selectedSpace)
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
                .filter(by: teamSpacesService.$selectedSpace)
                .map { items in
                    [DataSection(name: L10n.Localizable.itemsTitle, items: items)]
                }
                .eraseToAnyPublisher()
        }

    }
}
