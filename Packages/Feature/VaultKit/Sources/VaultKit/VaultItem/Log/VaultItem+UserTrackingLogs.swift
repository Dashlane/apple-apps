import Foundation
import CorePersonalData
import CoreUserTracking
import DashlaneCrypto
import SwiftTreats

public extension VaultItem {
    var userTrackingLogID: String {
        return id.rawValue
    }
    
    var hashedDomainForLogs: Definition.Domain {
        guard case let .credential(credential) = enumerated else {
            return Definition.Domain(id: "", type: .web)
        }
        return credential.hashedDomainForLogs
    }
}

public extension Credential {
    var hashedDomainForLogs: Definition.Domain {
        guard let domainName = url?.domain?.name,
              let hashedCredential = SHA.hash(text: domainName, using: .sha256) else {
            return Definition.Domain(id: "", type: .web)
        }
        return Definition.Domain(id: hashedCredential.hexadecimalString,
                                 type: .web)
    }
}

public extension Credential {
    var userTrackingSpace: Definition.Space {
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

public extension String {
    var hashedDomainForLogs: Definition.Domain {
        return Definition.Domain(id: SHA.hash(text: self, using: .sha256)?.hexadecimalString, type: .web)
    }
}

public extension GeneratedPassword {
    var userTrackingLogID: String {
        return id.rawValue
    }
}

public extension DocumentAttachable {
    var userTrackingLogID: String {
        return id.rawValue
    }
}
