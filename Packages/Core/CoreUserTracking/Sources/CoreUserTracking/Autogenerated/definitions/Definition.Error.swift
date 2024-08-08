import Foundation

extension Definition {

  public struct `Error`: Encodable, Sendable {
    public init(
      `description`: Definition.ErrorDescription? = nil, `name`: Definition.ErrorName,
      `step`: Definition.ErrorStep
    ) {
      self.description = description
      self.name = name
      self.step = step
    }
    public let description: Definition.ErrorDescription?
    public let name: Definition.ErrorName
    public let step: Definition.ErrorStep
  }
}
