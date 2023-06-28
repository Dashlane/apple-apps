import Foundation

public enum ServerAuthentication: Equatable, Codable {
        case uki(UKI)
        case signatureBased(SignedAuthentication)

        public var deviceId: String {
        switch self {
        case let .uki(uki):
            return uki.deviceId
        case let .signatureBased(deviceAuthentication):
            return deviceAuthentication.deviceAccessKey
        }
    }

    public var isSignatureBased: Bool {
        switch self {
        case  .uki:
            return false
        case  .signatureBased:
            return true
        }
    }

            public var uki: UKI {
        switch self {
            case let .uki(uki):
                return uki
            case let .signatureBased(deviceAuthentication):
                return deviceAuthentication.compatibilityUKI
        }
    }

            public var signedAuthentication: SignedAuthentication {
        switch self {
            case let .uki(uki):
                return uki.compatibilitySignedAuthentication
            case let .signatureBased(deviceAuthentication):
                return deviceAuthentication
        }
    }

    public init(deviceAccessKey: String, deviceSecretKey: String) {
        self = .signatureBased(SignedAuthentication(deviceAccessKey: deviceAccessKey, deviceSecretKey: deviceSecretKey))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let authentication = try? container.decode(SignedAuthentication.self) {
            self = .signatureBased(authentication)
        } else if let uki = try? container.decode(UKI.self) {
            self = .uki(uki)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode SignedAuthentication or UKI")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .uki(uki):
                return try container.encode(uki)
            case let .signatureBased(deviceAuthentication):
                return try container.encode(deviceAuthentication)
        }
    }
}

public struct UKI: Codable, Equatable {
    public let deviceId: String
    public let secret: String

    public var rawValue: String {
        [deviceId, secret].joined(separator: "-")
    }

        var compatibilitySignedAuthentication: SignedAuthentication {
        SignedAuthentication(deviceAccessKey: deviceId, deviceSecretKey: rawValue) 
    }

    public init(deviceId: String, secret: String) {
        self.deviceId = deviceId
        self.secret = secret
    }
}

public struct SignedAuthentication: Codable, Equatable {
    public let deviceAccessKey: String
    public let deviceSecretKey: String

    public init(deviceAccessKey: String, deviceSecretKey: String) {
        self.deviceAccessKey = deviceAccessKey
        self.deviceSecretKey = deviceSecretKey
    }

        var compatibilityUKI: UKI {
        return UKI(deviceId: deviceAccessKey, secret: deviceSecretKey)
    }
}
