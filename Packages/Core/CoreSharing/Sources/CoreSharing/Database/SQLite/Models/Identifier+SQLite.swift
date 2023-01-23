import Foundation
import GRDB
import DashTypes

extension Identifier: DatabaseValueConvertible {
    public var databaseValue: DatabaseValue { rawValue.databaseValue }
    
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        guard let raw = String.fromDatabaseValue(dbValue) else {
            return nil
        }
        
        return .init(raw)
    }
}
