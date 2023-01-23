import Foundation
import DashlaneReportKit

public struct VaultItemUsageLogData {
    public var website: String?
    public var details: String?
    public var origin: UsageLogCode11PersonalData.FromType?
    public var country: String?
    public var color: String?
    public var secure: Bool?
    public var size: Int?
    public var category: String?
    public var attachmentCount: Int
    
    public init(website: String? = nil,
                details: String? = nil,
                origin: UsageLogCode11PersonalData.FromType? = nil,
                country: String? = nil,
                color: String? = nil,
                secure: Bool? = nil,
                size: Int? = nil,
                category: String? = nil,
                attachmentCount: Int = 0) {
        self.website = website
        self.details = details
        self.origin = origin
        self.category = category
        self.country = country
        self.color = color
        self.secure = secure
        self.size = size
        self.attachmentCount = attachmentCount
    }
}
