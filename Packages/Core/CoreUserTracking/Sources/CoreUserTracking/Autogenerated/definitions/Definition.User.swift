import Foundation

extension Definition {

public struct `User`: Encodable {
public init(`id`: LowercasedUUID) {
self.id = id
}
public let id: LowercasedUUID
}
}