import Foundation

public struct PasswordHealthReport {

  public typealias CredentialsByFilter = [PasswordHealthAnalyzer.Request.Filter:
    [SecurityDashboardCredential]]
  public let score: Int?
  public let allCredentialsReport: ComputeReport
  public let importantCredentialsReport: ComputeReport

  public init(
    score: Int?, allCredentialsReport: ComputeReport, importantCredentialsReport: ComputeReport
  ) {
    self.score = score
    self.allCredentialsReport = allCredentialsReport
    self.importantCredentialsReport = importantCredentialsReport
  }

  public struct ComputeReport {
    public let totalCount: Int
    public let corruptedCount: Int
    public let compromisedCount: Int
    public let compromisedByDataLeakCount: Int
    public let countsByFilter: [PasswordHealthAnalyzer.Request.Filter: Int]
    public let countsByStrength: [PasswordStrength: Int]
    public let averagePasswordStrength: Double

    public init(
      credentials: [SecurityDashboardCredential],
      requests: [PasswordHealthAnalyzer.Request],
      results: [PasswordHealthAnalyzer.Request: PasswordHealthResult]
    ) {
      totalCount = credentials.count
      corruptedCount = PasswordHealthReport.count(for: requests, in: results)
      countsByFilter = PasswordHealthReport.countsByFilter(for: requests, in: results)
      let uncheckedCredentials = credentials.filter { !$0.disabledForPasswordAnalysis }
      countsByStrength = PasswordHealthReport.countsByStrength(with: uncheckedCredentials)
      compromisedCount = uncheckedCredentials.filter { $0.compromisedIn.count != 0 }.count
      compromisedByDataLeakCount = uncheckedCredentials.compromisedByDataLeakCount()
      if uncheckedCredentials.isEmpty {
        averagePasswordStrength = 0
      } else {
        let sumOfStrengthScore = uncheckedCredentials.map { $0.strength.percentScore }.reduce(0, +)
        averagePasswordStrength = Double(sumOfStrengthScore) / Double(uncheckedCredentials.count)
      }
    }
  }

}

extension Array where Element == SecurityDashboardCredential {
  func compromisedByDataLeakCount() -> Int {
    self.filter { credential in
      credential.compromisedIn.first(where: { $0.kind == .dataLeak }) != nil
    }.count
  }
}

extension PasswordHealthReport {
  private enum ReportKey: String {
    case passwordsCount = "nbrPasswords"
    case score = "securityIndex"
    case reusedCount = "reused"
    case weakCount = "weakPasswords"
    case compromisedCount = "compromisedPasswords"
    case averagePasswordStrength = "averagePasswordStrength"
    case passwordStrengthVeryUnsafeCount = "passwordStrength0_19Count"
    case passwordStrengthUnsafeCount = "passwordStrength20_39Count"
    case passwordStrengthNotSoSafeCount = "passwordStrength40_59Count"
    case passwordStrengthSafeCount = "passwordStrength60_79Count"
    case passwordStrengthSuperSafeCount = "passwordStrength80_100Count"
    case checkedCount = "checkedPasswords"
    case safeCount = "safePasswords"
  }

  public func computeUserActivityReportDictionary() -> [String: Any] {
    var dic = [ReportKey: Any]()
    dic[.passwordsCount] = allCredentialsReport.totalCount
    dic[.score] = score ?? "null"
    dic[.reusedCount] = allCredentialsReport.countsByFilter[.reused]
    dic[.weakCount] = allCredentialsReport.countsByFilter[.weak]
    dic[.compromisedCount] = allCredentialsReport.compromisedCount
    dic[.averagePasswordStrength] = allCredentialsReport.averagePasswordStrength
    dic[.passwordStrengthVeryUnsafeCount] = allCredentialsReport.countsByStrength[.veryUnsafe]
    dic[.passwordStrengthUnsafeCount] = allCredentialsReport.countsByStrength[.unsafe]
    dic[.passwordStrengthSafeCount] = allCredentialsReport.countsByStrength[.safe]
    dic[.passwordStrengthSuperSafeCount] = allCredentialsReport.countsByStrength[.superSafe]
    dic[.checkedCount] = allCredentialsReport.countsByFilter[.checked]
    dic[.safeCount] = allCredentialsReport.totalCount - allCredentialsReport.corruptedCount

    return Dictionary(
      uniqueKeysWithValues: dic.map { key, value in
        (key.rawValue, value)
      }
    )
  }
}

extension PasswordHealthReport {
  private static func countsByFilter(
    for requests: [PasswordHealthAnalyzer.Request],
    in results: ([PasswordHealthAnalyzer.Request: PasswordHealthResult])
  ) -> [PasswordHealthAnalyzer.Request.Filter: Int] {
    var counts: [PasswordHealthAnalyzer.Request.Filter: Int] = [:]
    for request in requests {
      guard let result = results[request] else {
        continue
      }
      counts[request.filter] = result.count
    }
    return counts
  }

  private static func credentialsByFilter(
    for requests: [PasswordHealthAnalyzer.Request],
    in results: [PasswordHealthAnalyzer.Request: PasswordHealthResult]
  ) -> CredentialsByFilter {

    return requests.reduce(into: CredentialsByFilter()) { credentialsByFilter, request in
      guard let result = results[request] else {
        return
      }
      credentialsByFilter[request.filter] = result.credentials
    }
  }

  private static func countsByStrength(with credentials: [SecurityDashboardCredential])
    -> [PasswordStrength: Int]
  {
    return credentials.reduce(into: [PasswordStrength: Int]()) { (dic, credential) in
      dic[credential.strength, default: 0] += 1
    }
  }

  private static func count(
    for requests: [PasswordHealthAnalyzer.Request],
    in results: ([PasswordHealthAnalyzer.Request: PasswordHealthResult])
  ) -> Int {
    var elements: [SecurityDashboardCredential] = []
    for request in requests {
      guard let result = results[request] else {
        continue
      }
      elements.append(
        contentsOf: result.elements.filter { elem in
          !elements.contains(where: { $0.identifier == elem.identifier })
        })
    }
    return elements.count
  }
}

extension PasswordStrength {

  var percentScore: Int {
    return (rawValue - 1) * 25
  }

}

extension PasswordHealthReport: CustomStringConvertible {
  public var description: String {
    return """
      Score \(self.score ?? -1)

      All credentials report:
      \(self.allCredentialsReport)

      Important credentials report:
      \(self.importantCredentialsReport)
      """
  }

}

extension PasswordHealthReport.ComputeReport: CustomStringConvertible {
  public var description: String {
    return """
      Filters:
      - Safe \(totalCount - corruptedCount)
      - Weak \(self.countsByFilter[.weak] ?? 0)
      - Compromised \(self.countsByFilter[.compromised] ?? 0)
      - Reused \(self.countsByFilter[.reused] ?? 0)
      Strength:
      - Average \(self.averagePasswordStrength)
      - Very unsafe \(self.countsByStrength[.veryUnsafe] ?? 0)
      - Unsafe \(self.countsByStrength[.unsafe] ?? 0)
      - Not so safe \(self.countsByStrength[.notSoSafe] ?? 0)
      - Safe \(self.countsByStrength[.safe] ?? 0)
      - Super safe \(self.countsByStrength[.superSafe] ?? 0)
      Compromised count: \(self.compromisedCount)
      Corrupted count: \(self.corruptedCount)
      """
  }
}
