import Foundation

private struct DBKeys {

    struct Categories {
        static let tableName = "CATEGORIES"
    }

    struct Domain {
        static let tableName = "DOMAIN_CATEGORIES"

        struct Columns {
            static let domain = "DOMAIN"
            static let categoryId = "CATEGORY_ID"
        }
    }

    static let otherCategoryCode = "other"
}

public enum CategorizerError: Error {
    case defaultCategoryNotFound
    case categoriesNotFound
}

public protocol CategorizerProtocol {
    var categories: [Category] { get }
    var defaultCategory: Category { get }
    func categorize(domain: String) throws -> Category?
    func getAllDomains() throws -> [String]
}

public struct Categorizer: CategorizerProtocol {

    let db: SqliteDBWrapper
    public let categories: [Category]
    public let defaultCategory: Category

    let dbPath: String! = Bundle.module.path(forResource: "categories", ofType: "db")

    public init() throws {

        db = try SqliteDBWrapper(dbPath: dbPath)
        categories = try db.query(statement: SQLQuery.getAllCategories.buildQuery()).rows.compactMap(Category.init)

        guard categories.count != 0 else { throw CategorizerError.categoriesNotFound }
        guard let defaultCat = categories.first(where: { $0.code == DBKeys.otherCategoryCode }) else { 
            throw CategorizerError.defaultCategoryNotFound
        }
        defaultCategory = defaultCat

    }

    func category(forId id: String) -> Category? {
        return categories.first { $0.id == id }
    }

    public func categorize(domain: String) throws -> Category? {
        let lowercasedDomain = domain.lowercased()
        let statement = SQLQuery.getCategoryId(forDomain: lowercasedDomain).buildQuery()
        let queryResult = try db.query(statement: statement)
        if let categoryId = queryResult.data(forRow: 0, columnName: DBKeys.Domain.Columns.categoryId),
            let category = category(forId: categoryId) {
            return category
        }
        return nil
    }

    public func getAllDomains() throws -> [String] {
        try db.query(statement: SQLQuery.getAllDomains.buildQuery()).rows.compactMap(Domain.init).map(\.domain)
    }
}
