import Foundation
import DashTypes

public struct SharingSummary: Decodable, Equatable {
    public let items: [Identifier: SharingTimestamp]
    public let itemGroups: [Identifier: SharingRevision]
    public let userGroups: [Identifier: SharingRevision]

    public init(items: [Identifier: SharingTimestamp] = [:], itemGroups: [Identifier: SharingRevision] = [:], userGroups: [Identifier: SharingRevision] = [:]) {
        self.items = items
        self.itemGroups = itemGroups
        self.userGroups = userGroups
    }
}

public typealias SharingRevision = Int
