import Foundation

protocol FilterAlgorithm {
    	static func compute(_ credentials: [SecurityDashboardCredential], using services: PasswordHealthAnalyzerServices) async -> PasswordHealthResult
}

extension FilterAlgorithm {
    static func filter(for credentials: [SecurityDashboardCredential], bySpaceId spaceId: String?, sensitiveOnly: Bool) -> [SecurityDashboardCredential] {
        return credentials.filter { credential in
            if sensitiveOnly == true, credential.sensitiveDomain == false {
                return false
            }

            if let spaceId = spaceId, credential.spaceId != spaceId {
                return false
            }

            return true
        }
    }
}

extension PasswordHealthAnalyzer.Request.Filter {
    var algorithm: FilterAlgorithm.Type {
        switch self {
        case .compromised:
            return CompromisedFilterAlgorithm.self

        case .reused:
            return ReusedFilterAlgorithm.self

        case .weak:
            return WeakFilterAlgorithm.self

        case .checked:
            return CheckedFilterAlgorithm.self
        }
    }
}

struct PasswordHealthAnalyzerServices {
    let passwordsSimilarityOperation: PasswordsSimilarityOperation
}
