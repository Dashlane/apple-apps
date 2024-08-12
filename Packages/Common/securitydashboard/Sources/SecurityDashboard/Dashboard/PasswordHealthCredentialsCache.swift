import Foundation

actor PasswordHealthCredentialsCache {
  private var credentialsByCheckStatus: [Bool: [SecurityDashboardCredential]] = [:]

  var safeNotExcludedCredentials: [SecurityDashboardCredential] {
    self.credentialsByCheckStatus[false] ?? []
  }

  func credentials(for filter: PasswordHealthAnalyzer.Request.Filter)
    -> [SecurityDashboardCredential]
  {
    return credentialsByCheckStatus[filter == .checked, default: []]
  }

  func update(with credentials: [SecurityDashboardCredential]) {
    self.credentialsByCheckStatus = Dictionary(grouping: credentials) {
      $0.disabledForPasswordAnalysis
    }
  }
}
