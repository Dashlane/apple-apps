import Foundation

public struct StatusCapabilitySet: Decodable, CapabilitySet {
    public var creditMonitoring: Capability<CreditMonitoringInfo> = .init()
    public var dataLeak: Capability<ReasonInfo<DarkWebMonitoringUnavailableReason>> = .init()
    public var devicesLimit: Capability<LimitInfo> = .init()
    public var identityRestoration: Capability<NoInfo> = .init()
    public var identityTheftProtection: Capability<NoInfo> = .init()
    public var passwordsLimit: Capability<LimitInfo> = .init()
    public var secureFiles: Capability<FileQuotaInfo> = .init()
    public var secureNotes: Capability<NoInfo> = .init()
    public var secureWiFi: Capability<ReasonInfo<SecureWifiUnavailableReason>> = .init()
    public var securityBreach: Capability<NoInfo> = .init()
    public var sharingLimit: Capability<LimitInfo> = .init()
    public var sync: Capability<NoInfo> = .init()
    public var yubikey: Capability<NoInfo> = .init()

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
    
        public init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()

        while !arrayContainer.isAtEnd {
            let container = try arrayContainer.nestedContainer(keyedBy: CapabilityCodingKey.self)

            guard let key = try? container.decode(CapabilityKey.self, forKey: .capability) else {
                continue
            }

            switch key {
                case .dataLeak:
                    self.dataLeak = try container.decode()
                case .creditMonitoring:
                    self.creditMonitoring = try container.decode()
                case .devicesLimit:
                    self.devicesLimit = try container.decode()
                case .identityRestoration:
                    self.identityRestoration = try container.decode()
                case .identityTheftProtection:
                    self.identityTheftProtection = try container.decode()
                case .secureFiles:
                    self.secureFiles = try container.decode()
                case .secureNotes:
                    self.secureNotes = try container.decode()
                case .secureWiFi:
                    self.secureWiFi = try container.decode()
                case .securityBreach:
                    self.securityBreach = try container.decode()
                case .sharingLimit:
                    self.sharingLimit = try container.decode()
                case .sync:
                    self.sync = try container.decode()
                case .yubikey:
                    self.yubikey = try container.decode()
            }
        }
    }
}

private enum CapabilityCodingKey: CodingKey {
    case capability
    case enabled
    case info
}

private extension KeyedDecodingContainer where K == CapabilityCodingKey {
    func decode<Info>() throws -> Capability<Info> {
        do {
            let enabled = try decode(Bool.self, forKey: .enabled)
            let info = try? decodeIfPresent(Info.self, forKey: .info)
            return Capability(enabled: enabled, info: info)
        } catch {
            return .init()
        }

    }
}
