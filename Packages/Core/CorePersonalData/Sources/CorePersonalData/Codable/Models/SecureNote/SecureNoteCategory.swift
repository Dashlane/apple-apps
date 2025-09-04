import CoreTypes
import Foundation
import LogFoundation

@Loggable
@PersonalData("SECURENOTE_CATEGORY")
public struct SecureNoteCategory: Equatable, Identifiable {

  @CodingKey("categoryName")
  public var name: String

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    name = ""
  }

  public func validate() throws {
    if name.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \SecureNoteCategory.name)
    }
  }
}
