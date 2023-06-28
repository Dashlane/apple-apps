import Foundation
import DashTypes

public protocol SharingGroupMember {
    var status: SharingMemberStatus { get }
    var permission: SharingPermission { get }
    var signatureId: String { get }
    var proposeSignature: String? { get }
    var acceptSignature: String? { get }
    var encryptedGroupKey: String? { get }
    var parentGroupId: Identifier { get }
}

public extension SharingMemberStatus {
    var isAcceptedOrPending: Bool {
        return [.pending, .accepted].contains(self)
    }
}

extension UserGroupMember: SharingGroupMember {
    public var signatureId: String {
        return id.rawValue
    }
}

extension User: SharingGroupMember {
    public var signatureId: String {
        return id
    }
}
