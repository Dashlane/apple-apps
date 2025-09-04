import Foundation

public struct PaymentsAccessibleStoreOffersCapabilities: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case activeDirectorySync = "activeDirectorySync"
    case activityLog = "activityLog"
    case adminPolicies = "adminPolicies"
    case autofillWithPhishingPrevention = "autofillWithPhishingPrevention"
    case canSeeCustomerSupportContacts = "canSeeCustomerSupportContacts"
    case collectionSharing = "collectionSharing"
    case creditMonitoring = "creditMonitoring"
    case dataLeak = "dataLeak"
    case devicesLimit = "devicesLimit"
    case groupSharing = "groupSharing"
    case identityRestoration = "identityRestoration"
    case identityTheftProtection = "identityTheftProtection"
    case inAppNudges = "inAppNudges"
    case internalSharingOnly = "internalSharingOnly"
    case multipleAccounts = "multipleAccounts"
    case nudges = "nudges"
    case passwordChanger = "passwordChanger"
    case passwordsLimit = "passwordsLimit"
    case phoneSupport = "phoneSupport"
    case riskDetection = "riskDetection"
    case samlProvisioning = "samlProvisioning"
    case scim = "scim"
    case secretManagement = "secretManagement"
    case secureFiles = "secureFiles"
    case secureNotes = "secureNotes"
    case secureWiFi = "secureWiFi"
    case securityBreach = "securityBreach"
    case sharingLimit = "sharingLimit"
    case sso = "sso"
    case sync = "sync"
    case usageReports = "usageReports"
    case yubikey = "yubikey"
  }

  public struct CanSeeCustomerSupportContacts: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case enabled = "enabled"
      case info = "info"
    }

    public let enabled: Bool
    public let info: PaymentsAccessibleStoreOffersInfo2?

    public init(enabled: Bool, info: PaymentsAccessibleStoreOffersInfo2? = nil) {
      self.enabled = enabled
      self.info = info
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(enabled, forKey: .enabled)
      try container.encodeIfPresent(info, forKey: .info)
    }
  }

  public struct Nudges: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case enabled = "enabled"
      case info = "info"
    }

    public let enabled: Bool
    public let info: PaymentsAccessibleStoreOffersInfo2?

    public init(enabled: Bool, info: PaymentsAccessibleStoreOffersInfo2? = nil) {
      self.enabled = enabled
      self.info = info
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(enabled, forKey: .enabled)
      try container.encodeIfPresent(info, forKey: .info)
    }
  }

  public struct SecretManagement: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case enabled = "enabled"
      case info = "info"
    }

    public let enabled: Bool
    public let info: PaymentsAccessibleStoreOffersInfo2?

    public init(enabled: Bool, info: PaymentsAccessibleStoreOffersInfo2? = nil) {
      self.enabled = enabled
      self.info = info
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(enabled, forKey: .enabled)
      try container.encodeIfPresent(info, forKey: .info)
    }
  }

  public let activeDirectorySync: CapabilitySchema?
  public let activityLog: CapabilitySchema?
  public let adminPolicies: PaymentsAccessibleStoreOffersAdminPolicies?
  public let autofillWithPhishingPrevention: CapabilitySchema?
  public let canSeeCustomerSupportContacts: CanSeeCustomerSupportContacts?
  public let collectionSharing: CapabilitySchema?
  public let creditMonitoring: CapabilitySchema?
  public let dataLeak: CapabilitySchema?
  public let devicesLimit: CapabilitySchema?
  public let groupSharing: PaymentsAccessibleStoreOffersGroupSharing?
  public let identityRestoration: CapabilitySchema?
  public let identityTheftProtection: CapabilitySchema?
  public let inAppNudges: PaymentsAccessibleStoreOffersInAppNudges?
  public let internalSharingOnly: CapabilitySchema?
  public let multipleAccounts: CapabilitySchema?
  public let nudges: Nudges?
  public let passwordChanger: CapabilitySchema?
  public let passwordsLimit: CapabilitySchema?
  public let phoneSupport: CapabilitySchema?
  public let riskDetection: PaymentsAccessibleStoreOffersRiskDetection?
  public let samlProvisioning: CapabilitySchema?
  public let scim: CapabilitySchema?
  public let secretManagement: SecretManagement?
  public let secureFiles: CapabilitySchema?
  public let secureNotes: CapabilitySchema?
  public let secureWiFi: CapabilitySchema?
  public let securityBreach: CapabilitySchema?
  public let sharingLimit: CapabilitySchema?
  public let sso: CapabilitySchema?
  public let sync: CapabilitySchema?
  public let usageReports: CapabilitySchema?
  public let yubikey: CapabilitySchema?

  public init(
    activeDirectorySync: CapabilitySchema? = nil, activityLog: CapabilitySchema? = nil,
    adminPolicies: PaymentsAccessibleStoreOffersAdminPolicies? = nil,
    autofillWithPhishingPrevention: CapabilitySchema? = nil,
    canSeeCustomerSupportContacts: CanSeeCustomerSupportContacts? = nil,
    collectionSharing: CapabilitySchema? = nil, creditMonitoring: CapabilitySchema? = nil,
    dataLeak: CapabilitySchema? = nil, devicesLimit: CapabilitySchema? = nil,
    groupSharing: PaymentsAccessibleStoreOffersGroupSharing? = nil,
    identityRestoration: CapabilitySchema? = nil, identityTheftProtection: CapabilitySchema? = nil,
    inAppNudges: PaymentsAccessibleStoreOffersInAppNudges? = nil,
    internalSharingOnly: CapabilitySchema? = nil, multipleAccounts: CapabilitySchema? = nil,
    nudges: Nudges? = nil, passwordChanger: CapabilitySchema? = nil,
    passwordsLimit: CapabilitySchema? = nil, phoneSupport: CapabilitySchema? = nil,
    riskDetection: PaymentsAccessibleStoreOffersRiskDetection? = nil,
    samlProvisioning: CapabilitySchema? = nil, scim: CapabilitySchema? = nil,
    secretManagement: SecretManagement? = nil, secureFiles: CapabilitySchema? = nil,
    secureNotes: CapabilitySchema? = nil, secureWiFi: CapabilitySchema? = nil,
    securityBreach: CapabilitySchema? = nil, sharingLimit: CapabilitySchema? = nil,
    sso: CapabilitySchema? = nil, sync: CapabilitySchema? = nil,
    usageReports: CapabilitySchema? = nil, yubikey: CapabilitySchema? = nil
  ) {
    self.activeDirectorySync = activeDirectorySync
    self.activityLog = activityLog
    self.adminPolicies = adminPolicies
    self.autofillWithPhishingPrevention = autofillWithPhishingPrevention
    self.canSeeCustomerSupportContacts = canSeeCustomerSupportContacts
    self.collectionSharing = collectionSharing
    self.creditMonitoring = creditMonitoring
    self.dataLeak = dataLeak
    self.devicesLimit = devicesLimit
    self.groupSharing = groupSharing
    self.identityRestoration = identityRestoration
    self.identityTheftProtection = identityTheftProtection
    self.inAppNudges = inAppNudges
    self.internalSharingOnly = internalSharingOnly
    self.multipleAccounts = multipleAccounts
    self.nudges = nudges
    self.passwordChanger = passwordChanger
    self.passwordsLimit = passwordsLimit
    self.phoneSupport = phoneSupport
    self.riskDetection = riskDetection
    self.samlProvisioning = samlProvisioning
    self.scim = scim
    self.secretManagement = secretManagement
    self.secureFiles = secureFiles
    self.secureNotes = secureNotes
    self.secureWiFi = secureWiFi
    self.securityBreach = securityBreach
    self.sharingLimit = sharingLimit
    self.sso = sso
    self.sync = sync
    self.usageReports = usageReports
    self.yubikey = yubikey
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(activeDirectorySync, forKey: .activeDirectorySync)
    try container.encodeIfPresent(activityLog, forKey: .activityLog)
    try container.encodeIfPresent(adminPolicies, forKey: .adminPolicies)
    try container.encodeIfPresent(
      autofillWithPhishingPrevention, forKey: .autofillWithPhishingPrevention)
    try container.encodeIfPresent(
      canSeeCustomerSupportContacts, forKey: .canSeeCustomerSupportContacts)
    try container.encodeIfPresent(collectionSharing, forKey: .collectionSharing)
    try container.encodeIfPresent(creditMonitoring, forKey: .creditMonitoring)
    try container.encodeIfPresent(dataLeak, forKey: .dataLeak)
    try container.encodeIfPresent(devicesLimit, forKey: .devicesLimit)
    try container.encodeIfPresent(groupSharing, forKey: .groupSharing)
    try container.encodeIfPresent(identityRestoration, forKey: .identityRestoration)
    try container.encodeIfPresent(identityTheftProtection, forKey: .identityTheftProtection)
    try container.encodeIfPresent(inAppNudges, forKey: .inAppNudges)
    try container.encodeIfPresent(internalSharingOnly, forKey: .internalSharingOnly)
    try container.encodeIfPresent(multipleAccounts, forKey: .multipleAccounts)
    try container.encodeIfPresent(nudges, forKey: .nudges)
    try container.encodeIfPresent(passwordChanger, forKey: .passwordChanger)
    try container.encodeIfPresent(passwordsLimit, forKey: .passwordsLimit)
    try container.encodeIfPresent(phoneSupport, forKey: .phoneSupport)
    try container.encodeIfPresent(riskDetection, forKey: .riskDetection)
    try container.encodeIfPresent(samlProvisioning, forKey: .samlProvisioning)
    try container.encodeIfPresent(scim, forKey: .scim)
    try container.encodeIfPresent(secretManagement, forKey: .secretManagement)
    try container.encodeIfPresent(secureFiles, forKey: .secureFiles)
    try container.encodeIfPresent(secureNotes, forKey: .secureNotes)
    try container.encodeIfPresent(secureWiFi, forKey: .secureWiFi)
    try container.encodeIfPresent(securityBreach, forKey: .securityBreach)
    try container.encodeIfPresent(sharingLimit, forKey: .sharingLimit)
    try container.encodeIfPresent(sso, forKey: .sso)
    try container.encodeIfPresent(sync, forKey: .sync)
    try container.encodeIfPresent(usageReports, forKey: .usageReports)
    try container.encodeIfPresent(yubikey, forKey: .yubikey)
  }
}
