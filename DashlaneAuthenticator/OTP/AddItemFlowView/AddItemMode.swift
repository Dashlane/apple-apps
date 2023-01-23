import Foundation
import CorePersonalData

enum AddItemMode {
    case paired(SessionCredentialsProvider)
    case standalone
}

extension AddItemMode {
    enum MatchingAction {
                case notNeeded
                case linkToCredential(Credential)
                case showList(matchingCredentials: [Credential], provider: SessionCredentialsProvider)
    }
    
    func matchingAction(forWebsite website: String) async -> MatchingAction {
        guard case let .paired(provider) = self else {
                        return .notNeeded
        }
        
        let matchingCredentials = await provider.matchingCredentialsFor(website)
        
                                guard matchingCredentials.count >= 2 else {
                        if let credential = matchingCredentials.first {
                return .linkToCredential(credential)
            } else {
                return .notNeeded
            }
        }
        

        return .showList(matchingCredentials: matchingCredentials, provider: provider)
    }
}
