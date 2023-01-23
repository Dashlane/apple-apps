import Foundation
import GRDB
import DashTypes


extension DerivableRequest where RowDecoder: Identifiable, RowDecoder.ID: DatabaseValueConvertible {
        func filter(id: RowDecoder.ID) -> Self {
        filter(Column.id == id.databaseValue)
    }
        func filterOut(id: RowDecoder.ID) -> Self {
        filter(Column.id != id.databaseValue)
    }
}
