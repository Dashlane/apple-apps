import Foundation
import DashTypes

struct SharingUploadTrigger {
    func update(_ metadata: inout RecordMetadata,
                for newContent: PersonalDataCollection,
                oldContent: PersonalDataCollection) {
        guard metadata.isShared else {
            return
        }

        let needsSharing = oldContent.isEmpty ? true : metadata
            .contentType
            .sharedPropertyKeys
            .contains {
                newContent[$0] != oldContent[$0]
            }

        guard needsSharing else {
            return
        }

        metadata.pendingSharingUploadId = UUID().uuidString
    }
}

extension SharingType {
    var sharedPropertyKeys: Set<String> {
        switch self {
            case .password:
                let keys: [Credential.CodingKeys] = [
                    .title,
                    .email,
                    .url,
                    .login,
                    .secondaryLogin,
                    .password,
                    .rawOTPURL,
                    .legacyOTPSecret,
                    .url,
                    .linkedServices,
                    .useFixedUrl,
                    .userSelectedUrl,
                    .note
                ]
                return Set(keys.map(\.rawValue))
            case .note:
                let keys: [SecureNote.CodingKeys] = [
                    .title,
                    .content,
                    .secured
                ]
                return Set(keys.map(\.rawValue))
        }
    }
}

extension PersonalDataContentType {
    var sharedPropertyKeys: Set<String> {
        return sharingType?.sharedPropertyKeys ?? []
    }
}
