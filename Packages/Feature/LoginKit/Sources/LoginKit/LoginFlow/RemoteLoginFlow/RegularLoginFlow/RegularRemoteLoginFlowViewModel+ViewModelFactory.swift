import CoreKeychain
import CoreSession
import CoreUserTracking
import Foundation

extension RegularRemoteLoginFlowViewModel {
  internal func makeMasterPasswordViewModel(loginKeys: LoginKeys) -> MasterPasswordRemoteViewModel {
    masterPasswordFactory.make(
      login: remoteLoginHandler.login,
      verificationMode: verificationMode,
      isBackupCode: isBackupCode,
      isExtension: false,
      validator: remoteLoginHandler,
      keys: loginKeys
    ) { [weak self] in
      guard let self = self else {
        return
      }
      self.updateStep()
    }
  }
}
