import Foundation

public struct AuthenticationCompleteRemoteKeys: Codable, Equatable {

    public let uuid: String

    public let key: String

    public let type: AuthenticationCompleteType

    public init(uuid: String, key: String, type: AuthenticationCompleteType) {
        self.uuid = uuid
        self.key = key
        self.type = type
    }
}
