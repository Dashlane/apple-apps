import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import DashTypes

public class VaultItemsPublishersStore {

  @Published public internal(set) var credentials: [Credential]
  @Published public internal(set) var passkeys: [Passkey]

  @Published public internal(set) var secureNotes: [SecureNote]
  @Published public internal(set) var secrets: [Secret]

  @Published public internal(set) var creditCards: [CreditCard]
  @Published public internal(set) var bankAccounts: [BankAccount]

  @Published public internal(set) var identities: [Identity]
  @Published public internal(set) var emails: [CorePersonalData.Email]
  @Published public internal(set) var phones: [Phone]
  @Published public internal(set) var addresses: [Address]
  @Published public internal(set) var companies: [Company]
  @Published public internal(set) var websites: [PersonalWebsite]

  @Published public internal(set) var passports: [Passport]
  @Published public internal(set) var idCards: [IDCard]
  @Published public internal(set) var fiscalInformation: [FiscalInformation]
  @Published public internal(set) var socialSecurityInformation: [SocialSecurityInformation]
  @Published public internal(set) var drivingLicenses: [DrivingLicence]

  @Published public var loaded: Bool = false

  public init(
    credentials: [Credential] = [],
    passkeys: [Passkey] = [],
    secureNotes: [SecureNote] = [],
    secrets: [Secret] = [],
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
    secureNotesCategories: [SecureNoteCategory] = []
  ) {
    self.credentials = credentials
    self.passkeys = passkeys
    self.secureNotes = secureNotes
    self.secrets = secrets
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
  }
}

public protocol VaultItemsStore: VaultItemsPublishersStore {
  var userSpacesService: UserSpacesService { get }
  var featureService: FeatureServiceProtocol { get }
  var capabilityService: CapabilityServiceProtocol { get }

  func dataSectionsPublisher(for category: ItemCategory?) -> AnyPublisher<[DataSection], Never>
}
