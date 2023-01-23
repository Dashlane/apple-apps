import Foundation
import DashlaneAppKit
import CoreSettings

extension UserSettings {
    
    func isSaveCredentialDisabled(forDomain domain: String) -> Bool {
        let disabledWebsites: Set<String> = self[.safariIsSaveCredentialDisabled] ?? []
        return disabledWebsites.contains(domain)
    }
    
    func disableSaveCredential(forDomain domain: String) {
        var disabledWebsites: Set<String> = self[.safariIsSaveCredentialDisabled] ?? []
        disabledWebsites.insert(domain)
        self[.safariIsSaveCredentialDisabled] = disabledWebsites
    }
}
