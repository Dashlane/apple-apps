import Foundation
import GRDB

extension PendingUserGroup: FetchableRecord { }

extension PendingUserGroup: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PendingUserGroup.CodingKeys.self)
        self.userGroupInfo = try container.decode(UserGroupInfo.self, forKey: .userGroupInfo)
        self.referrer = try container.decode([String].self, forKey: .referrer).first
    }
}
