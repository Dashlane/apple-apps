import Contacts
import Foundation

extension CNContactStore {
  struct SearchResult {
    let label: String
    let email: String
    var thumbnailData: Data?
  }

  func search(_ search: String) throws -> [SearchResult] {
    let fetchRequest = CNContactFetchRequest(keysToFetch: [
      CNContactEmailAddressesKey as CNKeyDescriptor,
      CNContactImageDataAvailableKey as CNKeyDescriptor,
      CNContactThumbnailImageDataKey as CNKeyDescriptor,
      CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    ])

    fetchRequest.predicate = CNContact.predicateForContacts(matchingName: search)
    fetchRequest.sortOrder = .givenName

    var results = [SearchResult]()

    try self.enumerateContacts(with: fetchRequest) { contact, _ in
      for email in contact.emailAddresses {
        let emailString = email.value as String
        let name = CNContactFormatter.string(from: contact, style: .fullName)
        let label = (name != nil) ? name! : emailString.lowercased()
        let result = SearchResult(
          label: label, email: emailString.lowercased(), thumbnailData: contact.thumbnailImageData)
        results.append(result)
      }
    }

    return results
  }
}
