import Foundation

extension Definition {

public struct `ContextAnonymous`: Encodable {
public init(`app`: Definition.App, `browser`: Definition.AnonymousBrowser? = nil, `os`: Definition.Os) {
self.app = app
self.browser = browser
self.os = os
}
public let app: Definition.App
public let browser: Definition.AnonymousBrowser?
public let os: Definition.Os
}
}