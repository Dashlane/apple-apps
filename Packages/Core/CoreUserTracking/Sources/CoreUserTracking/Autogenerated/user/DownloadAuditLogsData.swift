import Foundation

extension UserEvent {

public struct `DownloadAuditLogsData`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`auditLogCount`: Int? = nil, `auditLogDownloadError`: Definition.AuditLogDownloadError? = nil, `flowStep`: Definition.FlowStep) {
self.auditLogCount = auditLogCount
self.auditLogDownloadError = auditLogDownloadError
self.flowStep = flowStep
}
public let auditLogCount: Int?
public let auditLogDownloadError: Definition.AuditLogDownloadError?
public let flowStep: Definition.FlowStep
public let name = "download_audit_logs_data"
}
}
