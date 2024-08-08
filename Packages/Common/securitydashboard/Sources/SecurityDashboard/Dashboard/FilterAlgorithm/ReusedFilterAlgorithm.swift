import Foundation

struct ReusedFilterAlgorithm: FilterAlgorithm {

  public struct Result: PasswordHealthResult {

    public var credentials: [SecurityDashboardCredential] = []

    public var elements: [SecurityDashboardCredential]

    public var count: Int {
      return elements.count
    }

    init(credentials: [SecurityDashboardCredential], elements: [SecurityDashboardCredential]) {
      self.elements = elements
      self.credentials = credentials
    }

    public mutating func filter(bySpacedId spaceId: String?, sensitiveOnly: Bool) {
      elements = ReusedFilterAlgorithm.filter(
        for: elements, bySpaceId: spaceId, sensitiveOnly: sensitiveOnly)
    }
  }

  static func compute(
    _ credentialsToUse: [SecurityDashboardCredential],
    using services: PasswordHealthAnalyzerServices
  ) async -> PasswordHealthResult {
    let groups = await services.passwordsSimilarityOperation.run { checker in
      checker.groupByIndices(credentialsToUse.map { $0.password })
    }
    let indices = Set(groups.map { $0.linkedIndices }.flatMap { $0 })
    let elements = credentialsToUse.enumerated().filter { indices.contains($0.offset) }.map {
      $0.element
    }
    let groupedPasswordsIndices = Result(credentials: credentialsToUse, elements: elements)
    return groupedPasswordsIndices
  }
}

extension ReusedFilterAlgorithm.Result: Equatable {
  static func == (lhs: ReusedFilterAlgorithm.Result, rhs: ReusedFilterAlgorithm.Result) -> Bool {
    return lhs.elements.map { $0.identifier } == rhs.elements.map { $0.identifier }
  }
}
