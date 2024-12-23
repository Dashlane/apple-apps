import Combine
import CoreLocalization
import CorePersonalData

extension VaultItemsStore {
  private var enabledItemCategories: [ItemCategory] {
    let categories = ItemCategory.allCases
    let isSecretsManagementAvailable =
      capabilityService.status(of: .secretManagement).isAvailable
      && featureService.isEnabled(.vaultSecrets)
    return isSecretsManagementAvailable ? categories : categories.filter { $0 != .secrets }
  }

  public func allItemsPublisher() -> AnyPublisher<[VaultItem], Never> {
    enabledItemCategories
      .map { itemsPublisher(for: $0) }
      .combineLatest()
      .map { items in
        items.flatMap { $0 }
      }
      .eraseToAnyPublisher()
  }

  public func itemsPublisher(for category: ItemCategory?) -> AnyPublisher<[VaultItem], Never> {
    switch category {
    case .none:
      return allItemsPublisher()
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
    case .secrets:
      return secretsPublisher()
    }
  }

  public func dataSectionsPublisher(for category: ItemCategory?) -> AnyPublisher<
    [DataSection], Never
  > {
    switch category {
    case .none:
      return allItemsPublisher()
        .filter(by: userSpacesService.$configuration)
        .map { $0.alphabeticallyGrouped() }
        .eraseToAnyPublisher()
    case .credentials:
      return credentialsPublisher()
        .map { $0.alphabeticallyGrouped() }
        .filter(by: userSpacesService.$configuration)
        .eraseToAnyPublisher()
    case .secureNotes:
      return secureNotesPublisher()
        .map { $0.alphabeticallyGrouped() }
        .filter(by: userSpacesService.$configuration)
        .eraseToAnyPublisher()
    case .secrets:
      return
        $secrets
        .map { $0.alphabeticallyGrouped() }
        .filter(by: userSpacesService.$configuration)
        .eraseToAnyPublisher()
    case .payments:
      let creditCardsPublisher =
        $creditCards
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let bankAccountsPublisher =
        $bankAccounts
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      return [creditCardsPublisher, bankAccountsPublisher]
        .combineLatest()
        .filter(by: userSpacesService.$configuration)
        .eraseToAnyPublisher()
    case .personalInfo:
      let identities =
        $identities
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let emails =
        $emails
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let phones =
        $phones
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let addresses =
        $addresses
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let companies =
        $companies
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()
      let websites =
        $websites
        .map { $0.alphabeticallySorted() }
        .map(DataSection.init)
        .eraseToAnyPublisher()

      return [
        identities,
        emails,
        phones,
        addresses,
        companies,
        websites,
      ]
      .combineLatest()
      .filter(by: userSpacesService.$configuration)
      .eraseToAnyPublisher()

    case .ids:
      let passports =
        $passports
        .map { $0.alphabeticallySorted() }
        .map { $0 as [VaultItem] }
        .eraseToAnyPublisher()
      let drivingLicenses =
        $drivingLicenses
        .map { $0.alphabeticallySorted() }
        .map { $0 as [VaultItem] }
        .eraseToAnyPublisher()
      let socialSecurities =
        $socialSecurityInformation
        .map { $0.alphabeticallySorted() }
        .map { $0 as [VaultItem] }
        .eraseToAnyPublisher()
      let idCards =
        $idCards
        .map { $0.alphabeticallySorted() }
        .map { $0 as [VaultItem] }
        .eraseToAnyPublisher()
      let fiscalInfo =
        $fiscalInformation
        .map { $0.alphabeticallySorted() }
        .map { $0 as [VaultItem] }
        .eraseToAnyPublisher()

      return [
        passports,
        drivingLicenses,
        socialSecurities,
        idCards,
        fiscalInfo,
      ]
      .combineLatest()
      .map { $0.flatMap { $0 } }
      .filter(by: userSpacesService.$configuration)
      .map { items in
        [DataSection(name: L10n.Core.itemsTitle, items: items)]
      }
      .eraseToAnyPublisher()
    }
  }

  private func credentialsPublisher() -> AnyPublisher<[VaultItem], Never> {
    let credentials =
      $credentials
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let passkeys =
      $passkeys
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()

    return [credentials, passkeys]
      .combineLatest()
      .map { items in
        items.flatMap { $0 }
      }
      .eraseToAnyPublisher()
  }

  private func secureNotesPublisher() -> AnyPublisher<[VaultItem], Never> {
    $secureNotes
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
  }

  private func secretsPublisher() -> AnyPublisher<[VaultItem], Never> {
    $secrets
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
  }

  private func paymentsPublisher() -> AnyPublisher<[VaultItem], Never> {
    let creditCards =
      $creditCards
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let bankAccounts =
      $bankAccounts
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()

    return [creditCards, bankAccounts]
      .combineLatest()
      .map { items in
        items.flatMap { $0 }
      }
      .eraseToAnyPublisher()
  }

  private func personalInfoPublisher() -> AnyPublisher<[VaultItem], Never> {
    let identities =
      $identities
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let emails =
      $emails
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let phones =
      $phones
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let addresses =
      $addresses
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let companies =
      $companies
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let websites =
      $websites
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()

    return [
      identities,
      emails,
      phones,
      addresses,
      companies,
      websites,
    ]
    .combineLatest()
    .map { items in
      items.flatMap { $0 }
    }
    .eraseToAnyPublisher()
  }

  private func idsPublisher() -> AnyPublisher<[VaultItem], Never> {
    let passports =
      $passports
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let drivingLicenses =
      $drivingLicenses
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let socialSecurityInfo =
      $socialSecurityInformation
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let idCards =
      $idCards
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()
    let fiscalInfo =
      $fiscalInformation
      .map { $0 as [VaultItem] }
      .eraseToAnyPublisher()

    return [
      passports,
      drivingLicenses,
      socialSecurityInfo,
      idCards,
      fiscalInfo,
    ]
    .combineLatest()
    .map { items in
      items.flatMap { $0 }
    }
    .eraseToAnyPublisher()
  }
}
