import Foundation

struct WeakFilterAlgorithm: FilterAlgorithm {

                public struct Result: PasswordHealthResult {

        public var credentials: [SecurityDashboardCredential] = []

        public var elements: [SecurityDashboardCredential]

        public var count: Int {
            return elements.count
        }

        init(credentials: [SecurityDashboardCredential] = [], elements: [SecurityDashboardCredential]) {
            self.credentials = credentials
            self.elements = elements
        }

        public mutating func filter(bySpacedId spaceId: String?, sensitiveOnly: Bool) {
            elements = WeakFilterAlgorithm.filter(for: elements, bySpaceId: spaceId, sensitiveOnly: sensitiveOnly)
        }
    }

    	static func compute(_ credentialsToUse: [SecurityDashboardCredential], using services: PasswordHealthAnalyzerServices) -> PasswordHealthResult {
        let elements = credentialsToUse.filter { [.veryUnsafe, .unsafe].contains($0.strength) }
        return Result(credentials: credentialsToUse, elements: elements)
    }
}
