import Combine
import DashTypes
import Foundation
import GRDB

extension SQLiteDriver {

  private func eventPublisher(for id: Identifier) -> some Publisher {
    return
      eventPublisher
      .filter { event in
        switch event {
        case .invalidation:
          return true
        case let .incrementalChanges(changes):
          return changes.contains { $0.id == id }
        }
      }
      .prepend(.invalidation)
  }

  public func publisher(with id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error> {
    eventPublisher(for: id)
      .tryMap { _ in
        try read { db in
          try db.fetchOne(with: id)
        }
      }
      .eraseToAnyPublisher()
  }

  public func publisher(withParentId id: Identifier) -> AnyPublisher<PersonalDataRecord?, Error> {
    eventPublisher(for: id)
      .tryMap { _ in
        try read { db in
          try db.fetchOne(withParentId: id)
        }
      }
      .eraseToAnyPublisher()
  }

  public func metadataPublisher(with id: Identifier) -> AnyPublisher<RecordMetadata?, Error> {
    eventPublisher(for: id)
      .tryMap { _ in
        try read { db in
          try db.fetchOneMetadata(with: id)
        }
      }
      .eraseToAnyPublisher()
  }
}
