import Foundation

extension Definition {

public struct `App`: Encodable {
public init(`buildType`: Definition.BuildType, `platform`: Definition.Platform, `version`: String) {
self.buildType = buildType
self.platform = platform
self.version = version
}
public let buildType: Definition.BuildType
public let platform: Definition.Platform
public let version: String
}
}