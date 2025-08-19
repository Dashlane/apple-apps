import CoreKeychain
import CoreSession
import Foundation
import UserTrackingFoundation

extension LocalLoginFlowViewModel {
  internal func makeLocalLoginUnlockViewModel(userUnlockInfo: UserUnlockInfo)
    -> LocalLoginUnlockViewModel
  {
    localLoginUnlockViewModelFactory.make(
      login: login,
      context: LoginUnlockContext(
        verificationMode: .none,
        isBackupCode: userUnlockInfo.isBackupCode,
        origin: .login,
        localLoginContext: context),
      userSettings: userSettings,
      resetMasterPasswordService: resetMasterPasswordService,
      localLoginUnlockStateMachine: stateMachine.makeLocalLoginUnlockStateMachine(
        userUnlockInfo: userUnlockInfo,
        attempts: PinCodeAttempts(internalStore: userSettings.internalStore))
    ) { [weak self] completion in
      guard let self = self else { return }
      Task {
        switch completion {
        case .logout:
          await self.perform(.logout)
        case let .authenticated(localConfig):
          await self.perform(.completed(localConfig))
        case .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }
}
