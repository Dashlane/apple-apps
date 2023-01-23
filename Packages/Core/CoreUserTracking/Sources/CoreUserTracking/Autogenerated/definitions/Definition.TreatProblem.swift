import Foundation

extension Definition {

public enum `TreatProblem`: String, Encodable {
case `download`
case `notNeeded` = "not_needed"
case `upload`
case `uploadAndDownload` = "upload_and_download"
}
}