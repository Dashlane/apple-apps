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
         url: PersonalDataURL?,
         credentialCategories: [CredentialCategory]) {
        self.init()
        self.title = service.title
        self.url = url
        self.email = email

        let categoryName = NSLocalizedString(service.category, comment: "")
        self.category = credentialCategories.first(where: { $0.name == categoryName })
    }
}
