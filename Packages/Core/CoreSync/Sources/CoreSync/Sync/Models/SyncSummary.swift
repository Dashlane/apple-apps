import DashTypes
import Foundation

typealias TransactionTimestampSummary = [String: TimestampByRawIds]

public struct SyncSummary: Decodable {
  let timestamp: Timestamp
  let summary: TransactionTimestampSummary
}

extension SyncSummary {
  func allTimestamps(withTypes acceptedTypes: Set<PersonalDataContentType>) -> TimestampByIds {
    return
      summary
      .filter { summary in
        guard let type = PersonalDataContentType(rawValue: summary.key) else {
          return false
        }
        return acceptedTypes.contains(type)
      }
      .values
      .map(TimestampByIds.init)
      .reduce([:]) { $0.merging($1) { (current, _) in current } }
  }
}

extension TimestampIdPair {
  fileprivate init?(tuple: (key: Identifier, value: Timestamp)) {
    self.init(id: tuple.key, timestamp: tuple.value)
  }
}
