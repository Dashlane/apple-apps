import Combine
import CorePersonalData
import DashTypes
import CoreFeature

open class VaultItemsServicePublishersStore {
    @Published
    public var credentials: [Credential]
    @Published
    public var secureNotes: [SecureNote]
    @Published
    public var creditCards: [CreditCard]
    @Published
    public var bankAccounts: [BankAccount]
    @Published
    public var identities: [Identity]
    @Published
    public var emails: [CorePersonalData.Email]
    @Published
    public var phones: [Phone]
    @Published
    public var addresses: [Address]
    @Published
    public var companies: [Company]
    @Published
    public var websites: [PersonalWebsite]
    @Published
    public var passports: [Passport]
    @Published
    public var idCards: [IDCard]
    @Published
    public var fiscalInformation: [FiscalInformation]
    @Published
    public var socialSecurityInformation: [SocialSecurityInformation]
    @Published
    public var drivingLicenses: [DrivingLicence]
    @Published
    public var collections: [VaultCollection]
    @Published
    public var passkeys: [CorePersonalData.Passkey]

    @Published
    public var loaded: Bool = false

    public init(
        credentials: [Credential] = [],
        secureNotes: [SecureNote] = [],
        creditCards: [CreditCard] = [],
        bankAccounts: [BankAccount] = [],
        identities: [Identity] = [],
        emails: [CorePersonalData.Email] = [],
        phones: [Phone] = [],
        addresses: [Address] = [],
        companies: [Company] = [],
        websites: [PersonalWebsite] = [],
        passports: [Passport] = [],
        idCards: [IDCard] = [],
        fiscalInformation: [FiscalInformation] = [],
        socialSecurityInformation: [SocialSecurityInformation] = [],
        drivingLicenses: [DrivingLicence] = [],
        credentialCategories: [CredentialCategory] = [],
        secureNotesCategories: [SecureNoteCategory] = [],
        collections: [VaultCollection] = [],
        passkeys: [CorePersonalData.Passkey] = []
    ) {
        self.credentials = credentials
        self.secureNotes = secureNotes
        self.creditCards = creditCards
        self.bankAccounts = bankAccounts
        self.identities = identities
        self.emails = emails
        self.phones = phones
        self.addresses = addresses
        self.companies = companies
        self.websites = websites
        self.passports = passports
        self.idCards = idCards
        self.fiscalInformation = fiscalInformation
        self.socialSecurityInformation = socialSecurityInformation
        self.drivingLicenses = drivingLicenses
        self.collections = collections
        self.passkeys = passkeys
    }
}

public protocol VaultItemsServiceProtocol: VaultItemsServicePublishersStore {
    var prefilledCredentials: [Credential] { get set }
    var database: ApplicationDatabase { get }
    var sharingService: SharedVaultHandling { get }
    var featureService: FeatureServiceProtocol { get }

    func itemsPublisher<Output: VaultItem>(for output: Output.Type) -> AnyPublisher<[Output], Never>
    func itemPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<Output, Never>
    func itemsPublisher(for category: ItemCategory?) -> AnyPublisher<[VaultItem], Never>
    func allItemsPublisher() -> AnyPublisher<[VaultItem], Never>

    func collectionsPublisher() -> AnyPublisher<[VaultCollection], Never>
    func collectionsPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<[VaultCollection], Never>

    func fetchedPersonalData<Output: PersonalDataCodable>(for output: Output.Type) -> FetchedPersonalData<Output>
    func fetch<Output: VaultItem>(with identifier: Identifier, type: Output.Type) throws -> Output?

    func delete(_ vaultItem: VaultItem)
    func delete<Item: PersonalDataCodable>(_ item: Item) throws

    func save<Item: VaultItem>(_ item: Item) throws -> Item
    func save<Item: VaultItem>(_ items: [Item]) throws -> [Item]
    func save<ItemType: PersonalDataCodable>(_ item: ItemType) throws -> ItemType
    func save(_ item: GeneratedPassword) throws -> GeneratedPassword

    func count<ItemType: PersonalDataCodable>(for type: ItemType.Type) throws -> Int
    func link(_ generatedPassword: GeneratedPassword, to credential: Credential) throws -> GeneratedPassword

    func updateLastUseDate(of items: [VaultItem], origin: Set<LastUseUpdateOrigin>)
    func sharedItem(with id: Identifier) -> VaultItem?
}
