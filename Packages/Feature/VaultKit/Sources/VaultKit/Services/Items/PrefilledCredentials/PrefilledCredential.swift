import CorePersonalData
import Foundation

public struct PrefilledCredential: Decodable {
  public let title: String
  public let url: String
  public let category: String
}

extension Credential {
  public init(
    service: PrefilledCredential,
    email: String,
    url: PersonalDataURL?
  ) {
    self.init()
    self.title = service.title
    self.url = url
    self.email = email
  }
}
