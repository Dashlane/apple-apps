import Foundation

public protocol CapabilitySet: Decodable {
    var creditMonitoring: Capability<CreditMonitoringInfo> { get }
    var dataLeak: Capability<ReasonInfo<DarkWebMonitoringUnavailableReason>>  { get }
    var devicesLimit: Capability<LimitInfo>  { get }
    var identityRestoration: Capability<NoInfo> { get }
    var identityTheftProtection: Capability<NoInfo>  { get }
    var passwordsLimit: Capability<LimitInfo> { get }
    var secureFiles: Capability<FileQuotaInfo> { get }
    var secureNotes: Capability<NoInfo> { get }
    var secureWiFi: Capability<ReasonInfo<SecureWifiUnavailableReason>> { get }
    var securityBreach: Capability<NoInfo> { get }
    var sharingLimit: Capability<LimitInfo> { get }
    var sync: Capability<NoInfo> { get }
    var yubikey: Capability<NoInfo> { get }
}

public enum CapabilityKey: String, CodingKey, Decodable {
    case creditMonitoring
    case dataLeak
    case devicesLimit
    case identityRestoration
    case identityTheftProtection
    case secureFiles
    case secureNotes
    case secureWiFi
    case securityBreach
    case sharingLimit
    case sync
    case yubikey
}
