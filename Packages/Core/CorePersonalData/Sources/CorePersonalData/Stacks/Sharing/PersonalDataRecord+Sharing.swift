import Foundation
import DashTypes

public extension PersonalDataContentType {
    var sharingType: SharingType? {
        switch self {
            case .credential:
                return .password
            case .secureNote:
                return .note
            default:
                return nil
        }
    }
}

public extension RecordMetadata {
    var isShareable: Bool {
        return contentType.sharingType != nil && (isShared && sharingPermission == .admin || !isShared)
    }
}

extension PersonalDataRecord {
    enum SharingRecordKey: String {
        case id
        case title
        case spaceId
    }
    
    subscript(key: SharingRecordKey) -> String? {
        get {
            content[key.rawValue]?.item
        } set {
            content[key.rawValue] = newValue.map { .item($0) }
        }
    }
}
