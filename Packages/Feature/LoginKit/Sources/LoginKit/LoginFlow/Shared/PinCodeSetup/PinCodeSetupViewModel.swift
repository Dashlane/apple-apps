import CoreKeychain
import CoreTypes
import Foundation

class PinCodeSetupViewModel: ObservableObject {

  enum CompletionType {
    case completed(String)
    case cancel
  }

  @Published
  var choosePinCode: Bool = false

  private let login: Login
  let completion: (CompletionType) -> Void

  init(login: Login, completion: @escaping (PinCodeSetupViewModel.CompletionType) -> Void) {
    self.login = login
    self.completion = completion
  }

  func makePinCodeViewModel() -> PinCodeSelectionViewModel {
    PinCodeSelectionViewModel { [weak self] pin in
      guard let self else { return }
      self.choosePinCode = false
      guard let pin else { return }
      self.enablePincode(pin)
    }
  }

  func enablePincode(_ code: String) {
    completion(.completed(code))
  }

  func cancel() {
    completion(.cancel)
  }
}
