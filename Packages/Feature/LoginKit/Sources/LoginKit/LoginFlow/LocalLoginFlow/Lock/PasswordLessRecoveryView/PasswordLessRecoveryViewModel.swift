import CoreSession
import CoreSettings
import DashTypes
import Foundation

@MainActor
public class PasswordLessRecoveryViewModel: ObservableObject, LoginKitServicesInjecting {
  public enum CompletionResult {
    case logout
    case cancel
  }

  let login: Login
  let recoverFromFailure: Bool
  let completion: (CompletionResult) -> Void

  public init(
    login: Login,
    recoverFromFailure: Bool,
    completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void
  ) {
    self.login = login
    self.recoverFromFailure = recoverFromFailure
    self.completion = completion
  }

  func logout() {
    completion(.logout)
  }

  func cancel() {
    completion(.cancel)
  }

  func makeAccountRecoveryKeyLoginFlowModel() -> AccountRecoveryKeyLoginFlowModel {
    fatalError()
  }

  func makeDeviceToDeviceLoginFlowViewModel() -> DeviceTransferQRCodeFlowModel {
    fatalError()
  }
}

extension PasswordLessRecoveryViewModel {
  static func mock(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel {
    PasswordLessRecoveryViewModel(login: Login("_"), recoverFromFailure: recoverFromFailure) { _ in

    }
  }
}
