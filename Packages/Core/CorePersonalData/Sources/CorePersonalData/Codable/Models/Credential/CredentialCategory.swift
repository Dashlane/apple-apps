import DashTypes
import Foundation

@PersonalData("AUTH_CATEGORY")
public struct CredentialCategory: Equatable, Identifiable {
  @CodingKey("categoryName")
  public var name: String

  public init(id: Identifier = Identifier(), name: String = "") {
    self.id = id
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    self.name = name
  }

  public func validate() throws {
    if name.isEmptyOrWhitespaces() {
      throw ItemValidationError(invalidProperty: \CredentialCategory.name)
    }
  }
}
