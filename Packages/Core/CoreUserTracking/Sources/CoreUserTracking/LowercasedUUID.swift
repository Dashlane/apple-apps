import Foundation

public struct LowercasedUUID: Codable, CustomStringConvertible {
    
    private let uuid: UUID
    
    public init() {
        self.uuid = UUID()
    }

    public init?(uuidString: String) {
        guard let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        self.uuid = uuid
    }

    
    public init(from decoder: Decoder) throws {
        self.uuid = try decoder.singleValueContainer().decode(UUID.self)
    }
    

    public var uuidString: String {
        return uuid.uuidString.lowercased()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(uuid.uuidString.lowercased())
    }
    
    public var description: String {
        return uuid.uuidString.lowercased()
    }
}

