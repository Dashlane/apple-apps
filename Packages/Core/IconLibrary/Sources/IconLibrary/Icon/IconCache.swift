import Combine
import CoreTypes
import Foundation

public struct IconCache: Sendable {
  public var icon: Icon?
  var modificationDate: Date?

  public init(icon: Icon? = nil, modificationDate: Date? = nil) {
    self.icon = icon
    self.modificationDate = modificationDate
  }
}
