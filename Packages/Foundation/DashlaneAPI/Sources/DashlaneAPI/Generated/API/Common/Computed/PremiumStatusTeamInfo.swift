import Foundation

public struct PremiumStatusTeamInfo: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case membersNumber = "membersNumber"
    case planType = "planType"
    case activeDirectoryAllowedIpRange = "activeDirectoryAllowedIpRange"
    case activeDirectorySyncType = "activeDirectorySyncType"
    case activeDirectoryToken = "activeDirectoryToken"
    case aiAntiphishingEnabled = "aiAntiphishingEnabled"
    case autologinDomainDisabledArray = "autologinDomainDisabledArray"
    case collectSensitiveDataAuditLogsEnabled = "collectSensitiveDataAuditLogsEnabled"
    case color = "color"
    case compromisedPasswordInappNudgesEnabled = "compromisedPasswordInappNudgesEnabled"
    case cryptoForcedPayload = "cryptoForcedPayload"
    case defaultCurrency = "defaultCurrency"
    case distributor = "distributor"
    case duo = "duo"
    case duoApiHostname = "duoApiHostname"
    case duoIntegrationKey = "duoIntegrationKey"
    case duoSecretKey = "duoSecretKey"
    case emergencyDisabled = "emergencyDisabled"
    case features = "features"
    case forceAutomaticLogout = "forceAutomaticLogout"
    case forcedDomainsEnabled = "forcedDomainsEnabled"
    case freeFamilyProvisioningEnabled = "freeFamilyProvisioningEnabled"
    case fullSeatCountRenewal = "fullSeatCountRenewal"
    case gracePeriodDuration = "gracePeriodDuration"
    case groupManagers = "groupManagers"
    case idpCertificate = "idpCertificate"
    case idpSecurityGroups = "idpSecurityGroups"
    case idpUrl = "idpUrl"
    case letter = "letter"
    case lockOnExit = "lockOnExit"
    case mailVersion = "mailVersion"
    case mpEnforcePolicy = "mpEnforcePolicy"
    case mpPersistenceDisabled = "mpPersistenceDisabled"
    case mpPolicyMinDigits = "mpPolicyMinDigits"
    case mpPolicyMinLength = "mpPolicyMinLength"
    case mpPolicyMinLowerCase = "mpPolicyMinLowerCase"
    case mpPolicyMinSpecials = "mpPolicyMinSpecials"
    case mpPolicyMinUpperCase = "mpPolicyMinUpperCase"
    case name = "name"
    case personalSpaceEnabled = "personalSpaceEnabled"
    case provisioningSolution = "provisioningSolution"
    case recoveryEnabled = "recoveryEnabled"
    case removalGracePeriodPlan = "removalGracePeriodPlan"
    case removeForcedContentEnabled = "removeForcedContentEnabled"
    case reusedPasswordInappNudgesEnabled = "reusedPasswordInappNudgesEnabled"
    case richIconsEnabled = "richIconsEnabled"
    case secureStorageEnabled = "secureStorageEnabled"
    case secureWifiEnabled = "secureWifiEnabled"
    case sharingDisabled = "sharingDisabled"
    case sharingRestrictedToTeam = "sharingRestrictedToTeam"
    case spaceRestrictionsEnabled = "spaceRestrictionsEnabled"
    case ssoActivationType = "ssoActivationType"
    case ssoEnabled = "ssoEnabled"
    case ssoIdpEntrypoint = "ssoIdpEntrypoint"
    case ssoIdpMetadata = "ssoIdpMetadata"
    case ssoIsNitroProvider = "ssoIsNitroProvider"
    case ssoProvisioning = "ssoProvisioning"
    case ssoServiceProviderUrl = "ssoServiceProviderUrl"
    case ssoSolution = "ssoSolution"
    case teamCaptains = "teamCaptains"
    case teamDomains = "teamDomains"
    case teamSignupPageEnabled = "teamSignupPageEnabled"
    case transactionalEmailsLanguage = "transactionalEmailsLanguage"
    case twoFAEnforced = "twoFAEnforced"
    case uvvsReportEnabled = "uvvsReportEnabled"
    case vaultExportEnabled = "vaultExportEnabled"
    case weakPasswordInappNudgesEnabled = "weakPasswordInappNudgesEnabled"
    case whoCanShareCollections = "whoCanShareCollections"
  }

  public let membersNumber: Int
  public let planType: String
  public let activeDirectoryAllowedIpRange: String?
  public let activeDirectorySyncType: String?
  public let activeDirectoryToken: String?
  public let aiAntiphishingEnabled: Bool?
  public let autologinDomainDisabledArray: [String]?
  public let collectSensitiveDataAuditLogsEnabled: Bool?
  public let color: String?
  public let compromisedPasswordInappNudgesEnabled: Bool?
  public let cryptoForcedPayload: String?
  public let defaultCurrency: String?
  public let distributor: String?
  public let duo: Bool?
  public let duoApiHostname: String?
  public let duoIntegrationKey: String?
  public let duoSecretKey: String?
  public let emergencyDisabled: Bool?
  public let features: [String: Bool]?
  public let forceAutomaticLogout: Int?
  public let forcedDomainsEnabled: Bool?
  public let freeFamilyProvisioningEnabled: Bool?
  public let fullSeatCountRenewal: Bool?
  public let gracePeriodDuration: String?
  public let groupManagers: [Int]?
  public let idpCertificate: String?
  public let idpSecurityGroups: [String]?
  public let idpUrl: String?
  public let letter: String?
  public let lockOnExit: Bool?
  public let mailVersion: String?
  public let mpEnforcePolicy: Bool?
  public let mpPersistenceDisabled: Bool?
  public let mpPolicyMinDigits: Int?
  public let mpPolicyMinLength: Int?
  public let mpPolicyMinLowerCase: Int?
  public let mpPolicyMinSpecials: Int?
  public let mpPolicyMinUpperCase: Int?
  public let name: String?
  public let personalSpaceEnabled: Bool?
  public let provisioningSolution: String?
  public let recoveryEnabled: Bool?
  public let removalGracePeriodPlan: String?
  public let removeForcedContentEnabled: Bool?
  public let reusedPasswordInappNudgesEnabled: Bool?
  public let richIconsEnabled: Bool?
  public let secureStorageEnabled: Bool?
  public let secureWifiEnabled: Bool?
  public let sharingDisabled: Bool?
  public let sharingRestrictedToTeam: Bool?
  public let spaceRestrictionsEnabled: Bool?
  public let ssoActivationType: String?
  public let ssoEnabled: Bool?
  public let ssoIdpEntrypoint: String?
  public let ssoIdpMetadata: String?
  public let ssoIsNitroProvider: Bool?
  public let ssoProvisioning: String?
  public let ssoServiceProviderUrl: String?
  public let ssoSolution: String?
  public let teamCaptains: [String: Bool]?
  public let teamDomains: [String]?
  public let teamSignupPageEnabled: Bool?
  public let transactionalEmailsLanguage: String?
  public let twoFAEnforced: PremiumStatusTwoFAEnforced?
  public let uvvsReportEnabled: Bool?
  public let vaultExportEnabled: Bool?
  public let weakPasswordInappNudgesEnabled: Bool?
  public let whoCanShareCollections: String?

  public init(
    membersNumber: Int, planType: String, activeDirectoryAllowedIpRange: String? = nil,
    activeDirectorySyncType: String? = nil, activeDirectoryToken: String? = nil,
    aiAntiphishingEnabled: Bool? = nil, autologinDomainDisabledArray: [String]? = nil,
    collectSensitiveDataAuditLogsEnabled: Bool? = nil, color: String? = nil,
    compromisedPasswordInappNudgesEnabled: Bool? = nil, cryptoForcedPayload: String? = nil,
    defaultCurrency: String? = nil, distributor: String? = nil, duo: Bool? = nil,
    duoApiHostname: String? = nil, duoIntegrationKey: String? = nil, duoSecretKey: String? = nil,
    emergencyDisabled: Bool? = nil, features: [String: Bool]? = nil,
    forceAutomaticLogout: Int? = nil, forcedDomainsEnabled: Bool? = nil,
    freeFamilyProvisioningEnabled: Bool? = nil, fullSeatCountRenewal: Bool? = nil,
    gracePeriodDuration: String? = nil, groupManagers: [Int]? = nil, idpCertificate: String? = nil,
    idpSecurityGroups: [String]? = nil, idpUrl: String? = nil, letter: String? = nil,
    lockOnExit: Bool? = nil, mailVersion: String? = nil, mpEnforcePolicy: Bool? = nil,
    mpPersistenceDisabled: Bool? = nil, mpPolicyMinDigits: Int? = nil,
    mpPolicyMinLength: Int? = nil, mpPolicyMinLowerCase: Int? = nil,
    mpPolicyMinSpecials: Int? = nil, mpPolicyMinUpperCase: Int? = nil, name: String? = nil,
    personalSpaceEnabled: Bool? = nil, provisioningSolution: String? = nil,
    recoveryEnabled: Bool? = nil, removalGracePeriodPlan: String? = nil,
    removeForcedContentEnabled: Bool? = nil, reusedPasswordInappNudgesEnabled: Bool? = nil,
    richIconsEnabled: Bool? = nil, secureStorageEnabled: Bool? = nil,
    secureWifiEnabled: Bool? = nil, sharingDisabled: Bool? = nil,
    sharingRestrictedToTeam: Bool? = nil, spaceRestrictionsEnabled: Bool? = nil,
    ssoActivationType: String? = nil, ssoEnabled: Bool? = nil, ssoIdpEntrypoint: String? = nil,
    ssoIdpMetadata: String? = nil, ssoIsNitroProvider: Bool? = nil, ssoProvisioning: String? = nil,
    ssoServiceProviderUrl: String? = nil, ssoSolution: String? = nil,
    teamCaptains: [String: Bool]? = nil, teamDomains: [String]? = nil,
    teamSignupPageEnabled: Bool? = nil, transactionalEmailsLanguage: String? = nil,
    twoFAEnforced: PremiumStatusTwoFAEnforced? = nil, uvvsReportEnabled: Bool? = nil,
    vaultExportEnabled: Bool? = nil, weakPasswordInappNudgesEnabled: Bool? = nil,
    whoCanShareCollections: String? = nil
  ) {
    self.membersNumber = membersNumber
    self.planType = planType
    self.activeDirectoryAllowedIpRange = activeDirectoryAllowedIpRange
    self.activeDirectorySyncType = activeDirectorySyncType
    self.activeDirectoryToken = activeDirectoryToken
    self.aiAntiphishingEnabled = aiAntiphishingEnabled
    self.autologinDomainDisabledArray = autologinDomainDisabledArray
    self.collectSensitiveDataAuditLogsEnabled = collectSensitiveDataAuditLogsEnabled
    self.color = color
    self.compromisedPasswordInappNudgesEnabled = compromisedPasswordInappNudgesEnabled
    self.cryptoForcedPayload = cryptoForcedPayload
    self.defaultCurrency = defaultCurrency
    self.distributor = distributor
    self.duo = duo
    self.duoApiHostname = duoApiHostname
    self.duoIntegrationKey = duoIntegrationKey
    self.duoSecretKey = duoSecretKey
    self.emergencyDisabled = emergencyDisabled
    self.features = features
    self.forceAutomaticLogout = forceAutomaticLogout
    self.forcedDomainsEnabled = forcedDomainsEnabled
    self.freeFamilyProvisioningEnabled = freeFamilyProvisioningEnabled
    self.fullSeatCountRenewal = fullSeatCountRenewal
    self.gracePeriodDuration = gracePeriodDuration
    self.groupManagers = groupManagers
    self.idpCertificate = idpCertificate
    self.idpSecurityGroups = idpSecurityGroups
    self.idpUrl = idpUrl
    self.letter = letter
    self.lockOnExit = lockOnExit
    self.mailVersion = mailVersion
    self.mpEnforcePolicy = mpEnforcePolicy
    self.mpPersistenceDisabled = mpPersistenceDisabled
    self.mpPolicyMinDigits = mpPolicyMinDigits
    self.mpPolicyMinLength = mpPolicyMinLength
    self.mpPolicyMinLowerCase = mpPolicyMinLowerCase
    self.mpPolicyMinSpecials = mpPolicyMinSpecials
    self.mpPolicyMinUpperCase = mpPolicyMinUpperCase
    self.name = name
    self.personalSpaceEnabled = personalSpaceEnabled
    self.provisioningSolution = provisioningSolution
    self.recoveryEnabled = recoveryEnabled
    self.removalGracePeriodPlan = removalGracePeriodPlan
    self.removeForcedContentEnabled = removeForcedContentEnabled
    self.reusedPasswordInappNudgesEnabled = reusedPasswordInappNudgesEnabled
    self.richIconsEnabled = richIconsEnabled
    self.secureStorageEnabled = secureStorageEnabled
    self.secureWifiEnabled = secureWifiEnabled
    self.sharingDisabled = sharingDisabled
    self.sharingRestrictedToTeam = sharingRestrictedToTeam
    self.spaceRestrictionsEnabled = spaceRestrictionsEnabled
    self.ssoActivationType = ssoActivationType
    self.ssoEnabled = ssoEnabled
    self.ssoIdpEntrypoint = ssoIdpEntrypoint
    self.ssoIdpMetadata = ssoIdpMetadata
    self.ssoIsNitroProvider = ssoIsNitroProvider
    self.ssoProvisioning = ssoProvisioning
    self.ssoServiceProviderUrl = ssoServiceProviderUrl
    self.ssoSolution = ssoSolution
    self.teamCaptains = teamCaptains
    self.teamDomains = teamDomains
    self.teamSignupPageEnabled = teamSignupPageEnabled
    self.transactionalEmailsLanguage = transactionalEmailsLanguage
    self.twoFAEnforced = twoFAEnforced
    self.uvvsReportEnabled = uvvsReportEnabled
    self.vaultExportEnabled = vaultExportEnabled
    self.weakPasswordInappNudgesEnabled = weakPasswordInappNudgesEnabled
    self.whoCanShareCollections = whoCanShareCollections
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(membersNumber, forKey: .membersNumber)
    try container.encode(planType, forKey: .planType)
    try container.encodeIfPresent(
      activeDirectoryAllowedIpRange, forKey: .activeDirectoryAllowedIpRange)
    try container.encodeIfPresent(activeDirectorySyncType, forKey: .activeDirectorySyncType)
    try container.encodeIfPresent(activeDirectoryToken, forKey: .activeDirectoryToken)
    try container.encodeIfPresent(aiAntiphishingEnabled, forKey: .aiAntiphishingEnabled)
    try container.encodeIfPresent(
      autologinDomainDisabledArray, forKey: .autologinDomainDisabledArray)
    try container.encodeIfPresent(
      collectSensitiveDataAuditLogsEnabled, forKey: .collectSensitiveDataAuditLogsEnabled)
    try container.encodeIfPresent(color, forKey: .color)
    try container.encodeIfPresent(
      compromisedPasswordInappNudgesEnabled, forKey: .compromisedPasswordInappNudgesEnabled)
    try container.encodeIfPresent(cryptoForcedPayload, forKey: .cryptoForcedPayload)
    try container.encodeIfPresent(defaultCurrency, forKey: .defaultCurrency)
    try container.encodeIfPresent(distributor, forKey: .distributor)
    try container.encodeIfPresent(duo, forKey: .duo)
    try container.encodeIfPresent(duoApiHostname, forKey: .duoApiHostname)
    try container.encodeIfPresent(duoIntegrationKey, forKey: .duoIntegrationKey)
    try container.encodeIfPresent(duoSecretKey, forKey: .duoSecretKey)
    try container.encodeIfPresent(emergencyDisabled, forKey: .emergencyDisabled)
    try container.encodeIfPresent(features, forKey: .features)
    try container.encodeIfPresent(forceAutomaticLogout, forKey: .forceAutomaticLogout)
    try container.encodeIfPresent(forcedDomainsEnabled, forKey: .forcedDomainsEnabled)
    try container.encodeIfPresent(
      freeFamilyProvisioningEnabled, forKey: .freeFamilyProvisioningEnabled)
    try container.encodeIfPresent(fullSeatCountRenewal, forKey: .fullSeatCountRenewal)
    try container.encodeIfPresent(gracePeriodDuration, forKey: .gracePeriodDuration)
    try container.encodeIfPresent(groupManagers, forKey: .groupManagers)
    try container.encodeIfPresent(idpCertificate, forKey: .idpCertificate)
    try container.encodeIfPresent(idpSecurityGroups, forKey: .idpSecurityGroups)
    try container.encodeIfPresent(idpUrl, forKey: .idpUrl)
    try container.encodeIfPresent(letter, forKey: .letter)
    try container.encodeIfPresent(lockOnExit, forKey: .lockOnExit)
    try container.encodeIfPresent(mailVersion, forKey: .mailVersion)
    try container.encodeIfPresent(mpEnforcePolicy, forKey: .mpEnforcePolicy)
    try container.encodeIfPresent(mpPersistenceDisabled, forKey: .mpPersistenceDisabled)
    try container.encodeIfPresent(mpPolicyMinDigits, forKey: .mpPolicyMinDigits)
    try container.encodeIfPresent(mpPolicyMinLength, forKey: .mpPolicyMinLength)
    try container.encodeIfPresent(mpPolicyMinLowerCase, forKey: .mpPolicyMinLowerCase)
    try container.encodeIfPresent(mpPolicyMinSpecials, forKey: .mpPolicyMinSpecials)
    try container.encodeIfPresent(mpPolicyMinUpperCase, forKey: .mpPolicyMinUpperCase)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(personalSpaceEnabled, forKey: .personalSpaceEnabled)
    try container.encodeIfPresent(provisioningSolution, forKey: .provisioningSolution)
    try container.encodeIfPresent(recoveryEnabled, forKey: .recoveryEnabled)
    try container.encodeIfPresent(removalGracePeriodPlan, forKey: .removalGracePeriodPlan)
    try container.encodeIfPresent(removeForcedContentEnabled, forKey: .removeForcedContentEnabled)
    try container.encodeIfPresent(
      reusedPasswordInappNudgesEnabled, forKey: .reusedPasswordInappNudgesEnabled)
    try container.encodeIfPresent(richIconsEnabled, forKey: .richIconsEnabled)
    try container.encodeIfPresent(secureStorageEnabled, forKey: .secureStorageEnabled)
    try container.encodeIfPresent(secureWifiEnabled, forKey: .secureWifiEnabled)
    try container.encodeIfPresent(sharingDisabled, forKey: .sharingDisabled)
    try container.encodeIfPresent(sharingRestrictedToTeam, forKey: .sharingRestrictedToTeam)
    try container.encodeIfPresent(spaceRestrictionsEnabled, forKey: .spaceRestrictionsEnabled)
    try container.encodeIfPresent(ssoActivationType, forKey: .ssoActivationType)
    try container.encodeIfPresent(ssoEnabled, forKey: .ssoEnabled)
    try container.encodeIfPresent(ssoIdpEntrypoint, forKey: .ssoIdpEntrypoint)
    try container.encodeIfPresent(ssoIdpMetadata, forKey: .ssoIdpMetadata)
    try container.encodeIfPresent(ssoIsNitroProvider, forKey: .ssoIsNitroProvider)
    try container.encodeIfPresent(ssoProvisioning, forKey: .ssoProvisioning)
    try container.encodeIfPresent(ssoServiceProviderUrl, forKey: .ssoServiceProviderUrl)
    try container.encodeIfPresent(ssoSolution, forKey: .ssoSolution)
    try container.encodeIfPresent(teamCaptains, forKey: .teamCaptains)
    try container.encodeIfPresent(teamDomains, forKey: .teamDomains)
    try container.encodeIfPresent(teamSignupPageEnabled, forKey: .teamSignupPageEnabled)
    try container.encodeIfPresent(transactionalEmailsLanguage, forKey: .transactionalEmailsLanguage)
    try container.encodeIfPresent(twoFAEnforced, forKey: .twoFAEnforced)
    try container.encodeIfPresent(uvvsReportEnabled, forKey: .uvvsReportEnabled)
    try container.encodeIfPresent(vaultExportEnabled, forKey: .vaultExportEnabled)
    try container.encodeIfPresent(
      weakPasswordInappNudgesEnabled, forKey: .weakPasswordInappNudgesEnabled)
    try container.encodeIfPresent(whoCanShareCollections, forKey: .whoCanShareCollections)
  }
}
