import Foundation
import CorePersonalData

public struct PrefilledCredential: Decodable {
    public let title: String
    public let url: String
    public let category: String
}

public extension Credential {
    init(service: PrefilledCredential,
         email: String,
         url: PersonalDataURL?) {
        self.init()
        self.title = service.title
        self.url = url
        self.email = email
    }
}
