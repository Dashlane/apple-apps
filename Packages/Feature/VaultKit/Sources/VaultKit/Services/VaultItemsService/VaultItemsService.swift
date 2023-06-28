import Combine
import CoreCategorizer
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import DashTypes
import Foundation
import CoreActivityLogs

public class VaultItemsService: VaultItemsServicePublishersStore, VaultItemsServiceProtocol {

    public var prefilledCredentials: [Credential] = []

    public let database: ApplicationDatabase
    public let sharingService: SharedVaultHandling
    let activityLogsService: ActivityLogsServiceProtocol
    let login: Login
    let logger: Logger
    let spotlightIndexer: SpotlightIndexer?
    let userSettings: UserSettings
    let categorizer: CategorizerProtocol
    var itemsSubcriptions = Set<AnyCancellable>()
    public let featureService: FeatureServiceProtocol
    private let teamSpacesService: TeamSpacesServiceProtocol

    fileprivate let updateLastUseQueue = DispatchQueue(label: "updateLastLocalUseDateQueue", qos: .background)
    private var localFieldUpdatedSubscription: AnyCancellable?

    public init(
        database: ApplicationDatabase,
        urlDecoder: PersonalDataURLDecoderProtocol,
        teamSpacesService: TeamSpacesServiceProtocol,
        sharingService: SharedVaultHandling,
        featureService: FeatureServiceProtocol,
        activityLogsService: ActivityLogsServiceProtocol,
        spotlightIndexer: SpotlightIndexer?,
        userSettings: UserSettings,
        categorizer: CategorizerProtocol,
        context: SessionLoadingContext,
        login: Login,
        logger: Logger
    ) {
        self.database = database
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.featureService = featureService
        self.spotlightIndexer = spotlightIndexer
        self.userSettings = userSettings
        self.categorizer = categorizer
        self.logger = logger
        self.login = login
        self.activityLogsService = activityLogsService

        super.init()

        configureLists()
        if case .accountCreation = context {
            createDefaultItems()
        }
        configureSpotlightIndexation()
        configurePrefilledCredentials(using: urlDecoder)
    }

    public func unload(reason: SessionServicesUnloadReason) {
        if reason == .userLogsOut {
            spotlightIndexer?.deleteAll()
        }
    }

            func configureLists() {
        let credentials = itemsPublisher(for: Credential.self).shareReplayLatest()
        credentials.assign(to: &$credentials)

        let secureNotes = itemsPublisher(for: SecureNote.self).shareReplayLatest()
        secureNotes.assign(to: &$secureNotes)

        let creditCards = itemsPublisher(for: CreditCard.self).shareReplayLatest()
        creditCards.assign(to: &$creditCards)

        let bankAccounts = itemsPublisher(for: BankAccount.self).shareReplayLatest()
        bankAccounts.assign(to: &$bankAccounts)

        let identities = itemsPublisher(for: Identity.self).shareReplayLatest()
        identities.assign(to: &$identities)

        let emails = itemsPublisher(for: Email.self).shareReplayLatest()
        emails.assign(to: &$emails)

        let phones = itemsPublisher(for: Phone.self).shareReplayLatest()
        phones.assign(to: &$phones)

        let addresses = itemsPublisher(for: Address.self).shareReplayLatest()
        addresses.assign(to: &$addresses)

        let companies = itemsPublisher(for: Company.self).shareReplayLatest()
        companies.assign(to: &$companies)

        let websites = itemsPublisher(for: PersonalWebsite.self).shareReplayLatest()
        websites.assign(to: &$websites)

        let passports = itemsPublisher(for: Passport.self).shareReplayLatest()
        passports.assign(to: &$passports)

        let idCards = itemsPublisher(for: IDCard.self).shareReplayLatest()
        idCards.assign(to: &$idCards)

        let fiscalInformation = itemsPublisher(for: FiscalInformation.self).shareReplayLatest()
        fiscalInformation.assign(to: &$fiscalInformation)

        let socialSecurityInformation = itemsPublisher(for: SocialSecurityInformation.self).shareReplayLatest()
        socialSecurityInformation.assign(to: &$socialSecurityInformation)

        let drivingLicenses = itemsPublisher(for: DrivingLicence.self).shareReplayLatest()
        drivingLicenses.assign(to: &$drivingLicenses)

        let collections = database.itemsPublisher(for: VaultCollection.self)
            .map { Array($0) }.shareReplayLatest()
        collections.assign(to: &$collections)

        let passkeys = database.itemsPublisher(for: Passkey.self)
            .map { Array($0) }.shareReplayLatest()
        passkeys.assign(to: &$passkeys)

                Publishers.MergeMany(
            [
                credentials.first().map { _ in true }.eraseToAnyPublisher(),
                secureNotes.first().map { _ in true }.eraseToAnyPublisher(),
                creditCards.first().map { _ in true }.eraseToAnyPublisher(),
                bankAccounts.first().map { _ in true }.eraseToAnyPublisher(),
                identities.first().map { _ in true }.eraseToAnyPublisher(),
                emails.first().map { _ in true }.eraseToAnyPublisher(),
                phones.first().map { _ in true }.eraseToAnyPublisher(),
                addresses.first().map { _ in true }.eraseToAnyPublisher(),
                companies.first().map { _ in true }.eraseToAnyPublisher(),
                websites.first().map { _ in true }.eraseToAnyPublisher(),
                passports.first().map { _ in true }.eraseToAnyPublisher(),
                idCards.first().map { _ in true }.eraseToAnyPublisher(),
                fiscalInformation.first().map { _ in true }.eraseToAnyPublisher(),
                socialSecurityInformation.first().map { _ in true }.eraseToAnyPublisher(),
                drivingLicenses.first().map { _ in true }.eraseToAnyPublisher(),
                collections.first().map { _ in true }.eraseToAnyPublisher(),
                passkeys.first().map { _ in true }.eraseToAnyPublisher()
            ])
        .collect()
        .sinkOnce { [weak self] (_: [Bool]) in
            self?.loaded = true
        }
    }

        public func itemsPublisher<Output: VaultItem>(for output: Output.Type) -> AnyPublisher<[Output], Never> {
        let teamSpacesService = self.teamSpacesService
        return self.database.itemsPublisher(for: output).combineLatest(teamSpacesService.businessTeamsInfoPublisher)
            .map { (items, businessTeamsInfo) in
                items.compactMap({ teamSpacesService.itemWithSpaceUpdated(on: $0, businessInfo: businessTeamsInfo) })
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

            public func itemPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<Output, Never> {
        let teamSpacesService = self.teamSpacesService
        return self.database.itemPublisher(for: vaultItem.id, type: Output.self)
            .handleEvents(receiveCompletion: { [logger] completion in
                guard case let .failure(error) = completion else {
                    return
                }
                logger.fatal("Vault Item Publisher Failed", error: error)
            })
            .ignoreError()
            .combineLatest(teamSpacesService.businessTeamsInfoPublisher)
            .compactMap { (item, businessTeamsInfo) in
                teamSpacesService.itemWithSpaceUpdated(on: item, businessInfo: businessTeamsInfo) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

        public func collectionsPublisher() -> AnyPublisher<[VaultCollection], Never> {
        return self.database.itemsPublisher(for: VaultCollection.self)
            .map { collections in collections.map { $0 } }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

        public func collectionsPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<[VaultCollection], Never> {
        return self.database.itemsPublisher(for: VaultCollection.self)
            .map { collections in collections.filter(by: vaultItem) }
            .handleEvents(receiveCompletion: { [logger] completion in
                guard case let .failure(error) = completion else {
                    return
                }
                logger.fatal("Vault Collection Publisher Failed", error: error)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func fetchedPersonalData<Output: PersonalDataCodable>(for output: Output.Type) -> FetchedPersonalData<Output> {
        return self.database.fetchedPersonalData(for: output)
    }

        public func delete(_ vaultItem: VaultItem) {
        if vaultItem.isShared {
            Task {
                try await self.sharingService.refuseAndDelete(vaultItem)
            }
        } else {
            try? database.delete(vaultItem)
                                    collections.filter(by: vaultItem).forEach { collection in
                var collectionCopy = collection
                collectionCopy.remove(vaultItem)
                _ = try? save(collectionCopy)
            }
        }
        activityLogDelete(vaultItem)
    }

    public func delete<Item: PersonalDataCodable>(_ item: Item) throws {
        try database.delete(item)
    }

    @discardableResult
    public func save<Item: VaultItem>(_ item: Item) throws -> Item {
        activityLogSave(item)
        return try database.save(item)
    }

    @discardableResult
    public func save<Item: VaultItem>(_ items: [Item]) throws -> [Item] {
        activityLogSave(items)
        return try database.save(items)
    }

    @discardableResult
    public func save<ItemType: PersonalDataCodable>(_ item: ItemType) throws -> ItemType {
        return try database.save(item)
    }

    public func save(_ item: GeneratedPassword) throws -> GeneratedPassword {
        return try database.save(item)
    }

    public func count<ItemType: PersonalDataCodable>(for type: ItemType.Type) throws -> Int {
        return try database.count(for: type)
    }

    @discardableResult
    public func link(_ generatedPassword: GeneratedPassword, to credential: Credential) throws -> GeneratedPassword {
        var generatedPassword = generatedPassword
        generatedPassword.link(to: credential)
        return try save(generatedPassword)
    }

        public func fetch<Output: VaultItem>(with identifier: Identifier, type: Output.Type) throws -> Output? {
        guard let item = try database.fetch(with: identifier, type: type) else { return nil }
        return teamSpacesService.itemWithSpaceUpdated(on: item)
    }

    public func updateLastUseDate(of items: [VaultItem], origin: Set<LastUseUpdateOrigin>) {
        updateLastUseQueue.async {
            let ids = items.map(\.id)
            do {
                try self.database.updateLastUseDate(for: ids, origin: origin)
            } catch {
                self.logger.error("Can't update last use", error: error)
            }
        }
    }
}

fileprivate extension TeamSpacesServiceProtocol {
    func itemWithSpaceUpdated<Output: VaultItem>(on item: Output) -> Output? {
        guard let spaceId = userSpace(for: item)?.personalDataId else {
            return nil 
        }
        guard spaceId != item.spaceId else {
            return item
        }
        var updatedItem = item 
        updatedItem.spaceId = spaceId
        return updatedItem
    }

    func itemWithSpaceUpdated<Output: VaultItem>(on item: Output, businessInfo: BusinessTeamsInfo) -> Output? {
        guard let spaceId = businessInfo.userSpace(forSpaceId: item.spaceId)?.personalDataId else {
            return nil 
        }

        guard spaceId != item.spaceId else {
            return item
        }
        var updatedItem = item 
        updatedItem.spaceId = spaceId
        return updatedItem
    }

}

extension VaultItemsService {
    public convenience init(
        logger: Logger,
        login: Login,
        context: SessionLoadingContext,
        spotlightIndexer: SpotlightIndexer?,
        userSettings: UserSettings,
        categorizer: Categorizer,
        urlDecoder: PersonalDataURLDecoderProtocol,
        sharingService: SharedVaultHandling,
        database: ApplicationDatabase,
        teamSpacesService: TeamSpacesServiceProtocol,
        featureService: FeatureServiceProtocol,
        activityLogsService: ActivityLogsServiceProtocol
    ) async {
        self.init(
            database: database,
            urlDecoder: urlDecoder,
            teamSpacesService: teamSpacesService,
            sharingService: sharingService,
            featureService: featureService,
            activityLogsService: activityLogsService,
            spotlightIndexer: spotlightIndexer,
            userSettings: userSettings,
            categorizer: categorizer,
            context: context,
            login: login,
            logger: logger
        )

                for await _ in self.$loaded.filter({ $0 == true }).removeDuplicates().values {
            return
        }
    }
}

extension VaultItemsService {
    public func sharedItem(with id: Identifier) -> VaultItem? {
                guard let item = try? database.sharedItem(for: id) as? VaultItem else { return nil }
        return teamSpacesService.itemWithSpaceUpdated(on: item)
    }
}
