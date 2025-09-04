import CorePersonalData
import CryptoKit
import Foundation
import SwiftTreats
import UserTrackingFoundation

extension VaultItem {
  public var userTrackingLogID: String {
    return id.rawValue
  }

  public func hashedDomainForLogs() -> Definition.Domain {
    guard case let .credential(credential) = enumerated else {
      return Definition.Domain(id: "", type: .web)
    }
    return credential.hashedDomainForLogs()
  }
}

extension Credential {
  public func hashedDomainForLogs() -> Definition.Domain {
    guard let domainName = url?.domain?.name,
      let data = domainName.data(using: .utf8)
    else {
      return Definition.Domain(id: "", type: .web)
    }

    let hashedCredential = Data(SHA256.hash(data: data))
    return Definition.Domain(
      id: hashedCredential.hexadecimalString,
      type: .web)
  }
}

extension VaultItem {
  public var userTrackingSpace: Definition.Space {
    switch spaceId {
    case nil:
      return .all
    case "":
      return .personal
    default:
      return .professional
    }
  }
}

extension String {
  public func hashedDomainForLogs() -> Definition.Domain {
    let id = self.data(using: .utf8).map { Data(SHA256.hash(data: $0)) }

    return Definition.Domain(id: id?.hexadecimalString, type: .web)
  }
}

extension GeneratedPassword {
  public var userTrackingLogID: String {
    return id.rawValue
  }
}

extension DocumentAttachable {
  public var userTrackingLogID: String {
    return id.rawValue
  }
}
