import Foundation
import CorePersonalData
import DashlaneAppKit

extension VaultItemsService {
    func createDefaultItems() {
        self.createDefaultCategories()
        self.createDefaultEmail()
    }

    func createDefaultEmail() {
        do {
            var email = Email()
            email.value = login.email
            email.name = L10n.Localizable.kwEmailIOS + " 1" 
            _ = try database.save(email)
        } catch {
            logger.error("createDefaultEmail error", error: error)
        }
    }

    func createDefaultCategories() {
        do {
            if try database.count(for: CredentialCategory.self) == 0 {
                try self.createDefaultCredentialCategories()
            }

            if try database.count(for: SecureNoteCategory.self) == 0 {
                try self.createDefaultSecureNotesCategories()
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
        let categories = [L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteAppPasswords,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteDatabase,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteFinance,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteLegal,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteMemberships,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteOther,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNotePersonal,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteServer,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteSoftwareLicenses,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteWifiPasswords,
                          L10n.Localizable.KWSecureNoteCategoriesManager.categoryNoteWork]
            .map { categoryName -> SecureNoteCategory in
                var category = SecureNoteCategory() 
                category.name = categoryName
                return category
        }
        _ = try database.save(categories)

    }
}
