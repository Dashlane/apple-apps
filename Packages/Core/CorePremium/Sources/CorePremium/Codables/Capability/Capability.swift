import Foundation

public struct Capability<Info: Decodable>: Decodable {
    public let enabled: Bool
    public let info: Info?

    public init(enabled: Bool = false, info: Info? = nil) {
        self.enabled = enabled
        self.info = info
    }
}

public struct NoInfo: Decodable {

}

public struct LimitInfo: Decodable {
    public let limit: Int
}

public struct ReasonInfo<Reason: Decodable>: Decodable {
    public let reason: Reason

    public init(reason: Reason) {
        self.reason = reason
    }
}

public struct FileQuotaInfo: Decodable {
    public struct Quota: Decodable {
        enum CodingKeys: CodingKey {
            case max
            case remaining
        }

        public let max: Int
        public let remaining: Int

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.max = try container.decode(Int.self, forKey: .max)
            self.remaining = try container.decodeIfPresent(Int.self, forKey: .remaining) ?? 0
        }
    }
    public let quota: Quota
    public let maxFileSize: Int
}

extension KeyedDecodingContainer {
    func decode<Info>(_ type: Capability<Info>.Type,
                      forKey key: Key) throws -> Capability<Info> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}
