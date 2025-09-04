import Combine
import CoreTypes
import Foundation

public struct PersonalDataChangeSet<T: HistoryChangeTracking>: Identifiable, Comparable {
  public static func < (lhs: PersonalDataChangeSet<T>, rhs: PersonalDataChangeSet<T>) -> Bool {
    lhs.modificationDate < rhs.modificationDate
  }

  public let id: Identifier

  public let modificationDate: Date
  public let revertContent: T.PreviousChangeContent
}

public typealias ChangeSetPublisher<T: HistoryChangeTracking> = AnyPublisher<
  [PersonalDataChangeSet<T>], Never
>
