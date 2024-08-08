import Foundation

enum SQLQuery {
  case getAllCategories
  case getAllDomains
  case getCategoryId(forDomain: String)

  private struct SQLKeys {
    struct Tables {
      static let categories = "CATEGORIES"
      static let domainCategories = "DOMAIN_CATEGORIES"
    }
    static let domainColumn = "DOMAIN"
  }

  func buildQuery() -> String {
    switch self {
    case .getAllCategories:
      return "SELECT * FROM \(SQLKeys.Tables.categories);"
    case .getCategoryId(let domain):
      return """
        SELECT * FROM \(SQLKeys.Tables.domainCategories) where \(SQLKeys.domainColumn)="\(domain)";
        """
    case .getAllDomains:
      return """
        SELECT \(SQLKeys.domainColumn) FROM \(SQLKeys.Tables.domainCategories);
        """
    }
  }
}
