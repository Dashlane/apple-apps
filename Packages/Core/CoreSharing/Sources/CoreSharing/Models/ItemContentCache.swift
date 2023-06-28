import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

public struct ItemContentCache: Codable, Identifiable, Hashable {
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case encryptedContent
    }
        public let id: Identifier
        public let timestamp: SharingTimestamp
        public let encryptedContent: String
}

extension ItemContentCache {
    init(_ item: ItemContent) {
        self.id = Identifier(item.itemId)
        self.timestamp = item.timestamp
        self.encryptedContent = item.content
    }
}

extension ItemContentCache {
                func content(using engine: CryptoEngine) throws -> SymmetricKey {
        let encryptedContentBase64 = encryptedContent
        guard !encryptedContentBase64.isEmpty,
              let encryptedContent = Data(base64Encoded: encryptedContentBase64) else {
            throw SharingGroupError.missingKey(.itemKey)
        }

        return try encryptedContent.decrypt(using: engine)
    }
}
