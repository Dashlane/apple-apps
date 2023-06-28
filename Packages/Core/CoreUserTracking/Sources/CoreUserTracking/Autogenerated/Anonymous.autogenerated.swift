import Foundation

extension Report {

public struct `Anonymous`<Event: AnonymousEventProtocol>: Encodable {
public init(`browse`: Definition.Browse? = nil, `context`: Definition.ContextAnonymous, `date`: Date, `dateOrigin`: Definition.DateOrigin, `id`: LowercasedUUID, properties: Event) {
self.browse = browse
self.context = context
self.date = date
self.dateOrigin = dateOrigin
self.id = id
self.properties = properties
}
public let browse: Definition.Browse?
public let category = "anonymous"
public let context: Definition.ContextAnonymous
public let date: Date
public let dateOrigin: Definition.DateOrigin
public let id: LowercasedUUID
public let schemaVersion = "1.19.11"
public let properties: Event
}
}