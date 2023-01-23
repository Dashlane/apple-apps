import Foundation
import CoreSession
import CoreKeychain
import DashlaneCrypto
import DashlaneAppKit
import CoreSettings

class LocalAuthenticationInformationService {
    
    let session: Session
    let premiumService: PremiumService
    let keychainService: AuthenticationKeychainService
    let settings: LocalSettingsStore
    let userSettings: UserSettings
    let userLockSettings: KeyedSettings<UserLockSettingsKey>
    
    private var lastAuthenticationDate = Date()
    
    enum LocalAuthentication {
        case masterPassword
        case biometric
        case pinCode
        case rememberMasterPassword
        case sso
    }
    
    init(session: Session,
        premiumService: PremiumService,
         settings: LocalSettingsStore,
         keychainService: AuthenticationKeychainService) {
        self.session = session
        self.premiumService = premiumService
        self.keychainService = keychainService
        self.settings = settings
        self.userSettings = settings.keyed(by: UserSettingsKey.self)
        self.userLockSettings = settings.keyed(by: UserLockSettingsKey.self)
    }
    
    func localAuthentication() -> LocalAuthentication {
        if userLockSettings[.biometric] == true {
            return .biometric
        } else if userLockSettings[.pinCode] == true {
            return .pinCode
        } else if userLockSettings[.rememberMasterPassword] == true {
            return .rememberMasterPassword
        } else if premiumService.status?.isSSOUser() ?? false {
            return .sso
        }
        
        return .masterPassword
    }
    
    func hasBiometry() -> Bool {
        return userLockSettings[.biometric] == true
    }
    
    func authorizeWithBiometry() async -> Bool {
        guard localAuthentication() == .biometric else {
            assertionFailure("No biometric set")
            return false
        }
        guard let _ = try? await keychainService.masterKey(for: session.login) else {
            return false
        }
        
        return true
    }
    
    func isMasterPasswordValid(autofillMasterPassword: String) -> Bool {
        switch session.configuration.masterKey {
        case let .masterPassword(masterPassword, _):
            if masterPassword == autofillMasterPassword { return true }
                        return HashedMasterPasswordVerification.is(hashedMasterPassword: autofillMasterPassword, equalTo: masterPassword)
        case .ssoKey:
            assertionFailure("Should not check masterpassword while we have SSO")
            return true
        }
    }
    
        func hasAuthorizationForSecureDataAccess() -> Bool {
        let fiveMinutes: TimeInterval = 5 * 60
        return Date() < lastAuthenticationDate.addingTimeInterval(fiveMinutes)
    }
    
    func resetAuthorization() {
        lastAuthenticationDate = Date()
    }
}
