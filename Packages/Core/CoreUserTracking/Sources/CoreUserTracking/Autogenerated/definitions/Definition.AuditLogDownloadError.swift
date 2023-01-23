import Foundation

extension Definition {

public enum `AuditLogDownloadError`: String, Encodable {
case `noCsv` = "no_csv"
case `noLogData` = "no_log_data"
case `unexpectedUnknown` = "unexpected_unknown"
}
}