import Foundation

extension Definition {

public struct `Domain`: Encodable {
public init(`id`: String? = nil, `type`: Definition.DomainType) {
self.id = id
self.type = type
}
public let id: String?
public let type: Definition.DomainType
}
}