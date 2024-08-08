import Combine
import DashTypes
import Foundation

class PassphraseInputViewModel: ObservableObject {
  let passphrase: [String]
  let deviceName: String
  let indexField = Int.random(in: 0...4)
  let completion: (CompletionType) -> Void

  enum CompletionType {
    case completed
    case intro
    case cancel
  }

  @Published
  var inputText: String = "" {
    didSet {
      showNoMatchError = false
    }
  }

  @Published
  var showNoMatchError: Bool

  @Published
  var showError: Bool = false

  var errorCount = 0

  @Published
  var error: AddNewDeviceViewModel.Error?

  init(
    passphrase: [String], deviceName: String, showNoMatchError: Bool = false,
    completion: @escaping (PassphraseInputViewModel.CompletionType) -> Void
  ) {
    self.passphrase = passphrase
    self.showNoMatchError = showNoMatchError
    self.deviceName = deviceName
    self.completion = completion
  }

  func validate() {
    guard passphrase[indexField] != inputText else {
      showNoMatchError = false
      completion(.completed)
      return
    }
    showNoMatchError = true
    errorCount += 1
    if errorCount > 2 {
      showError = true
    }
  }

  func cancel() {
    completion(.intro)
  }

  func gotoSettings() {
    completion(.cancel)
  }
}
