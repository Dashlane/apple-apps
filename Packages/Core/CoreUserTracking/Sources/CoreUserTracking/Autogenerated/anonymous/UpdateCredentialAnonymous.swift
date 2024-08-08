import Foundation

extension AnonymousEvent {

  public struct `UpdateCredential`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.Action, `associatedAppsAddedList`: [String]? = nil,
      `associatedAppsRemovedList`: [String]? = nil, `associatedWebsitesAddedList`: [String]? = nil,
      `associatedWebsitesRemovedList`: [String]? = nil,
      `credentialOriginalSecurityStatus`: Definition.CredentialSecurityStatus? = nil,
      `credentialSecurityStatus`: Definition.CredentialSecurityStatus? = nil,
      `domain`: Definition.Domain, `fieldList`: [Definition.Field]? = nil,
      `isCredentialCurrentlyEligibleToPasswordChanger`: Bool? = nil, `space`: Definition.Space,
      `updateCredentialOrigin`: Definition.UpdateCredentialOrigin? = nil
    ) {
      self.action = action
      self.associatedAppsAddedList = associatedAppsAddedList
      self.associatedAppsRemovedList = associatedAppsRemovedList
      self.associatedWebsitesAddedList = associatedWebsitesAddedList
      self.associatedWebsitesRemovedList = associatedWebsitesRemovedList
      self.credentialOriginalSecurityStatus = credentialOriginalSecurityStatus
      self.credentialSecurityStatus = credentialSecurityStatus
      self.domain = domain
      self.fieldList = fieldList
      self.isCredentialCurrentlyEligibleToPasswordChanger =
        isCredentialCurrentlyEligibleToPasswordChanger
      self.space = space
      self.updateCredentialOrigin = updateCredentialOrigin
    }
    public let action: Definition.Action
    public let associatedAppsAddedList: [String]?
    public let associatedAppsRemovedList: [String]?
    public let associatedWebsitesAddedList: [String]?
    public let associatedWebsitesRemovedList: [String]?
    public let credentialOriginalSecurityStatus: Definition.CredentialSecurityStatus?
    public let credentialSecurityStatus: Definition.CredentialSecurityStatus?
    public let domain: Definition.Domain
    public let fieldList: [Definition.Field]?
    public let isCredentialCurrentlyEligibleToPasswordChanger: Bool?
    public let name = "update_credential"
    public let space: Definition.Space
    public let updateCredentialOrigin: Definition.UpdateCredentialOrigin?
  }
}
