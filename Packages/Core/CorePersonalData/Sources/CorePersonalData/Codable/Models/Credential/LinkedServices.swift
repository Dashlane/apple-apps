import SwiftTreats

public enum DomainSource: String, Codable, Defaultable, CaseIterable {
  public static let defaultValue: DomainSource = .manual

  case manual
  case remember
}

public struct LinkedServices: Codable {
  public struct AssociatedAndroidApps: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
      case packageName = "package_name"
      case name
      case sha256CertFingerprints = "sha256_cert_fingerprints"
      case sha512CertFingerprints = "sha512_cert_fingerprints"
      case linkSource = "link_source"

    }

    public enum LinkSource: String, Codable {
      case dashlane
      case user
    }

    public var packageName: String
    public var name: String
    public var sha256CertFingerprints: [String]
    public var sha512CertFingerprints: [String]
    public var linkSource: LinkSource
  }

  public struct AssociatedDomain: Codable, Equatable {
    public var domain: String
    public var source: DomainSource

    public init(domain: String, source: DomainSource) {
      self.domain = domain
      self.source = source
    }
  }

  public enum CodingKeys: String, CodingKey {
    case associatedDomains = "associated_domains"
    case associatedAndroidApps = "associated_android_apps"
  }

  @Defaulted
  public var associatedDomains: [AssociatedDomain]
  @Defaulted
  public var associatedAndroidApps: [AssociatedAndroidApps]

  public init(
    associatedDomains: [AssociatedDomain], associatedAndroidApps: [AssociatedAndroidApps] = []
  ) {
    self.associatedDomains = associatedDomains
    self.associatedAndroidApps = associatedAndroidApps
  }
}

extension LinkedServices: Defaultable {
  public static var defaultValue: Self {
    return LinkedServices(associatedDomains: [])
  }
}

extension LinkedServices: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.associatedDomains.count == rhs.associatedDomains.count else {
      return false
    }

    return zip(lhs.associatedDomains, rhs.associatedDomains).allSatisfy { $0.0 == $0.1 }
  }
}
