import DashTypes
import Foundation

@PersonalData("GENERATED_PASSWORD")
public struct GeneratedPassword: Equatable {
  public static let searchCategory: SearchCategory = .credential

  public var creationDatetime: Date?
  public var authId: Identifier?
  public var generatedDate: Date?
  public var password: String?
  @Searchable
  public var domain: PersonalDataURL?
  public var platform: String

  public init() {
    id = Identifier()
    metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
    generatedDate = nil
    password = nil
    platform = ""
    domain = nil
    creationDatetime = Date()
    authId = nil
  }
}
