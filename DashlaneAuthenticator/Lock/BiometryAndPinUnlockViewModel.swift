import UIKit
import Combine
import Foundation
import SwiftTreats
import DashlaneAppKit
import CoreKeychain
import CoreSession
import DashTypes
import LocalAuthentication
import LoginKit

@MainActor
class BiometryAndPinUnlockViewModel: ObservableObject {
    enum State {
        case biometry
        case pin
    }
    
    @Published
    var state: State = .biometry
    
    @Published
    var showError = false
    
    @Published
    var errorMessage = ""
    
    @Published
    var showRetry = false
    
    @Published
    var enteredPincode: String = "" {
        didSet {
            errorMessage = ""
            if enteredPincode.count == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.validatePinCode()
                }
            }
        }
    }
    
    @Published
    var attempts: Int = 1
    
    @Published
    var inProgress = false
    
    let login: Login
    let biometryType: Biometry
    let pin: String
    let pinCodeAttempts: PinCodeAttempts
    let masterKey: CoreKeychain.MasterKey
    let validateMasterKey: (CoreKeychain.MasterKey) async throws -> PairedServicesContainer
    let completion: (PairedServicesContainer) -> Void

    private var cancellables: Set<AnyCancellable> = []

    init(login: Login,
         pin: String,
         pinCodeAttempts: PinCodeAttempts,
         masterKey: CoreKeychain.MasterKey,
         biometryType: Biometry,
         validateMasterKey: @escaping (CoreKeychain.MasterKey) async throws -> PairedServicesContainer,
         completion: @escaping (PairedServicesContainer) -> Void) {
        self.login = login
        self.biometryType = biometryType
        self.pin = pin
        self.pinCodeAttempts = pinCodeAttempts
        self.masterKey = masterKey
        self.validateMasterKey = validateMasterKey
        self.completion = completion

        self.pinCodeAttempts.countPublisher.assign(to: &$attempts)
        self.pinCodeAttempts.tooManyAttemptsPublisher.assign(to: &$showError)

                        NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    private func refresh() {
        showError = pinCodeAttempts.tooManyAttempts
        errorMessage = pinCodeAttempts.count == 1 ? L10n.Localizable.pincodeError : L10n.Localizable.pincodeAttemptsLeftError(3 - attempts)
    }
    
    func validateBiometry() async {
        showRetry = false
        inProgress = true
        do {
            try await Biometry.authenticate(reasonTitle: L10n.Localizable.lockedStateButtonTitle, fallbackTitle: L10n.Localizable.enterPasscode)
            let result = try await self.validateMasterKey(self.masterKey)
            self.completion(result)
        } catch {
            inProgress = false
            if let error = error as? LAError, error.code == LAError.systemCancel {
                showRetry = true
                return
            }
            self.state = .pin
        }
    }

    func validatePinCode() {
        inProgress = true
        if enteredPincode == pin {
            Task {
                do {
                    let result = try await validateMasterKey(masterKey)
                    pinCodeAttempts.removeAll()
                    completion(result)
                } catch {
                    showError = true
                    enteredPincode = ""
                }
            }
        } else {
            pinCodeAttempts.addNewAttempt()
            enteredPincode = ""
            errorMessage = pinCodeAttempts.count == 1 ? L10n.Localizable.pincodeError : L10n.Localizable.pincodeAttemptsLeftError(3 - attempts)
        }
        inProgress = false
    }
    
    func showPin() {
        showRetry = false
        state = .pin
    }
}
