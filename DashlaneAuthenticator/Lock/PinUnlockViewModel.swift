import Combine
import CoreKeychain
import CoreSession
import DashTypes
import Foundation
import LoginKit
import SwiftTreats
import UIKit

@MainActor
class PinUnlockViewModel: ObservableObject {
  let login: Login
  let completion: (PairedServicesContainer) -> Void
  let pin: String
  let pinCodeAttempts: PinCodeAttempts
  let masterKey: CoreKeychain.MasterKey
  let validateMasterKey: (CoreKeychain.MasterKey) async throws -> PairedServicesContainer

  @Published
  var showError: Bool

  @Published
  var enteredPincode: String = "" {
    didSet {
      errorMessage = ""
      if enteredPincode.count == pinCodeLength {
        _ = Task {
          await validate()
        }
      }
    }
  }

  @Published
  var errorMessage: String = ""

  @Published
  var attempts: Int = 1

  var pinCodeLength: Int {
    pin.count
  }

  private var cancellables: Set<AnyCancellable> = []

  init(
    login: Login,
    pin: String,
    pinCodeAttempts: PinCodeAttempts,
    masterKey: CoreKeychain.MasterKey,
    validateMasterKey: @escaping (CoreKeychain.MasterKey) async throws -> PairedServicesContainer,
    completion: @escaping (PairedServicesContainer) -> Void
  ) {
    self.login = login
    self.validateMasterKey = validateMasterKey
    self.pin = pin
    self.pinCodeAttempts = pinCodeAttempts
    self.showError = pinCodeAttempts.tooManyAttempts
    self.masterKey = masterKey
    self.completion = completion

    self.pinCodeAttempts.countPublisher.assign(to: &$attempts)
    self.pinCodeAttempts.tooManyAttemptsPublisher.assign(to: &$showError)

    NotificationCenter.default.publisher(
      for: UIApplication.applicationWillEnterForegroundNotification
    )
    .sink { [weak self] _ in self?.refresh() }
    .store(in: &cancellables)
  }

  private func refresh() {
    showError = pinCodeAttempts.tooManyAttempts
    if showError {
      errorMessage =
        pinCodeAttempts.count == 1
        ? L10n.Localizable.pincodeError : L10n.Localizable.pincodeAttemptsLeftError(3 - attempts)
    }
  }

  func validate() async {
    if enteredPincode == pin {
      do {
        let result = try await validateMasterKey(masterKey)
        completion(result)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.pinCodeAttempts.removeAll()
        }
      } catch {
        showError = true
        enteredPincode = ""
      }
    } else {
      pinCodeAttempts.addNewAttempt()
      enteredPincode = ""
      errorMessage =
        pinCodeAttempts.count == 1
        ? L10n.Localizable.pincodeError : L10n.Localizable.pincodeAttemptsLeftError(3 - attempts)
    }
  }
}
