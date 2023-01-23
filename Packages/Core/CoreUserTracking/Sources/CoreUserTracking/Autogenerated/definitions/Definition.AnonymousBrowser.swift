import Foundation

extension Definition {

public struct `AnonymousBrowser`: Encodable {
public init(`name`: String, `version`: String? = nil) {
self.name = name
self.version = version
}
public let name: String
public let version: String?
}
}