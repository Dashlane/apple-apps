import CoreCategorizer
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSession
import CoreTypes
import LogFoundation

public protocol DefaultVaultItemsServiceProtocol {
  func createItemsIfNeeded(for context: SessionLoadingContext)
}

struct DefaultVaultItemsService: VaultKitServicesInjecting, DefaultVaultItemsServiceProtocol {

  private let login: Login

  private let logger: Logger
  private let database: ApplicationDatabase
  private let userSpacesService: UserSpacesService
  private let categorizer: CategorizerProtocol

  init(
    login: Login,
    logger: Logger,
    database: ApplicationDatabase,
    userSpacesService: UserSpacesService,
    categorizer: CategorizerProtocol
  ) {
    self.logger = logger
    self.login = login
    self.database = database
    self.userSpacesService = userSpacesService
    self.categorizer = categorizer
  }

  func createItemsIfNeeded(for context: SessionLoadingContext) {
    switch context {
    case .accountCreation:
      createNewAccountDefaultItems()

    case .localLogin(.afterLogout(reason: .loginEmailChanged), _):
      try? createAccountEmailIfNotExistAlready()

    default:
      break
    }
  }

  func createNewAccountDefaultItems() {
    createDefaultCategories()
    createDefaultEmail()
  }

  func createAccountEmailIfNotExistAlready() throws {
    let emails = try database.fetchAll(Email.self)
    guard
      !emails.contains(where: {
        $0.value.lowercased().trimmingCharacters(in: .whitespaces) == login.email
      })
    else {
      return
    }

    var nextAvailableEmailNumber = 1

    while emails.contains(where: { $0.name == "Email \(nextAvailableEmailNumber)" }) {
      nextAvailableEmailNumber += 1
    }

    createDefaultEmail(number: nextAvailableEmailNumber)
  }

  private func createDefaultEmail(number: Int = 1) {
    do {
      var email = Email()
      email.value = login.email
      email.name = CoreL10n.kwEmailIOS + " \(number)"
      email.spaceId = userSpacesService.configuration.defaultSpace(for: email).personalDataId

      _ = try database.save(email)
    } catch {
      logger.error("createDefaultEmail error", error: error)
    }
  }

  private func createDefaultCategories() {
    do {
      if try database.count(for: CredentialCategory.self) == 0 {
        try createDefaultCredentialCategories()
      }

      if try database.count(for: SecureNoteCategory.self) == 0 {
        try createDefaultSecureNotesCategories()
      }
    } catch {
      logger.error("createDefaultCategories error", error: error)
    }
  }

  private func createDefaultCredentialCategories() throws {
    let categories = categorizer.allCategoriesName()
      .map { categoryName -> CredentialCategory in
        var category = CredentialCategory()
        category.name = categoryName
        return category
      }
    _ = try database.save(categories)
  }

  private func createDefaultSecureNotesCategories() throws {
    let categories = [
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteAppPasswords,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteDatabase,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteFinance,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteLegal,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteMemberships,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteOther,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNotePersonal,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteServer,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteSoftwareLicenses,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteWifiPasswords,
      CoreL10n.KWSecureNoteCategoriesManager.categoryNoteWork,
    ]
    .map { categoryName -> SecureNoteCategory in
      var category = SecureNoteCategory()
      category.name = categoryName
      return category
    }
    _ = try database.save(categories)
  }
}

extension DefaultVaultItemsServiceProtocol where Self == DefaultVaultItemsService {
  static var mock: DefaultVaultItemsServiceProtocol {
    DefaultVaultItemsService(
      login: .init("_"),
      logger: .mock,
      database: ApplicationDBStack.mock(),
      userSpacesService: UserSpacesService.mock(),
      categorizer: CategorizerMock()
    )
  }
}
