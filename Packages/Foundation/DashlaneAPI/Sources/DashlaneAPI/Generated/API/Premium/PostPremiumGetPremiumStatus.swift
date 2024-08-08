import Foundation

extension UserDeviceAPIClient.Premium {
  public struct GetPremiumStatus: APIRequest {
    public static let endpoint: Endpoint = "/premium/GetPremiumStatus"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getPremiumStatus: GetPremiumStatus {
    GetPremiumStatus(api: api)
  }
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Premium.GetPremiumStatus {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case b2cStatus = "b2cStatus"
      case capabilities = "capabilities"
      case b2bStatus = "b2bStatus"
      case currentTimestampUnix = "currentTimestampUnix"
    }

    public struct B2cStatus: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case isTrial = "isTrial"
        case autoRenewal = "autoRenewal"
        case endDateUnix = "endDateUnix"
        case familyStatus = "familyStatus"
        case hasPaid = "hasPaid"
        case planFeature = "planFeature"
        case planName = "planName"
        case planType = "planType"
        case previousPlan = "previousPlan"
        case startDateUnix = "startDateUnix"
      }

      public enum StatusCode: String, Sendable, Equatable, CaseIterable, Codable {
        case free = "free"
        case subscribed = "subscribed"
        case legacy = "legacy"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct FamilyStatus: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case isAdmin = "isAdmin"
          case familyId = "familyId"
          case planName = "planName"
        }

        public let isAdmin: Bool
        public let familyId: Int
        public let planName: String

        public init(isAdmin: Bool, familyId: Int, planName: String) {
          self.isAdmin = isAdmin
          self.familyId = familyId
          self.planName = planName
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(isAdmin, forKey: .isAdmin)
          try container.encode(familyId, forKey: .familyId)
          try container.encode(planName, forKey: .planName)
        }
      }

      public enum PlanFeature: String, Sendable, Equatable, CaseIterable, Codable {
        case premium = "premium"
        case essentials = "essentials"
        case premiumplus = "premiumplus"
        case backupForAll = "backup-for-all"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public enum PlanType: String, Sendable, Equatable, CaseIterable, Codable {
        case amazon = "amazon"
        case freeTrial = "free_trial"
        case invoice = "invoice"
        case ios = "ios"
        case iosRenewable = "ios_renewable"
        case mac = "mac"
        case macRenewable = "mac_renewable"
        case offer = "offer"
        case partner = "partner"
        case paypal = "paypal"
        case paypalRenewable = "paypal_renewable"
        case playstore = "playstore"
        case playstoreRenewable = "playstore_renewable"
        case stripe = "stripe"
        case legacy = "legacy"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct PreviousPlan: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case planName = "planName"
          case endDateUnix = "endDateUnix"
        }

        public let planName: String
        public let endDateUnix: Int

        public init(planName: String, endDateUnix: Int) {
          self.planName = planName
          self.endDateUnix = endDateUnix
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(planName, forKey: .planName)
          try container.encode(endDateUnix, forKey: .endDateUnix)
        }
      }

      public let statusCode: StatusCode
      public let isTrial: Bool
      public let autoRenewal: Bool
      public let endDateUnix: Int?
      public let familyStatus: FamilyStatus?
      public let hasPaid: Bool?
      public let planFeature: PlanFeature?
      public let planName: String?
      public let planType: PlanType?
      public let previousPlan: PreviousPlan?
      public let startDateUnix: Int?

      public init(
        statusCode: StatusCode, isTrial: Bool, autoRenewal: Bool, endDateUnix: Int? = nil,
        familyStatus: FamilyStatus? = nil, hasPaid: Bool? = nil, planFeature: PlanFeature? = nil,
        planName: String? = nil, planType: PlanType? = nil, previousPlan: PreviousPlan? = nil,
        startDateUnix: Int? = nil
      ) {
        self.statusCode = statusCode
        self.isTrial = isTrial
        self.autoRenewal = autoRenewal
        self.endDateUnix = endDateUnix
        self.familyStatus = familyStatus
        self.hasPaid = hasPaid
        self.planFeature = planFeature
        self.planName = planName
        self.planType = planType
        self.previousPlan = previousPlan
        self.startDateUnix = startDateUnix
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(isTrial, forKey: .isTrial)
        try container.encode(autoRenewal, forKey: .autoRenewal)
        try container.encodeIfPresent(endDateUnix, forKey: .endDateUnix)
        try container.encodeIfPresent(familyStatus, forKey: .familyStatus)
        try container.encodeIfPresent(hasPaid, forKey: .hasPaid)
        try container.encodeIfPresent(planFeature, forKey: .planFeature)
        try container.encodeIfPresent(planName, forKey: .planName)
        try container.encodeIfPresent(planType, forKey: .planType)
        try container.encodeIfPresent(previousPlan, forKey: .previousPlan)
        try container.encodeIfPresent(startDateUnix, forKey: .startDateUnix)
      }
    }

    public struct CapabilitiesElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case capability = "capability"
        case enabled = "enabled"
        case info = "info"
      }

      public enum Capability: String, Sendable, Equatable, CaseIterable, Codable {
        case autofillWithPhishingPrevention = "autofillWithPhishingPrevention"
        case sync = "sync"
        case creditMonitoring = "creditMonitoring"
        case dataLeak = "dataLeak"
        case identityRestoration = "identityRestoration"
        case identityTheftProtection = "identityTheftProtection"
        case multipleAccounts = "multipleAccounts"
        case passwordsLimit = "passwordsLimit"
        case secureFiles = "secureFiles"
        case secureWiFi = "secureWiFi"
        case securityBreach = "securityBreach"
        case sharingLimit = "sharingLimit"
        case collectionSharing = "collectionSharing"
        case groupSharing = "groupSharing"
        case internalSharingOnly = "internalSharingOnly"
        case yubikey = "yubikey"
        case secureNotes = "secureNotes"
        case passwordChanger = "passwordChanger"
        case devicesLimit = "devicesLimit"
        case samlProvisioning = "samlProvisioning"
        case sso = "sso"
        case scim = "scim"
        case phoneSupport = "phoneSupport"
        case activeDirectorySync = "activeDirectorySync"
        case activityLog = "activityLog"
        case usageReports = "usageReports"
        case adminPolicies = "adminPolicies"
        case secretManagement = "secretManagement"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct Info: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case action = "action"
          case excludedPolicies = "excludedPolicies"
          case limit = "limit"
          case maxFileSize = "maxFileSize"
          case quota = "quota"
          case reason = "reason"
          case whoCanShare = "whoCanShare"
        }

        public enum Action: String, Sendable, Equatable, CaseIterable, Codable {
          case enforceFreeze = "enforce_freeze"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public struct Quota: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case max = "max"
            case remaining = "remaining"
          }

          public let max: Int
          public let remaining: Int?

          public init(max: Int, remaining: Int? = nil) {
            self.max = max
            self.remaining = remaining
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(max, forKey: .max)
            try container.encodeIfPresent(remaining, forKey: .remaining)
          }
        }

        public enum Reason: String, Sendable, Equatable, CaseIterable, Codable {
          case inTeam = "in_team"
          case notPremium = "not_premium"
          case noPayment = "no_payment"
          case isUnpaidFamilyMember = "is_unpaid_family_member"
          case defaultSettings = "default_settings"
          case noVpnCapability = "no_vpn_capability"
          case disabledForFreeUser = "disabled_for_free_user"
          case notForB2C = "not_for_b2c"
          case notAdmin = "not_admin"
          case notReleased = "not_released"
          case notInThisTier = "not_in_this_tier"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public enum WhoCanShare: String, Sendable, Equatable, CaseIterable, Codable {
          case adminOnly = "admin_only"
          case everyone = "everyone"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let action: Action?
        public let excludedPolicies: [String]?
        public let limit: Int?
        public let maxFileSize: Int?
        public let quota: Quota?
        public let reason: Reason?
        public let whoCanShare: WhoCanShare?

        public init(
          action: Action? = nil, excludedPolicies: [String]? = nil, limit: Int? = nil,
          maxFileSize: Int? = nil, quota: Quota? = nil, reason: Reason? = nil,
          whoCanShare: WhoCanShare? = nil
        ) {
          self.action = action
          self.excludedPolicies = excludedPolicies
          self.limit = limit
          self.maxFileSize = maxFileSize
          self.quota = quota
          self.reason = reason
          self.whoCanShare = whoCanShare
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(action, forKey: .action)
          try container.encodeIfPresent(excludedPolicies, forKey: .excludedPolicies)
          try container.encodeIfPresent(limit, forKey: .limit)
          try container.encodeIfPresent(maxFileSize, forKey: .maxFileSize)
          try container.encodeIfPresent(quota, forKey: .quota)
          try container.encodeIfPresent(reason, forKey: .reason)
          try container.encodeIfPresent(whoCanShare, forKey: .whoCanShare)
        }
      }

      public let capability: Capability
      public let enabled: Bool
      public let info: Info?

      public init(capability: Capability, enabled: Bool, info: Info? = nil) {
        self.capability = capability
        self.enabled = enabled
        self.info = info
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(capability, forKey: .capability)
        try container.encode(enabled, forKey: .enabled)
        try container.encodeIfPresent(info, forKey: .info)
      }
    }

    public struct B2bStatus: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case currentTeam = "currentTeam"
        case hasPaid = "hasPaid"
        case pastTeams = "pastTeams"
      }

      public enum StatusCode: String, Sendable, Equatable, CaseIterable, Codable {
        case notInTeam = "not_in_team"
        case proposed = "proposed"
        case inTeam = "in_team"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public struct CurrentTeam: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case planName = "planName"
          case nextBillingDateUnix = "nextBillingDateUnix"
          case isSoftDiscontinued = "isSoftDiscontinued"
          case teamId = "teamId"
          case planFeature = "planFeature"
          case joinDateUnix = "joinDateUnix"
          case teamMembership = "teamMembership"
          case teamInfo = "teamInfo"
          case associatedEmail = "associatedEmail"
          case hasPaid = "hasPaid"
          case invitationDateUnix = "invitationDateUnix"
          case isRenewalStopped = "isRenewalStopped"
          case isTrial = "isTrial"
          case recoveryHash = "recoveryHash"
          case teamName = "teamName"
        }

        public let planName: String
        public let nextBillingDateUnix: Int?
        public let isSoftDiscontinued: Bool
        public let teamId: Int
        public let planFeature: PremiumStatusPlanFeature
        public let joinDateUnix: Int
        public let teamMembership: PremiumStatusTeamMembership
        public let teamInfo: PremiumStatusTeamInfo
        public let associatedEmail: String?
        public let hasPaid: Bool?
        public let invitationDateUnix: Int?
        public let isRenewalStopped: Bool?
        public let isTrial: Bool?
        public let recoveryHash: String?
        public let teamName: String?

        public init(
          planName: String, nextBillingDateUnix: Int?, isSoftDiscontinued: Bool, teamId: Int,
          planFeature: PremiumStatusPlanFeature, joinDateUnix: Int,
          teamMembership: PremiumStatusTeamMembership, teamInfo: PremiumStatusTeamInfo,
          associatedEmail: String? = nil, hasPaid: Bool? = nil, invitationDateUnix: Int? = nil,
          isRenewalStopped: Bool? = nil, isTrial: Bool? = nil, recoveryHash: String? = nil,
          teamName: String? = nil
        ) {
          self.planName = planName
          self.nextBillingDateUnix = nextBillingDateUnix
          self.isSoftDiscontinued = isSoftDiscontinued
          self.teamId = teamId
          self.planFeature = planFeature
          self.joinDateUnix = joinDateUnix
          self.teamMembership = teamMembership
          self.teamInfo = teamInfo
          self.associatedEmail = associatedEmail
          self.hasPaid = hasPaid
          self.invitationDateUnix = invitationDateUnix
          self.isRenewalStopped = isRenewalStopped
          self.isTrial = isTrial
          self.recoveryHash = recoveryHash
          self.teamName = teamName
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(planName, forKey: .planName)
          try container.encode(nextBillingDateUnix, forKey: .nextBillingDateUnix)
          try container.encode(isSoftDiscontinued, forKey: .isSoftDiscontinued)
          try container.encode(teamId, forKey: .teamId)
          try container.encode(planFeature, forKey: .planFeature)
          try container.encode(joinDateUnix, forKey: .joinDateUnix)
          try container.encode(teamMembership, forKey: .teamMembership)
          try container.encode(teamInfo, forKey: .teamInfo)
          try container.encodeIfPresent(associatedEmail, forKey: .associatedEmail)
          try container.encodeIfPresent(hasPaid, forKey: .hasPaid)
          try container.encodeIfPresent(invitationDateUnix, forKey: .invitationDateUnix)
          try container.encodeIfPresent(isRenewalStopped, forKey: .isRenewalStopped)
          try container.encodeIfPresent(isTrial, forKey: .isTrial)
          try container.encodeIfPresent(recoveryHash, forKey: .recoveryHash)
          try container.encodeIfPresent(teamName, forKey: .teamName)
        }
      }

      public struct PastTeamsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case status = "status"
          case revokeDateUnix = "revokeDateUnix"
          case teamId = "teamId"
          case planFeature = "planFeature"
          case joinDateUnix = "joinDateUnix"
          case teamMembership = "teamMembership"
          case teamInfo = "teamInfo"
          case associatedEmail = "associatedEmail"
          case invitationDateUnix = "invitationDateUnix"
          case shouldDelete = "shouldDelete"
          case teamName = "teamName"
        }

        public enum Status: String, Sendable, Equatable, CaseIterable, Codable {
          case accepted = "accepted"
          case proposed = "proposed"
          case removed = "removed"
          case unproposed = "unproposed"
          case pending = "pending"
          case revoked = "revoked"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let status: Status
        public let revokeDateUnix: Int
        public let teamId: Int
        public let planFeature: PremiumStatusPlanFeature
        public let joinDateUnix: Int
        public let teamMembership: PremiumStatusTeamMembership
        public let teamInfo: PremiumStatusTeamInfo
        public let associatedEmail: String?
        public let invitationDateUnix: Int?
        public let shouldDelete: Bool?
        public let teamName: String?

        public init(
          status: Status, revokeDateUnix: Int, teamId: Int, planFeature: PremiumStatusPlanFeature,
          joinDateUnix: Int, teamMembership: PremiumStatusTeamMembership,
          teamInfo: PremiumStatusTeamInfo, associatedEmail: String? = nil,
          invitationDateUnix: Int? = nil, shouldDelete: Bool? = nil, teamName: String? = nil
        ) {
          self.status = status
          self.revokeDateUnix = revokeDateUnix
          self.teamId = teamId
          self.planFeature = planFeature
          self.joinDateUnix = joinDateUnix
          self.teamMembership = teamMembership
          self.teamInfo = teamInfo
          self.associatedEmail = associatedEmail
          self.invitationDateUnix = invitationDateUnix
          self.shouldDelete = shouldDelete
          self.teamName = teamName
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(status, forKey: .status)
          try container.encode(revokeDateUnix, forKey: .revokeDateUnix)
          try container.encode(teamId, forKey: .teamId)
          try container.encode(planFeature, forKey: .planFeature)
          try container.encode(joinDateUnix, forKey: .joinDateUnix)
          try container.encode(teamMembership, forKey: .teamMembership)
          try container.encode(teamInfo, forKey: .teamInfo)
          try container.encodeIfPresent(associatedEmail, forKey: .associatedEmail)
          try container.encodeIfPresent(invitationDateUnix, forKey: .invitationDateUnix)
          try container.encodeIfPresent(shouldDelete, forKey: .shouldDelete)
          try container.encodeIfPresent(teamName, forKey: .teamName)
        }
      }

      public let statusCode: StatusCode
      public let currentTeam: CurrentTeam?
      public let hasPaid: Bool?
      public let pastTeams: [PastTeamsElement]?

      public init(
        statusCode: StatusCode, currentTeam: CurrentTeam? = nil, hasPaid: Bool? = nil,
        pastTeams: [PastTeamsElement]? = nil
      ) {
        self.statusCode = statusCode
        self.currentTeam = currentTeam
        self.hasPaid = hasPaid
        self.pastTeams = pastTeams
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encodeIfPresent(currentTeam, forKey: .currentTeam)
        try container.encodeIfPresent(hasPaid, forKey: .hasPaid)
        try container.encodeIfPresent(pastTeams, forKey: .pastTeams)
      }
    }

    public let b2cStatus: B2cStatus
    public let capabilities: [CapabilitiesElement]
    public let b2bStatus: B2bStatus?
    public let currentTimestampUnix: Int?

    public init(
      b2cStatus: B2cStatus, capabilities: [CapabilitiesElement], b2bStatus: B2bStatus? = nil,
      currentTimestampUnix: Int? = nil
    ) {
      self.b2cStatus = b2cStatus
      self.capabilities = capabilities
      self.b2bStatus = b2bStatus
      self.currentTimestampUnix = currentTimestampUnix
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(b2cStatus, forKey: .b2cStatus)
      try container.encode(capabilities, forKey: .capabilities)
      try container.encodeIfPresent(b2bStatus, forKey: .b2bStatus)
      try container.encodeIfPresent(currentTimestampUnix, forKey: .currentTimestampUnix)
    }
  }
}
