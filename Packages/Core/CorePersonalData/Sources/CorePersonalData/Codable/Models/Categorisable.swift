import Foundation
import DashTypes

public protocol Categorisable {
    associatedtype CategoryType: PersonalDataCategory
    var category: CategoryType? { get set }
}

public protocol PersonalDataCategory {
    var id: Identifier { get }
    var name: String { get set }
}
