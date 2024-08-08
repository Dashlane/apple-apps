import Foundation

extension Definition {

  public enum `TreatProblem`: String, Encodable, Sendable {
    case `download`
    case `notNeeded` = "not_needed"
    case `upload`
    case `uploadAndDownload` = "upload_and_download"
  }
}
