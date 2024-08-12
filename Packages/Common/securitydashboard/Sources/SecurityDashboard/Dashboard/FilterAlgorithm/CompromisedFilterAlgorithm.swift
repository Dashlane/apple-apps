import Foundation

public typealias BreachPair = (breach: SecurityDashboardBreach, indices: [Int])

public struct CompromisedFilterAlgorithm: FilterAlgorithm {
  public struct Result: PasswordHealthResult {

    public var credentials: [SecurityDashboardCredential] = []

    public var elements: [SecurityDashboardCredential]

    public var count: Int {
      return elements.count
    }

    public init(credentials: [SecurityDashboardCredential], elements: [SecurityDashboardCredential])
    {
      self.credentials = credentials
      self.elements = elements
    }

    public mutating func filter(bySpacedId spaceId: String?, sensitiveOnly: Bool) {
      elements = CompromisedFilterAlgorithm.filter(
        for: elements, bySpaceId: spaceId, sensitiveOnly: sensitiveOnly)
    }
  }

  static func compute(
    _ credentialsToUse: [SecurityDashboardCredential],
    using services: PasswordHealthAnalyzerServices
  ) -> PasswordHealthResult {
    let elements = credentialsToUse.filter { !$0.compromisedIn.isEmpty }
    return Result(credentials: credentialsToUse, elements: elements)
  }
}
