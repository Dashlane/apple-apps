import Foundation
import GRDB
import SwiftTreats

extension Collection
where
  Element: FetchableRecord & TableRecord & Identifiable & PersistableRecord,
  Element.ID: DatabaseValueConvertible
{
  func update(_ db: Database, from values: [Element]) throws {
    let existingValues = Dictionary(values: values)
    let newIds = self.map(\.id)

    for newValue in self {
      if let value = existingValues[newValue.id] {
        try newValue.updateChanges(db, from: value)
      } else {
        try newValue.insert(db)
      }
    }

    for value in values where !newIds.contains(value.id) {
      try value.delete(db)
    }
  }
}
