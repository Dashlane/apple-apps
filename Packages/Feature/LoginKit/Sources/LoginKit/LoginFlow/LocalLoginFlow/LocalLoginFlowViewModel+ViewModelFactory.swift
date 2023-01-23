import Foundation
import CoreSession
import CoreKeychain
import CoreUserTracking

extension LocalLoginFlowViewModel {
    internal func makeTotpViewModel(validator: ThirdPartyOTPLocalLoginValidator, hasLock: Bool) -> TOTPLocalLoginViewModel {
        TOTPLocalLoginViewModel(validator: validator,
                                usageLogService: loginUsageLogService,
                                activityReporter: activityReporter,
                                loginInstallerLogger: installerLogService.login,
                                recover2faWebService: Recover2FAWebService(webService: nonAuthenticatedUKIBasedWebService, login: validator.login),
                                keychainService: keychainService,
                                hasLock: hasLock,
                                context: context) { [weak self] completionType in
            guard let self = self else { return }
            switch completionType {
            case let .success(isBackupCode):
                self.isBackupCode = isBackupCode
                self.updateStep()
            case .error(let error):
                self.completion(.failure(error))
            }
        }
    }
    
    internal func makeLocalLoginUnlockViewModel(secureLockMode: SecureLockMode,
                                                handler: UnlockSessionHandler,
                                                unlockType: UnlockType,
                                                context: LocalLoginFlowContext) -> LocalLoginUnlockViewModel {
        
        LocalLoginUnlockViewModel(login: localLoginHandler.login,
                                  verificationMode: verificationMode,
                                  isBackupCode: isBackupCode,
                                  biometry: secureLockMode.biometryType,
                                  usageLogService: loginUsageLogService,
                                  activityReporter: activityReporter,
                                  localLoginHandler: localLoginHandler,
                                  unlocker: handler,
                                  keychainService: keychainService,
                                  userSettings: userSettings,
                                  resetMasterPasswordService: resetMasterPasswordService,
                                  installerLogService: installerLogService,
                                  isSSOUser: isPartOfSSOCompany,
                                  secureLockMode: secureLockMode,
                                  unlockType: unlockType,
                                  context: context) { [weak self] completion in
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
        case .masterPassword, .resetMasterPassword:
            return .masterPassword
        case .biometry, .rememberMasterPassword:
            return .biometric
        case .pincode:
            return .pin
        }
    }
}

