import Combine
import DashTypes
import Foundation

extension ApplicationDBStack {
  public func changeSetsPublisher<T: HistoryChangeTracking>(for item: T) -> ChangeSetPublisher<T> {
    return itemPublisher(withParentId: item.id, type: DataChangeHistory.self)
      .map { history in
        guard let changeSets = history?.changeSets else {
          return []
        }

        return changeSets.compactMap { changeSet -> PersonalDataChangeSet<T>? in
          guard !changeSet.removed,
            case let content = changeSet.sanitizedPreviousRecordContent(),
            !content.isEmpty,
            let modificationDate = changeSet.modificationDate,
            let content = try? decode(T.PreviousChangeContent.self, from: content)
          else {
            return nil
          }

          return PersonalDataChangeSet(
            id: changeSet.id,
            modificationDate: modificationDate,
            revertContent: content)
        }
        .sorted()
      }
      .replaceError(with: [])
      .eraseToAnyPublisher()
  }

  public func revert<T: HistoryChangeTracking>(
    _ id: Identifier,
    to changeSet: PersonalDataChangeSet<T>
  ) throws {
    try driver.write { db in
      guard var record = try db.fetchOne(with: id) else {
        return
      }

      let newContent = try encoder.encode(changeSet.revertContent)

      record.content.merge(newContent) { _, fromChangeSet in
        fromChangeSet
      }

      try db.save(record)
    }
  }

}

extension DataChangeHistory.ChangeSet {
  func sanitizedPreviousRecordContent() -> PersonalDataCollection {
    previousRecordContent.filter {
      changedKeys.contains($0.key.capitalizingFirstLetter())
    }
  }
}
