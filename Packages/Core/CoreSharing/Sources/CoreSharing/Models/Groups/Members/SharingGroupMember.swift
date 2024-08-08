import DashTypes
import Foundation

public protocol SharingGroupMember: Sendable {
  associatedtype Group: SharingGroup
  associatedtype Target

  var status: SharingMemberStatus { get }
  var permission: SharingPermission { get }
  var signatureId: String { get }
  var proposeSignature: String? { get }
  var acceptSignature: String? { get }
  var encryptedGroupKey: String? { get }
  var parentGroupId: Identifier { get }
}

extension SharingMemberStatus {
  public var isAcceptedOrPending: Bool {
    return [.pending, .accepted].contains(self)
  }
}
