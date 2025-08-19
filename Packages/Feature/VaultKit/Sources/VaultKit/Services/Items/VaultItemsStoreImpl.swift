import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession

public final class VaultItemsStoreImpl:
  VaultItemsPublishersStore,
  VaultItemsStore
{

  public let userSpacesService: UserSpacesService
  public let featureService: FeatureServiceProtocol
  public let capabilityService: CapabilityServiceProtocol
  public let vaultItemDatabase: VaultItemDatabaseProtocol

  public init(
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    capabilityService: CapabilityServiceProtocol,
    vaultItemDatabase: VaultItemDatabaseProtocol
  ) {
    self.vaultItemDatabase = vaultItemDatabase
    self.featureService = featureService
    self.capabilityService = capabilityService
    self.userSpacesService = userSpacesService

    super.init()
    configureLists()
  }

  private func configureLists() {
    let credentials =
      vaultItemDatabase
      .itemsPublisher(for: Credential.self)
      .shareReplayLatest()
    credentials.assign(to: &$credentials)

    let passkeys =
      vaultItemDatabase
      .itemsPublisher(for: Passkey.self)
      .shareReplayLatest()
    passkeys.assign(to: &$passkeys)

    let secureNotes =
      vaultItemDatabase
      .itemsPublisher(for: SecureNote.self)
      .shareReplayLatest()
    secureNotes.assign(to: &$secureNotes)

    let secrets =
      vaultItemDatabase
      .itemsPublisher(for: Secret.self)
      .shareReplayLatest()
    secrets.assign(to: &$secrets)

    let creditCards =
      vaultItemDatabase
      .itemsPublisher(for: CreditCard.self)
      .shareReplayLatest()
    creditCards.assign(to: &$creditCards)

    let bankAccounts =
      vaultItemDatabase
      .itemsPublisher(for: BankAccount.self)
      .shareReplayLatest()
    bankAccounts.assign(to: &$bankAccounts)

    let identities =
      vaultItemDatabase
      .itemsPublisher(for: Identity.self)
      .shareReplayLatest()
    identities.assign(to: &$identities)

    let emails =
      vaultItemDatabase
      .itemsPublisher(for: Email.self)
      .shareReplayLatest()
    emails.assign(to: &$emails)

    let phones =
      vaultItemDatabase
      .itemsPublisher(for: Phone.self)
      .shareReplayLatest()
    phones.assign(to: &$phones)

    let addresses =
      vaultItemDatabase
      .itemsPublisher(for: Address.self)
      .shareReplayLatest()
    addresses.assign(to: &$addresses)

    let companies =
      vaultItemDatabase
      .itemsPublisher(for: Company.self)
      .shareReplayLatest()
    companies.assign(to: &$companies)

    let websites =
      vaultItemDatabase
      .itemsPublisher(for: PersonalWebsite.self)
      .shareReplayLatest()
    websites.assign(to: &$websites)

    let passports =
      vaultItemDatabase
      .itemsPublisher(for: Passport.self)
      .shareReplayLatest()
    passports.assign(to: &$passports)

    let idCards =
      vaultItemDatabase
      .itemsPublisher(for: IDCard.self)
      .shareReplayLatest()
    idCards.assign(to: &$idCards)

    let fiscalInformation =
      vaultItemDatabase
      .itemsPublisher(for: FiscalInformation.self)
      .shareReplayLatest()
    fiscalInformation.assign(to: &$fiscalInformation)

    let socialSecurityInformation =
      vaultItemDatabase
      .itemsPublisher(for: SocialSecurityInformation.self)
      .shareReplayLatest()
    socialSecurityInformation.assign(to: &$socialSecurityInformation)

    let drivingLicenses =
      vaultItemDatabase
      .itemsPublisher(for: DrivingLicence.self)
      .shareReplayLatest()
    drivingLicenses.assign(to: &$drivingLicenses)

    let wifis =
      vaultItemDatabase
      .itemsPublisher(for: WiFi.self)
      .shareReplayLatest()
    wifis.assign(to: &$wifis)

    Publishers.MergeMany(
      [
        credentials.first().map { _ in true }.eraseToAnyPublisher(),
        passkeys.first().map { _ in true }.eraseToAnyPublisher(),
        secureNotes.first().map { _ in true }.eraseToAnyPublisher(),
        secrets.first().map { _ in true }.eraseToAnyPublisher(),
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
        wifis.first().map { _ in true }.eraseToAnyPublisher(),
      ]
    )
    .collect()
    .sinkOnce { [weak self] (_: [Bool]) in
      self?.loaded = true
    }
  }
}

extension VaultItemsStoreImpl {
  convenience init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    capabilityService: CapabilityServiceProtocol
  ) async {
    self.init(
      userSpacesService: userSpacesService,
      featureService: featureService,
      capabilityService: capabilityService,
      vaultItemDatabase: vaultItemDatabase
    )

    for await _ in $loaded.filter({ $0 == true }).removeDuplicates().values {
      return
    }
  }
}

public class VaultItemsStoreMock: VaultItemsPublishersStore, VaultItemsStore {
  public var userSpacesService: CorePremium.UserSpacesService = .mock()

  public var featureService: any CoreFeature.FeatureServiceProtocol = .mock()

  public var capabilityService: any CorePremium.CapabilityServiceProtocol = .mock()

  public func dataSectionsPublisher(for category: ItemCategory?) -> AnyPublisher<
    [DataSection], Never
  > {
    Just([]).eraseToAnyPublisher()
  }

  init(credentials: [Credential]) {
    super.init()
    self.credentials = credentials
  }
}

extension VaultItemsStore where Self == VaultItemsStoreMock {
  public static func mock(
    database: VaultItemDatabaseProtocol = .mock(), credentials: [Credential] = []
  ) -> VaultItemsStore {
    VaultItemsStoreMock(credentials: credentials)
  }
}
