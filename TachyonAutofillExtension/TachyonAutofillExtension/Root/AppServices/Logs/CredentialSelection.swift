import Foundation
import CorePersonalData
import AuthenticationServices
import CoreUserTracking

struct CredentialSelection {
    let credential: Credential
    let selectionOrigin: Origin
    let visitedWebsite: String?

    enum Origin {
        case quickTypeBar
        case credentialsList
        case newCredential
    }
}
