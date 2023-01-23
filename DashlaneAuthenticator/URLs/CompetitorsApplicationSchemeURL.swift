import Foundation
import CoreUserTracking

enum CompetitorsApplicationSchemeURL: String, CaseIterable {
    case authy = "authy:///"
    case duo = "duo:///"
    case googleAuthenticator = "googleauthenticator:///"
    case lastPassAuthenticator = "lastpassmfa:///"
    case microsoftAuthenticator = "microsoft-authenticator:///"
    
    var url: URL {
                URL(string: self.rawValue)!
    }
}
