import Foundation

extension Definition {

  public enum `ErrorStep`: String, Encodable, Sendable {
    case `chronological`
    case `deduplicate`
    case `sharing`
    case `treatProblem` = "treat_problem"
  }
}
