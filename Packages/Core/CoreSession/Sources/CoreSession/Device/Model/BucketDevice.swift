import Foundation

public struct BucketDevice: Decodable, Hashable {
    public enum Platform: String, Decodable {
        case iphone = "server_iphone"
        case ipad = "server_ipad"
        case ipod = "server_ipod"
        case android = "server_android"
        case macos = "server_macosx"
        case catalyst = "server_catalyst"
        case windows = "server_win"
        case web

        var isDesktop: Bool {
            return self == .macos || self == .windows
        }
    }
        public let id: String
        public let name: String
        public let platform: Platform
        public let creationDate: Date
        public let lastUpdateDate: Date
        public let lastActivityDate: Date
        public let isBucketOwner: Bool
        public let isTemporary: Bool

    enum CodingKeys: String, CodingKey {
        case id = "deviceId"
        case name = "deviceName"
        case platform = "devicePlatform"
        case creationDate = "creationDateUnix"
        case lastUpdateDate = "lastUpdateDateUnix"
        case lastActivityDate = "lastActivityDateUnix"
        case isBucketOwner = "isBucketOwner"
        case isTemporary = "temporary"
    }

    public init(id: String,
                name: String,
                platform: BucketDevice.Platform,
                creationDate: Date,
                lastUpdateDate: Date,
                lastActivityDate: Date,
                isBucketOwner: Bool,
                isTemporary: Bool) {
        self.id = id
        self.name = name
        self.platform = platform
        self.creationDate = creationDate
        self.lastUpdateDate = lastUpdateDate
        self.lastActivityDate = lastActivityDate
        self.isBucketOwner = isBucketOwner
        self.isTemporary = isTemporary
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""

        let platformString = try container.decodeIfPresent(String.self, forKey: .platform) ?? ""
        if let devicePlatform = Platform(rawValue: platformString) {
            platform = devicePlatform
        } else {
                        platform = .web
        }

        creationDate = try container.decode(Date.self, forKey: .creationDate)
        lastUpdateDate = try container.decode(Date.self, forKey: .lastUpdateDate)
        lastActivityDate = try container.decode(Date.self, forKey: .lastActivityDate)
        isBucketOwner = try container.decode(Bool.self, forKey: .isBucketOwner)
        isTemporary = try container.decode(Bool.self, forKey: .isTemporary)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension Collection where Element == BucketDevice {
    func sortedByUpdateDate() -> [BucketDevice] {
        return self.sorted { $0.lastUpdateDate > $1.lastUpdateDate }
    }

        func lastActive() -> BucketDevice? {
        let devices = self.sortedByUpdateDate()

                        if let desktop = devices.first(where: { $0.platform.isDesktop }) {
            return desktop
        }

                        if let `extension` = devices.first(where: { $0.platform == .web }) {
            return `extension`
        }

        return nil
    }
}
