import Combine
import Foundation
import SwiftTreats

public typealias SpaceId = String

public actor PasswordHealthAnalyzer {
  public typealias Password = String
  private let requestCache = AsyncCache<Request, PasswordHealthResult>()
  private let filterCache = AsyncCache<Request.Filter, PasswordHealthResult>()
  private var credentialsCache = PasswordHealthCredentialsCache()

  let passwordsSimilarityOperation: PasswordsSimilarityOperation
  let notificationManager: IdentityDashboardNotificationManager

  init(
    passwordsSimilarityOperation: PasswordsSimilarityOperation,
    notificationManager: IdentityDashboardNotificationManager
  ) {
    self.passwordsSimilarityOperation = passwordsSimilarityOperation
    self.notificationManager = notificationManager
  }

  func reset(with credentials: [SecurityDashboardCredential]) async {
    await credentialsCache.update(with: credentials)
    await requestCache.clearCache()
    await filterCache.clearCache()
  }

  func compute(for requests: [Request]) async -> [Request: PasswordHealthResult] {
    let requestsResult = await withTaskGroup(
      of: (request: Request, result: PasswordHealthResult).self,
      returning: [Request: PasswordHealthResult].self
    ) { taskGroup in
      for request in requests {
        taskGroup.addTask {
          (request, await self.compute(for: request))
        }
      }

      var data: [Request: PasswordHealthResult] = [:]
      for await taskResult in taskGroup {
        data[taskResult.request] = taskResult.result
      }

      return data
    }

    return requestsResult
  }

  func compute(for request: Request) async -> PasswordHealthResult {
    let result = await compute(for: request.filter)
    guard request.sensitiveOnly || request.spaceId != nil else {
      return result
    }

    return await requestCache.value(for: request) {
      Task.detached(priority: .userInitiated) {
        var result = result
        result.filter(bySpacedId: request.spaceId, sensitiveOnly: request.sensitiveOnly)
        return result
      }
    }
  }

  func compute(for filter: Request.Filter) async -> PasswordHealthResult {
    let credentials = await credentialsCache.credentials(for: filter)
    let services = PasswordHealthAnalyzerServices(
      passwordsSimilarityOperation: passwordsSimilarityOperation)
    return await filterCache.value(for: filter) {
      Task.detached(priority: .userInitiated) {
        await filter.algorithm.compute(credentials, using: services)
      }
    }
  }

  nonisolated func compute(for requests: [Request]) -> AnyPublisher<
    [Request: PasswordHealthResult], Never
  > {
    notificationManager
      .publisher(for: .securityDashboardDidRefresh)
      .asyncMap { _ in
        await self.compute(for: requests)
      }
      .eraseToAnyPublisher()
  }

  nonisolated func compute(for request: Request) -> AnyPublisher<PasswordHealthResult, Never> {
    notificationManager
      .publisher(for: .securityDashboardDidRefresh)
      .asyncMap { _ in
        await self.compute(for: request)
      }
      .eraseToAnyPublisher()
  }
}

extension PasswordHealthAnalyzer {
  public struct Request: Hashable {
    public static func == (lhs: PasswordHealthAnalyzer.Request, rhs: PasswordHealthAnalyzer.Request)
      -> Bool
    {
      return lhs.hashValue == rhs.hashValue
    }

    public enum Filter: Int8, CaseIterable {
      case compromised
      case `weak`
      case reused
      case checked
    }

    public let filter: Filter
    public let spaceId: SpaceId?
    public let sensitiveOnly: Bool

    public init(filtering: Filter, spaceID: SpaceId?, sensitiveOnly: Bool = false) {
      self.filter = filtering
      self.spaceId = spaceID
      self.sensitiveOnly = sensitiveOnly
    }
  }
}

extension PasswordHealthAnalyzer {
  public struct ReportRequest {
    public struct AlgorithmParameters {
      public let n: Int
      public let m: Int
      public init(n: Int = 1, m: Int = 1) {
        self.n = n
        self.m = m
      }
    }

    public let spaceId: String?
    public let weightOfImportantAccounts: Float
    public let parameters: AlgorithmParameters

    public init(
      spaceId: String?, weightOfImportantAccounts: Float = 0.6,
      parameters: AlgorithmParameters = AlgorithmParameters(n: 1, m: 1)
    ) {
      self.spaceId = spaceId
      self.weightOfImportantAccounts = weightOfImportantAccounts
      self.parameters = parameters
    }

    func score(forCorruptedCount corruptedAccount: Int, importantCorruptedCount: Int, total: Int)
      -> Float
    {
      let d = weightOfImportantAccounts

      let n = Float(parameters.n)
      let m = Float(parameters.m)

      let A = Float(total)
      let Ac = Float(corruptedAccount)
      let Ic = Float(importantCorruptedCount)

      let part2 = d * pow(1.0 - (Ic / A), n)
      let part3 = (1.0 - d) * pow(1.0 - (Ac / A), m)

      let result = (0.2 + 0.8 * (part2 + part3)) * 100

      return result
    }
  }

  private static let scoreMinimumNumberOfCredentials = 5

  func report(for request: ReportRequest) async -> PasswordHealthReport {
    let requestFilters: [PasswordHealthAnalyzer.Request.Filter] = [.compromised, .weak, .reused]

    let requests = requestFilters.map {
      Request(filtering: $0, spaceID: request.spaceId, sensitiveOnly: false)
    }
    let requestsImportant = requestFilters.map {
      Request(filtering: $0, spaceID: request.spaceId, sensitiveOnly: true)
    }

    let credentialsCachedCredentials: [SecurityDashboardCredential] =
      await credentialsCache.credentials(for: .compromised)
    let results = await self.compute(for: requests + requestsImportant)
    var credentials = credentialsCachedCredentials
    if let spaceId = request.spaceId {
      credentials = credentials.filter { $0.spaceId == spaceId }
    }

    let allReport = PasswordHealthReport.ComputeReport(
      credentials: credentials,
      requests: requests,
      results: results)

    let importantCredentials = credentials.filter { $0.sensitiveDomain }
    let importantReport = PasswordHealthReport.ComputeReport(
      credentials: importantCredentials,
      requests: requestsImportant,
      results: results)

    let score: Int?
    if allReport.totalCount >= PasswordHealthAnalyzer.scoreMinimumNumberOfCredentials {
      score = Int(
        round(
          request.score(
            forCorruptedCount: allReport.corruptedCount,
            importantCorruptedCount: importantReport.corruptedCount, total: allReport.totalCount)))
    } else {
      score = nil
    }

    let report = PasswordHealthReport(
      score: score, allCredentialsReport: allReport, importantCredentialsReport: importantReport)

    return report
  }

  nonisolated func report(for request: ReportRequest) -> AnyPublisher<PasswordHealthReport, Never> {
    notificationManager
      .publisher(for: .securityDashboardDidRefresh)
      .asyncMap { _ in
        await self.report(for: request)
      }
      .eraseToAnyPublisher()
  }
}

extension PasswordHealthAnalyzer {
  public func reusedCount(for password: Password) async -> Int {
    let credentials = await self.credentialsCache.safeNotExcludedCredentials
    let passwords = credentials.map({ $0.password })
    return await self.passwordsSimilarityOperation.run {
      $0.similarityCount(of: password, in: passwords)
    }
  }
}

extension PasswordHealthAnalyzer {
  public func reusedPasswords() async -> [Password] {
    let result = await compute(for: .reused)
    return result.elements.map { $0.password }
  }
}

extension PasswordHealthAnalyzer {

  public enum Title {
    case compromised
    case `weak`
    case reused
    case checked
    case trivialCredentials
    case mediumCredentials
    case weakCredentials
    case breach(SecurityDashboardBreach)
    case reusedGroup(Int)
  }
}
