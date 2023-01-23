import SwiftUI
import Contacts

class SystemContactRecipientProvider {
    var cachedImages: [String: Image] = [:]
    lazy var contactStore = CNContactStore()

    func search(_ search: String) -> [EmailRecipient] {
        do {
            let status = CNContactStore.authorizationStatus(for: .contacts)
            guard status == .authorized || status == .notDetermined else {
                return []
            }

            return try self.contactStore.search(search)
                .map { contact in
                    return EmailRecipient(label: contact.label, email: contact.email, image: image(for: contact), origin: .systemContact)
                }
        } catch {
                        return []
        }
    }

    private func image(for contact: CNContactStore.SearchResult) -> Image? {
        let image: Image?
        if let cached = cachedImages[contact.email] {
            image = cached
        } else if let data = contact.thumbnailData, let uiImage = UIImage(data: data) {
            let newImage = Image(uiImage: uiImage)
            image = newImage
            cachedImages[contact.email] = newImage
        } else {
            image = nil
        }
        return image
    }
}
