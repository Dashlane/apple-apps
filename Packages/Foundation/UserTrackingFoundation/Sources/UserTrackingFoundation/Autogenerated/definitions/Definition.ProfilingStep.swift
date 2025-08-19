import Foundation

extension Definition {

  public enum `ProfilingStep`: String, Encodable, Sendable {
    case `familiarityWithPasswordManagers` = "familiarity_with_password_managers"
    case `features`
    case `teamSize` = "team_size"
    case `useCase` = "use_case"
  }
}
