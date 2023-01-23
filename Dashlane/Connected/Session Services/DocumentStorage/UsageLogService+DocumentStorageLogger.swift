import Foundation
import DocumentServices
import CorePersonalData
import DashlaneReportKit

private struct DocumentLogger: DocumentStorageLogger {
    let usageLogService: UsageLogServiceProtocol

    func logAttachment(for secureFileInfo: SecureFileInformation, action: DocumentActionType) {
        guard let fileExtension = secureFileInfo.fileExtension,
            let localSize = secureFileInfo.localSizeInt,
            let remoteSize = secureFileInfo.remoteSizeInt else { return }
        let log = UsageLogCode123DocumentDetails(action: action.usageLogAction,
                                                 file_extension: fileExtension,
                                                 local_size: localSize,
                                                 upload_size: remoteSize,
                                                 item_id: secureFileInfo.anonId)
        usageLogService.post(log)
    }
}

extension UsageLogServiceProtocol {
    var documentLogger: DocumentStorageLogger {
        DocumentLogger(usageLogService: self)
    }
}

fileprivate extension SecureFileInformation {
    var fileExtension: String? {
        guard let url = URL(string: filename) else { return nil }
        return url.pathExtension
    }

    var localSizeInt: Int? {
        return Int(localSize)
    }

    var remoteSizeInt: Int? {
        return Int(remoteSize)
    }
}

fileprivate extension DocumentActionType {
    var usageLogAction: UsageLogCode123DocumentDetails.ActionType {
        switch self {
        case .add: return .add
        case .edit: return .edit
        case .delete: return .delete
        }
    }
}
