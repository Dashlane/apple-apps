import Foundation

extension Definition {

  public enum `AuditLogDownloadError`: String, Encodable, Sendable {
    case `noCsv` = "no_csv"
    case `noLogData` = "no_log_data"
    case `unexpectedUnknown` = "unexpected_unknown"
  }
}
