import Foundation
import SwiftTreats
import DashlaneAppKit
import CoreKeychain
import CoreSession
import DashTypes

@MainActor
class BiometryUnlockViewModel: ObservableObject {
    let login: Login
    let biometryType: Biometry
    let completion: (PairedServicesContainer) -> Void

    @Published
    var showError = false

    @Published
    var showRetry = false

    @Published
    var inProgress = false

    let keychainService: AuthenticationKeychainServiceProtocol
    let validateMasterKey: (CoreKeychain.MasterKey) async throws -> PairedServicesContainer
    init(login: Login,
         biometryType: Biometry,
         keychainService: AuthenticationKeychainServiceProtocol,
         validateMasterKey: @escaping (CoreKeychain.MasterKey) async throws -> PairedServicesContainer,
         completion: @escaping (PairedServicesContainer) -> Void) {
        self.login = login
        self.biometryType = biometryType
        self.keychainService = keychainService
        self.validateMasterKey = validateMasterKey
        self.completion = completion
    }

    func validate() async {
        inProgress = true
        do {
            let masterKey = try await keychainService.masterKey(for: login)
            let result = try await validateMasterKey(masterKey)
            completion(result)
        } catch {
            inProgress = false
            if let error = error as? KeychainError, error == KeychainError.userFailedAuthCheck {
                showRetry = true
                return
            }
            showError = true
        }
    }
}
