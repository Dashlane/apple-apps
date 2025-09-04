import CoreTypes
import Foundation

public struct PersonalDataSnapshot: Identifiable, Hashable {
  public let id: Identifier

  public var content: PersonalDataCollection
}
