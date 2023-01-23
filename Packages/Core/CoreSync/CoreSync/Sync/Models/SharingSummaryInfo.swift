import Foundation
import SwiftTreats

public struct SharingSummaryInfo: Decodable {
    
    public let items: [ItemSummary]
    public let itemGroups: [GroupSummary]
    public let userGroups: [GroupSummary]
}
