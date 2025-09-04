import Foundation

extension Definition {

  public enum `OriginalAuthMethod`: String, Encodable, Sendable {
    case `mp`
    case `mpless`
    case `propertyNotAvailable` = "property_not_available"
  }
}
