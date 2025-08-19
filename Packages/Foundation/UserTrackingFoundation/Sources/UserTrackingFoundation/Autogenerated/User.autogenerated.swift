import Foundation

extension Report {

  public struct `User`<Event: UserEventProtocol>: Encodable, Sendable {
    public init(
      `browse`: Definition.Browse, `context`: Definition.Context, `date`: Date,
      `dateOrigin`: Definition.DateOrigin, `id`: LowercasedUUID,
      `session`: Definition.Session? = nil,
      properties: Event
    ) {
      self.browse = browse
      self.context = context
      self.date = date
      self.dateOrigin = dateOrigin
      self.id = id
      self.session = session
      self.properties = properties
    }
    public let browse: Definition.Browse
    public let category = "user"
    public let context: Definition.Context
    public let date: Date
    public let dateOrigin: Definition.DateOrigin
    public let id: LowercasedUUID
    public let schemaVersion = "1.31.11"
    public let session: Definition.Session?
    public let properties: Event
  }
}
