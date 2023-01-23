import Foundation
import CoreSettings
import DashTypes
import DashlaneCrypto
import CoreKeychain
import Combine



public class ResetMasterPasswordService: ResetMasterPasswordServiceProtocol {

    enum ResetMasterPasswordServiceError: Error {
        case masterPasswordUnavailable
        case resetContainerCreationError
    }

    private let resetContainerManager: ResetContainerKeychainManager
    private let settings: KeyedSettings<ResetMasterPasswordSettingsKey>
    private let keychainService: AuthenticationKeychainServiceProtocol
    private var subscriptions = Set<AnyCancellable>()

                    public init(login: Login,
                settings: LocalSettingsStore,
                keychainService: AuthenticationKeychainServiceProtocol) {
        self.settings = settings.keyed(by: ResetMasterPasswordSettingsKey.self)
        self.resetContainerManager = keychainService.makeResetContainerKeychainManager(userLogin: login.email)
        self.keychainService = keychainService
        self.keychainService.masterKeyStatusChanged.sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .update(let masterKey):
                if case let .masterPassword(masterPassword) = masterKey, self.settings.activated == true {
                    try? self.update(masterPassword: masterPassword)
                }
            case .removal:
                try? self.removeResetContainer()
            }
        }.store(in: &subscriptions)
    }

    public var isActive: Bool {
        let resetContainerStatus = try? resetContainerManager.checkStatus()
        guard let status = resetContainerStatus else {
            assertionFailure("We should always be able to check the reset container status.")
            return false
        }
        return status == .available && settings.activated
    }

    public var needsReactivation: Bool {
        return self.isActive == false && settings.activated
    }

    public func activationStatusPublisher() -> AnyPublisher<Bool, Never> {
        self.settings.settingsChangePublisher(key: .activated)
            .map { [weak self] in
                self?.isActive
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    public func update(masterPassword: String) throws {
        try resetContainerManager.store(masterPassword)
    }

    public func activate(using masterPassword: String) throws {
         do {
            try resetContainerManager.store(masterPassword)
            settings.activated = true
        } catch {
            settings.activated = false
            throw ResetMasterPasswordServiceError.resetContainerCreationError
        }
    }

    public func deactivate() throws {
        settings.activated = false
        try removeResetContainer()
    }

    public func storedMasterPassword() throws -> String {
        return try resetContainerManager.get().masterPassword
    }

    private func removeResetContainer() throws {
        do {
            try resetContainerManager.remove()
        } catch let error as CoreKeychain.KeychainError where error == .itemNotFound {
                    }
    }
}

enum ResetMasterPasswordSettingsKey: String, LocalSettingsKey {
    case activated = "ResetMasterPasswordWithBiometricsActivated"

    var type: Any.Type {
        return Bool.self
    }
}

extension KeyedSettings where Key == ResetMasterPasswordSettingsKey {
    var activated: Bool {
        get { return self[Key.activated] ?? false }
        nonmutating set { self[Key.activated] = newValue }
    }
}
