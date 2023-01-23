import Foundation
import DashTypes

extension SharingKeys {
    init?(_ raw: RawSharingKeys?) {
        guard let raw = raw,
              let privateKey = raw.privateKey,
              !privateKey.isEmpty,
              let publicKey = raw.publicKey,
              !publicKey.isEmpty else {
                  return nil
              }
        
        self.init(publicKey: publicKey, encryptedPrivateKey: privateKey)
    }
}

struct RawSharingKeys: Codable {
    public let privateKey: String?
    public let publicKey: String?
}
