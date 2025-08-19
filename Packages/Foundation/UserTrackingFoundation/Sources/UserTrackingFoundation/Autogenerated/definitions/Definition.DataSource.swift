import Foundation

extension Definition {

  public enum `DataSource`: String, Encodable, Sendable {
    case `employeeLogins` = "employee_logins"
    case `nudgesFullActivity` = "nudges_full_activity"
    case `phishingActivity` = "phishing_activity"
    case `urlsForAllowlist` = "urls_for_allowlist"
  }
}
