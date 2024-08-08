import CoreCategorizer
import CoreLocalization
import CorePersonalData
import CorePremium
import DashTypes

protocol DefaultVaultItemsServiceProtocol {
  func createDefaultItems()
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

  func createDefaultItems() {
    createDefaultCategories()
    createDefaultEmail()
  }

  private func createDefaultEmail() {
    do {
      var email = Email()
      email.value = login.email
      email.name = L10n.Core.kwEmailIOS + " 1"
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
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteAppPasswords,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteDatabase,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteFinance,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteLegal,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteMemberships,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteOther,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNotePersonal,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteServer,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteSoftwareLicenses,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteWifiPasswords,
      L10n.Core.KWSecureNoteCategoriesManager.categoryNoteWork,
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
      logger: LoggerMock(),
      database: ApplicationDBStack.mock(),
      userSpacesService: UserSpacesService.mock(),
      categorizer: CategorizerMock()
    )
  }
}
