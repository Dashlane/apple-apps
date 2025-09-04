import CoreTypes
import Foundation

public struct SharingSummary: Decodable, Equatable {
  public let items: [Identifier: SharingTimestamp]
  public let itemGroups: [Identifier: SharingRevision]
  public let userGroups: [Identifier: SharingRevision]
  public let collections: [Identifier: SharingRevision]

  public init(
    items: [Identifier: SharingTimestamp] = [:],
    itemGroups: [Identifier: SharingRevision] = [:],
    userGroups: [Identifier: SharingRevision] = [:],
    collections: [Identifier: SharingRevision] = [:]
  ) {
    self.items = items
    self.itemGroups = itemGroups
    self.userGroups = userGroups
    self.collections = collections
  }
}

public typealias SharingRevision = Int
