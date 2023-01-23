import Foundation
import SwiftUI
import Combine
import DashlaneCrypto
import DashTypes
import CoreSession
import LocalAuthentication
import CoreUserTracking
import DashlaneAppKit
import LoginKit

protocol AccessControlProtocol {
    func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher
}

typealias AccessControlPublisher = AnyPublisher<Bool, Never>

enum AccessControlReason {
    case unlockItem
    case lockOnExit

    var logReason: Definition.Reason {
        switch self {
        case .unlockItem:
            return .unlockItem
        case .lockOnExit:
            return .editSettings
        }
    }

    var promptMessage: String {
        switch self {
        case .unlockItem:
            return L10n.Localizable.itemAccessUnlockPrompt
        case .lockOnExit:
            return L10n.Localizable.kwLockOnExit
        }
    }
}

extension AccessControlProtocol {
    func requestAccess() -> AccessControlPublisher {
        return requestAccess(forReason: .unlockItem)
    }

    func requestAccess(_ completion: @escaping (Bool) -> Void) {
        requestAccess().sinkOnce(receiveValue: completion)
    }

    func requestAccess(forReason reason: AccessControlReason,
                       _ completion: @escaping (Bool) -> Void) {
        requestAccess(forReason: reason).sinkOnce(receiveValue: completion)
    }
}

public struct FakeAccessControl: AccessControlProtocol {
    let accept: Bool
    func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
        return Just(accept).eraseToAnyPublisher()
    }
}

protocol AccessControlViewModelProtocol: ObservableObject {
    var pendingAccess: AccessControl.PendingAccess? { get set }
    func cancel()
}

class AccessControl: AccessControlViewModelProtocol, AccessControlProtocol {
    struct PendingAccess {
        fileprivate(set) var mode: Mode
        let reason: String
        var error: AuthenticationError?

        fileprivate let publisher = PassthroughSubject<Bool, Never>()
    }

        enum AuthenticationError: String, Swift.Error, Identifiable {
        var id: String {
            return rawValue
        }

        case wrongMasterPassword
        case wrongPin
    }

    struct CancelledError: Error {

    }

    enum Mode {
        case masterPassword((String) -> Void)
        case biometry(() -> Void)
        case pin((String) -> Void)
        case rememberMasterPassword(() -> Void)

        var isPin: Bool {
            if case .pin = self {
                return true
            } else {
                return false
            }
        }
    }

        let secureLockProvider: SecureLockProvider
    let session: Session
    let teamSpaceService: TeamSpacesService
    let activityReporter: ActivityReporterProtocol

    @Published
    var pendingAccess: PendingAccess?

        init(session: Session, teamSpaceService: TeamSpacesService, secureLockProvider: SecureLockProvider, activityReporter: ActivityReporterProtocol) {
        self.session = session
        self.secureLockProvider = secureLockProvider
        self.teamSpaceService = teamSpaceService
        self.activityReporter = activityReporter
    }

        private func makePendingAccess(reason: AccessControlReason) -> PendingAccess {

        let secureLockMode = secureLockProvider.secureLockMode()
        let accessMode: Mode

        switch secureLockMode {
        case .biometry:
            accessMode = makePendingAccessForBiometry(for: reason, fallback: makePendingAccessForMasterPassword(reason: reason))
        case .pincode(let code, _, _):
            accessMode = makePendingAccessForPin(code: code, reason: reason)
        case .biometryAndPincode(_, let code, _, _):
            accessMode = makePendingAccessForBiometry(for: reason, fallback: makePendingAccessForPin(code: code, reason: reason))
        case .masterKey, .rememberMasterPassword:
            accessMode = makePendingAccessForMasterPassword(reason: reason)
        }
        return PendingAccess(mode: accessMode, reason: reason.promptMessage)
    }

    private func makePendingAccessForBiometry(for reason: AccessControlReason,
                                              fallback: Mode) -> Mode {
        logAskAuthentication(for: .biometric, reason: reason.logReason)
        return .biometry { [weak self] in
                        DispatchQueue.main.async {
                self?.validateBiometry(forReason: reason, fallbackTitle: fallback.isPin ? L10n.Localizable.enterPasscode : nil) {
                    self?.pendingAccess?.mode = fallback
                }
            }
        }
    }

    private func makePendingAccessForPin(code: String, reason: AccessControlReason) -> Mode {
        logAskAuthentication(for: .pin, reason: reason.logReason)
        return .pin { [weak self] enteredPin in
            guard code == enteredPin else {
                self?.pendingAccess?.error = .wrongPin
                return
            }
            self?.approveAccess()
        }
    }

    private func makePendingAccessForMasterPassword(reason: AccessControlReason) -> Mode {
        logAskAuthentication(for: .masterPassword, reason: reason.logReason)
        return .masterPassword({ [weak self] password in
            self?.validateMasterPassword(password)
        })
    }

        func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
        guard !teamSpaceService.isSSOUser else {
            return Just(true).eraseToAnyPublisher()
        }

        let pendingAccess = makePendingAccess(reason: reason)
        self.pendingAccess = pendingAccess
        return pendingAccess.publisher.eraseToAnyPublisher()
    }

    func cancel() {
        unapproveAccess()
    }

    private func approveAccess() {
        self.pendingAccess?.publisher.send(true)
        self.pendingAccess = nil
    }

    private func unapproveAccess() {
        self.pendingAccess?.publisher.send(false)
        self.pendingAccess = nil
    }

        private func validateBiometry(forReason reason: AccessControlReason, fallbackTitle: String? = nil, fallback: @escaping () -> Void) {
        let context = LAContext()
        fallbackTitle.map { context.localizedFallbackTitle = $0 }
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason.promptMessage) { (success, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if success {
                    self.approveAccess()
                    return
                }

                if error != nil {
                    fallback()
                }
            }
        }
    }

    private func validateMasterPassword(_ password: String) {
        guard let masterPassword = self.session.configuration.masterKey.masterPassword, password == masterPassword else {
            self.pendingAccess?.error = .wrongMasterPassword
            return
        }
        self.approveAccess()
    }

    private func logAskAuthentication(for mode: Definition.Mode,
                                      reason: Definition.Reason) {
        activityReporter.report(UserEvent.AskAuthentication(mode: mode, reason: reason))
    }
}
