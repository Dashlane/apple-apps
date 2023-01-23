import Foundation

public struct OfferCapabilitySet: Decodable, CapabilitySet {
    public let creditMonitoring: Capability<CreditMonitoringInfo>
    public let dataLeak: Capability<ReasonInfo<DarkWebMonitoringUnavailableReason>>
    public let devicesLimit: Capability<LimitInfo>
    public let identityRestoration: Capability<NoInfo>
    public let identityTheftProtection: Capability<NoInfo>
    public let passwordsLimit: Capability<LimitInfo>
    public let secureFiles: Capability<FileQuotaInfo>
    public let secureNotes: Capability<NoInfo>
    public let secureWiFi: Capability<ReasonInfo<SecureWifiUnavailableReason>>
    public let securityBreach: Capability<NoInfo>
    public let sharingLimit: Capability<LimitInfo>
    public let sync: Capability<NoInfo>
    public let yubikey: Capability<NoInfo>

    public init(creditMonitoring: Capability<CreditMonitoringInfo> = .init(),
                dataLeak: Capability<ReasonInfo<DarkWebMonitoringUnavailableReason>> = .init(),
                devicesLimit: Capability<LimitInfo> = .init(),
                identityRestoration: Capability<NoInfo> = .init(),
                identityTheftProtection: Capability<NoInfo> = .init(),
                passwordsLimit: Capability<LimitInfo> = .init(),
                secureFiles: Capability<FileQuotaInfo> = .init(),
                secureNotes: Capability<NoInfo> = .init(),
                secureWiFi: Capability<ReasonInfo<SecureWifiUnavailableReason>> = .init(),
                securityBreach: Capability<NoInfo> = .init(),
                sharingLimit: Capability<LimitInfo> = .init(),
                sync: Capability<NoInfo> = .init(),
                yubikey: Capability<NoInfo> = .init()) {
        self.creditMonitoring = creditMonitoring
        self.dataLeak = dataLeak
        self.devicesLimit = devicesLimit
        self.identityRestoration = identityRestoration
        self.identityTheftProtection = identityTheftProtection
        self.passwordsLimit = passwordsLimit
        self.secureFiles = secureFiles
        self.secureNotes = secureNotes
        self.secureWiFi = secureWiFi
        self.securityBreach = securityBreach
        self.sharingLimit = sharingLimit
        self.sync = sync
        self.yubikey = yubikey
    }

}
