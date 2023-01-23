import Foundation
import CoreSession
import CoreKeychain
import CoreUserTracking

extension RemoteLoginFlowViewModel {
    internal func makeTotpViewModel(validator: ThirdPartyOTPDeviceRegistrationValidator) -> TOTPRemoteLoginViewModel {
        totpFactory.make(validator: validator,
                         recover2faWebService: Recover2FAWebService(webService: nonAuthenticatedUKIBasedWebService, login: validator.login)) { [weak self] completionType in
            guard let self = self else { return }
            switch completionType {
            case let .success(isBackupCode):
                self.verificationMode = .otp1
                self.isBackupCode = isBackupCode
                self.updateStep()
            case .error(let error):
                self.completion(.failure(error))
            }
        }
    }

    internal func makeTokenViewModel(validator: TokenDeviceRegistrationValidator) -> TokenViewModel {
        tokenFactory.make(tokenPublisher: tokenPublisher,
                          validator: validator) { [weak self] completionType in
            guard let self = self else {
                return
            }
            switch completionType {
            case .success:
                self.verificationMode = .emailToken
                self.updateStep()
            case .error(let error):
                self.completion(.failure(error))
            }
        }
    }

    internal func makeAuthenticatorPushViewModel(validator: TokenDeviceRegistrationValidator) -> AuthenticatorPushViewModel {
        authenticatorFactory.make(login: validator.login,
                                  validator: validator.validateUsingAuthenticatorPush) { [weak self] completionType in
            guard let self = self else {
                return
            }
            switch completionType {
            case .success:
                self.verificationMode = .authenticatorApp
                self.updateStep()
            case .error(let error):
                self.completion(.failure(error))
            case .token:
                self.steps.append(.token(self.makeTokenViewModel(validator: validator)))
            }
        }
    }

    internal func makeMasterPasswordView(loginKeys: LoginKeys) -> MasterPasswordRemoteViewModel {
        masterPasswordFactory.make(login: remoteLoginHandler.login,
                                   verificationMode: verificationMode,
                                   isBackupCode: isBackupCode,
                                   isExtension: false,
                                   validator: remoteLoginHandler,
                                   keys: loginKeys) { [weak self] in
            guard let self = self else {
                return
            }
            self.updateStep()
        }
    }

    internal func makeDeviceUnlinkLoadingViewModel(deviceUnlinker: DeviceUnlinker,
                                                   session: RemoteLoginSession) -> DeviceUnlinkingFlowViewModel {
        deviceUnlinkingFactory.make(deviceUnlinker: deviceUnlinker,
                                    login: session.login,
                                    session: session,
                                    purchasePlanFlowProvider: purchasePlanFlowProvider,
                                    sessionActivityReporterProvider: sessionActivityReporterProvider) { completion in
            switch completion {
            case .logout:
                self.completion(.failure(AccountError.deviceDeactivated))
            case let .load(loadActionPublisher):
                self.completion(.success(.deviceUnlinking(remoteLoginSession: session,
                                                          logInfo: self.logInfo,
                                                          remoteLoginHandler: self.remoteLoginHandler,
                                                          loadActionPublisher: loadActionPublisher)))
            }
        }
    }
}
