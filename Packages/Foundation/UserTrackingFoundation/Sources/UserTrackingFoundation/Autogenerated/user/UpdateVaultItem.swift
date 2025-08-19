import Foundation

extension UserEvent {

  public struct `UpdateVaultItem`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.Action, `collectionCount`: Int? = nil,
      `credentialOriginalSecurityStatus`: Definition.CredentialSecurityStatus? = nil,
      `credentialSecurityStatus`: Definition.CredentialSecurityStatus? = nil,
      `fieldsEdited`: [Definition.Field]? = nil,
      `isCredentialCurrentlyEligibleToPasswordChanger`: Bool? = nil,
      `itemId`: String, `itemType`: Definition.ItemType, `multiSelectId`: LowercasedUUID? = nil,
      `space`: Definition.Space, `updateCredentialOrigin`: Definition.UpdateCredentialOrigin? = nil
    ) {
      self.action = action
      self.collectionCount = collectionCount
      self.credentialOriginalSecurityStatus = credentialOriginalSecurityStatus
      self.credentialSecurityStatus = credentialSecurityStatus
      self.fieldsEdited = fieldsEdited
      self.isCredentialCurrentlyEligibleToPasswordChanger =
        isCredentialCurrentlyEligibleToPasswordChanger
      self.itemId = itemId
      self.itemType = itemType
      self.multiSelectId = multiSelectId
      self.space = space
      self.updateCredentialOrigin = updateCredentialOrigin
    }
    public let action: Definition.Action
    public let collectionCount: Int?
    public let credentialOriginalSecurityStatus: Definition.CredentialSecurityStatus?
    public let credentialSecurityStatus: Definition.CredentialSecurityStatus?
    public let fieldsEdited: [Definition.Field]?
    public let isCredentialCurrentlyEligibleToPasswordChanger: Bool?
    public let itemId: String
    public let itemType: Definition.ItemType
    public let multiSelectId: LowercasedUUID?
    public let name = "update_vault_item"
    public let space: Definition.Space
    public let updateCredentialOrigin: Definition.UpdateCredentialOrigin?
  }
}
