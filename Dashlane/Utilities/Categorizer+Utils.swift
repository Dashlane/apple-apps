import Foundation
import CoreCategorizer
import CorePersonalData

extension CategorizerProtocol {
    func allCategoriesKey() -> [String] {
        return categories.map { $0.code }
    }

    func allCategoriesName() -> [String] {
        return allCategoriesKey().map { NSLocalizedString($0, comment: "") }
    }

    func categorize(_ credential: Credential) -> CoreCategorizer.Category? {
        guard let domain = credential.url?.domain?.name else {
            return nil
        }

        return try? categorize(domain: domain)
    }
}
