import Foundation

public protocol HistoryChangeTracking: PersonalDataCodable {
  associatedtype PreviousChangeContent: HistoryChangePreviousContent
}

public protocol HistoryChangePreviousContent: Codable, Equatable {}
