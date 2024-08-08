import CoreCategorizer
import CorePersonalData
import Foundation

extension CategorizerProtocol {
  public func allCategoriesKey() -> [String] {
    return categories.map { $0.code }
  }

  public func allCategoriesName() -> [String] {
    return allCategoriesKey().map { NSLocalizedString($0, comment: "") }
  }

  public func categorize(_ credential: Credential) -> CoreCategorizer.Category? {
    guard let domain = credential.url?.domain?.name else {
      return nil
    }

    return try? categorize(domain: domain)
  }
}
