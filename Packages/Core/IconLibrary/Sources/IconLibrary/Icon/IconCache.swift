import Combine
import DashTypes
import Foundation

public struct IconCache {
  public var icon: Icon?
  var modificationDate: Date?

  public init(icon: Icon? = nil, modificationDate: Date? = nil) {
    self.icon = icon
    self.modificationDate = modificationDate
  }
}
