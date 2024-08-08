import Foundation

extension UserEvent {

  public struct `VaultReport`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(
      `collectionsPerItemAverageCount`: Int? = nil, `collectionsSharedCount`: Int? = nil,
      `collectionsTotalCount`: Int? = nil, `darkWebAlertsActiveCount`: Int? = nil,
      `darkWebAlertsCount`: Int? = nil, `domainsWithoutAutofillCount`: Int? = nil,
      `ids`: Definition.ItemTypeCounts, `itemsPerCollectionAverageCount`: Int? = nil,
      `itemsSharedCount`: Int? = nil, `itemsTotalCount`: Int? = nil,
      `passkeys`: Definition.ItemTypeCounts? = nil, `passwords`: Definition.ItemTypeCounts,
      `passwordsCompromisedCount`: Int, `passwordsCompromisedThroughDarkWebCount`: Int? = nil,
      `passwordsExcludedCount`: Int, `passwordsProtectedWithMasterPasswordCount`: Int? = nil,
      `passwordsReusedCount`: Int, `passwordsSafeCount`: Int, `passwordsWeakCount`: Int,
      `passwordsWithAutologinDisabledCount`: Int? = nil, `passwordsWithOtpCount`: Int,
      `payments`: Definition.ItemTypeCounts, `personalInfo`: Definition.ItemTypeCounts,
      `scope`: Definition.Scope, `secrets`: Definition.ItemTypeCounts? = nil,
      `secureNotes`: Definition.ItemTypeCounts, `securityAlertsActiveCount`: Int? = nil,
      `securityAlertsCount`: Int? = nil, `securityScore`: Int? = nil
    ) {
      self.collectionsPerItemAverageCount = collectionsPerItemAverageCount
      self.collectionsSharedCount = collectionsSharedCount
      self.collectionsTotalCount = collectionsTotalCount
      self.darkWebAlertsActiveCount = darkWebAlertsActiveCount
      self.darkWebAlertsCount = darkWebAlertsCount
      self.domainsWithoutAutofillCount = domainsWithoutAutofillCount
      self.ids = ids
      self.itemsPerCollectionAverageCount = itemsPerCollectionAverageCount
      self.itemsSharedCount = itemsSharedCount
      self.itemsTotalCount = itemsTotalCount
      self.passkeys = passkeys
      self.passwords = passwords
      self.passwordsCompromisedCount = passwordsCompromisedCount
      self.passwordsCompromisedThroughDarkWebCount = passwordsCompromisedThroughDarkWebCount
      self.passwordsExcludedCount = passwordsExcludedCount
      self.passwordsProtectedWithMasterPasswordCount = passwordsProtectedWithMasterPasswordCount
      self.passwordsReusedCount = passwordsReusedCount
      self.passwordsSafeCount = passwordsSafeCount
      self.passwordsWeakCount = passwordsWeakCount
      self.passwordsWithAutologinDisabledCount = passwordsWithAutologinDisabledCount
      self.passwordsWithOtpCount = passwordsWithOtpCount
      self.payments = payments
      self.personalInfo = personalInfo
      self.scope = scope
      self.secrets = secrets
      self.secureNotes = secureNotes
      self.securityAlertsActiveCount = securityAlertsActiveCount
      self.securityAlertsCount = securityAlertsCount
      self.securityScore = securityScore
    }
    public let collectionsPerItemAverageCount: Int?
    public let collectionsSharedCount: Int?
    public let collectionsTotalCount: Int?
    public let darkWebAlertsActiveCount: Int?
    public let darkWebAlertsCount: Int?
    public let domainsWithoutAutofillCount: Int?
    public let ids: Definition.ItemTypeCounts
    public let itemsPerCollectionAverageCount: Int?
    public let itemsSharedCount: Int?
    public let itemsTotalCount: Int?
    public let name = "vault_report"
    public let passkeys: Definition.ItemTypeCounts?
    public let passwords: Definition.ItemTypeCounts
    public let passwordsCompromisedCount: Int
    public let passwordsCompromisedThroughDarkWebCount: Int?
    public let passwordsExcludedCount: Int
    public let passwordsProtectedWithMasterPasswordCount: Int?
    public let passwordsReusedCount: Int
    public let passwordsSafeCount: Int
    public let passwordsWeakCount: Int
    public let passwordsWithAutologinDisabledCount: Int?
    public let passwordsWithOtpCount: Int
    public let payments: Definition.ItemTypeCounts
    public let personalInfo: Definition.ItemTypeCounts
    public let scope: Definition.Scope
    public let secrets: Definition.ItemTypeCounts?
    public let secureNotes: Definition.ItemTypeCounts
    public let securityAlertsActiveCount: Int?
    public let securityAlertsCount: Int?
    public let securityScore: Int?
  }
}
