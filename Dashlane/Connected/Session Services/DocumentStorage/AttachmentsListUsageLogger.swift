import Foundation
import DashlaneReportKit

struct AttachmentsListUsageLogger {
    let anonId: String
    let usageLogService: UsageLogServiceProtocol

    struct Log {
        static let type = "type"
        static let upload = "upload"
        static let download = "download"
        static let itemId = "item_id"
        static let success = "success"
        static let subAction = "action_sub"
        static let uploadFileType = "upload_fileType"
        static let uploadCancelled = "upload_cancelled"
        static let takePhoto = "take_photo"
        static let pickPhoto = "pick_photo"
        static let pickFile = "pick_file"
        static let action = "action"
        static let click = "click"
        static let delete = "delete"
        static let start = "start"
        static let view = "view"
        static let error = "error"
        static let confirm = "confirm"
    }

    func logUploadStart() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .start,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadSuccess() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .success,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadError() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .error,
                                                          action_sub: "upload",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadFileTypeError(with fileExtension: String) {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .error,
                                                          action_sub: "upload_fileType_\(fileExtension)",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadCancelled() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .error,
                                                          action_sub: "upload_cancelled",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadClickPickPhoto() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .click,
                                                          action_sub: "pick_photo",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadClickPickFile() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .click,
                                                          action_sub: "pick_file",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadClickTakePhoto() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .click,
                                                          action_sub: "take_photo",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logUploadClick() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .upload,
                                                          action: .click,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logDeleteConfirm() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .delete,
                                                          action: .confirm,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logDeleteClick() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .delete,
                                                          action: .click,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logDownloadSuccess() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .download,
                                                          action: .success,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logViewStart() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .view,
                                                          action: .start,
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logDownloadError() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .download,
                                                          action: .error,
                                                          action_sub: "download",
                                                          item_id: anonId)
        usageLogService.post(log)
    }

    func logDownloadStart() {
        let log = UsageLogCode122DocumentStorageUXBackend(type: .download,
                                                          action: .start,
                                                          item_id: anonId)
        usageLogService.post(log)
    }
}
