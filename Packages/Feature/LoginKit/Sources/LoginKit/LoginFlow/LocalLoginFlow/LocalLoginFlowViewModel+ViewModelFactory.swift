import Foundation
import CoreSession
import CoreKeychain
import CoreUserTracking

extension LocalLoginFlowViewModel {
    internal func makeLocalLoginUnlockViewModel(secureLockMode: SecureLockMode,
                                                handler: UnlockSessionHandler,
                                                unlockType: UnlockType,
                                                accountType: AccountType,
                                                context: LocalLoginFlowContext) -> LocalLoginUnlockViewModel {
        localLoginUnlockViewModelFactory.make(login: localLoginHandler.login,
                                              accountType: accountType,
                                              unlockType: unlockType,
                                              secureLockMode: secureLockMode,
                                              unlocker: handler,
                                              context: LoginUnlockContext(verificationMode: verificationMode,
                                                                          isBackupCode: isBackupCode,
                                                                          origin: .login,
                                                                          localLoginContext: context),
                                              userSettings: userSettings,
                                              resetMasterPasswordService: resetMasterPasswordService) { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .sso:
                Task {
                    await self.authenticationUsingSSO(with: handler)
                }
            case .logout:
                self.completion(.success(.logout))
            case .authenticated(let mode):
                self.lastSuccessfulAuthenticationMode = mode.authenticationLog
                self.updateStep(for: mode)
            }
        }
    }
}

private extension LocalLoginUnlockViewModel.Completion.AuthenticationMode {
    var authenticationLog: Definition.Mode {
        switch self {
        case .masterPassword, .resetMasterPassword, .accountRecovered:
            return .masterPassword
        case .biometry, .rememberMasterPassword:
            return .biometric
        case .pincode:
            return .pin
        }
    }
}
