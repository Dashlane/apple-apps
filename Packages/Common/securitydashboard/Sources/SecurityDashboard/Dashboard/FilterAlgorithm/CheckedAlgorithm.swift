import Foundation

struct CheckedFilterAlgorithm: FilterAlgorithm {

            public struct Result: PasswordHealthResult {

        public var credentials: [SecurityDashboardCredential] = []

        public var elements: [SecurityDashboardCredential]

        public var count: Int {
            return elements.count
        }

        public init(credentials: [SecurityDashboardCredential], elements: [SecurityDashboardCredential]) {
            self.credentials = credentials
            self.elements = elements
        }

        public mutating func filter(bySpacedId spaceId: String?, sensitiveOnly: Bool) {
            self.elements = CheckedFilterAlgorithm.filter(for: credentials, bySpaceId: spaceId, sensitiveOnly: sensitiveOnly)
        }
    }

        static func compute(_ credentialsToUse: [SecurityDashboardCredential], using services: PasswordHealthAnalyzerServices) -> PasswordHealthResult {
        return Result(credentials: credentialsToUse, elements: credentialsToUse)
    }
}

extension CheckedFilterAlgorithm.Result: Equatable {
    static func == (lhs: CheckedFilterAlgorithm.Result, rhs: CheckedFilterAlgorithm.Result) -> Bool {
        return lhs.elements.map { $0.identifier } == rhs.elements.map { $0.identifier }
    }
}
