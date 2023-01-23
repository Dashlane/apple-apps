import Foundation
import Combine
import CoreSpotlight
import DashlaneAppKit
import VaultKit

extension VaultItemsService {
    private func spotlightPublisher() -> AnyPublisher<[SpotLightSearchable & VaultItem], Never> {
        let credentials = self.$credentials
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let creditCards = self.$creditCards
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let bankAccount = self.$bankAccounts
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let passports = self.$passports
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let driverLicenses = self.$drivingLicenses
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let ids = self.$idCards
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        let fiscalInformation = self.$fiscalInformation
            .map { $0 as [SpotLightSearchable & VaultItem] }
            .eraseToAnyPublisher()

        return [credentials,
                creditCards,
                bankAccount,
                passports,
                driverLicenses,
                ids,
                fiscalInformation]

            .combineLatest()
            .map { $0.flatMap { $0 } }
            .eraseToAnyPublisher()
    }

    func configureSpotlightIndexation() {
                guard let indexer = spotlightIndexer else {
            return
        }
                self.userSettings
            .publisher(for: .advancedSystemIntegration)
            .filter { $0 == true }
            .flatMap { [weak self] _ -> AnyPublisher<[SpotLightSearchable & VaultItem], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.spotlightPublisher()
            }
            .debounce(for: .seconds(2), scheduler: DispatchQueue(label: "com.dashlane.SpotlightIndexation"))
            .map { vaultItems in
                return vaultItems.compactMap(CSSearchableItem.init)
            }
            .receive(on: DispatchQueue.main)
            .sink { items in
                indexer.deleteIndexedItems(for: .vaultItem) {
                    indexer.index(items)
                }
            }.store(in: &self.itemsSubcriptions)

                self.userSettings
            .publisher(for: .advancedSystemIntegration)
            .filter { $0 == false }
            .sink { _ in
                indexer.deleteIndexedItems(for: .vaultItem)
            }.store(in: &self.itemsSubcriptions)
    }
}
