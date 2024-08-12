import Foundation

public struct CapabilitySchema: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case enabled = "enabled"
    case info = "info"
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

  public let enabled: Bool
  public let info: Info?

  public init(enabled: Bool, info: Info? = nil) {
    self.enabled = enabled
    self.info = info
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(enabled, forKey: .enabled)
    try container.encodeIfPresent(info, forKey: .info)
  }
}
