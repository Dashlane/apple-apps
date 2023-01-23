import Foundation
import CoreSession
import CoreKeychain
import CoreUserTracking
import SwiftTreats
import LocalAuthentication
import Combine
import DashTypes
import CoreLocalization
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public protocol PinCodeAndBiometryViewModel: ObservableObject {
    var pincode: String { get set }
    var login: Login { get }
    var attempts: Int { get }
    var biometricAuthenticationInProgress: Bool { get }
    var loading: Bool { get }
    func cancel()
    func logOnAppear()
}

@MainActor
public class LockPinCodeAndBiometryViewModel: PinCodeAndBiometryViewModel {

    public enum State {
        case biometricAuthenticationRequested
        case biometricAuthenticationFailure
        case biometricAuthenticationSuccess
        case pinRequested
        case pinIncorrect
        case pinCorrect
    }

    public enum Completion {
        case biometricAuthenticationSuccess
        case pinAuthenticationSuccess
        case failure
        case cancel
    }

    public let login: Login

    @Published
    public var pincode: String = "" {
        didSet {
            if pincode.count == 4 {
                Task {
                    await self.validatePinCode()
                }
            }
        }
    }

    @Published
    public var attempts: Int = 0

    @Published
    private var state: State {
        didSet {
                        if state == .biometricAuthenticationFailure {
                self.log(.biometricAuthenticationFailure)
                self.state = .pinRequested
            }
        }
    }

    @Published
    public var loading: Bool = true

    @Published
    public var biometricAuthenticationInProgress: Bool = false

    let usageLogService: LoginUsageLogServiceProtocol
    let masterKey: CoreKeychain.MasterKey
    let savedPincode: String
    let unlocker: UnlockSessionHandler
    let installerLogService: InstallerLogServiceProtocol
    let completion: (Completion) -> Void
    let activityReporter: ActivityReporterProtocol
    let biometryType: Biometry?

    private let pinCodeAttempts: PinCodeAttempts
    private var cancellables: Set<AnyCancellable> = []

        private let verificationMode: Definition.VerificationMode
    private let isBackupCode: Bool?
    private let reason: Definition.Reason

    public init(login: Login,
                verificationMode: Definition.VerificationMode = Definition.VerificationMode.none,
                isBackupCode: Bool? = nil,
                reason: Definition.Reason,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                pinCodeAttempts: PinCodeAttempts,
                masterKey: CoreKeychain.MasterKey,
                pincode: String = "",
                unlocker: UnlockSessionHandler,
                biometryType: Biometry? = nil,
                installerLogService: InstallerLogServiceProtocol,
                completion: @escaping (Completion) -> Void) {
        self.login = login
        self.reason = reason
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.pinCodeAttempts = pinCodeAttempts
        self.masterKey = masterKey
        self.savedPincode = pincode
        self.installerLogService = installerLogService
        self.unlocker = unlocker
        self.completion = completion
        self.biometryType = biometryType

        if let biometryType = biometryType {
            state = .biometricAuthenticationRequested
            Task {
                await authenticate(using: biometryType)
            }
        } else {
            state = .pinRequested
        }

        $state.map {
            switch $0 {
            case .biometricAuthenticationRequested, .biometricAuthenticationSuccess, .biometricAuthenticationFailure:
                return true
            default:
                return false
            }
        }.assign(to: &$biometricAuthenticationInProgress)

        $state.map {
            switch $0 {
            case .biometricAuthenticationSuccess:
                return true
            default:
                return false
            }
        }.assign(to: &$loading)

        $state
            .sink { [weak self] in
                self?.log($0)
            }
            .store(in: &cancellables)

        self.pinCodeAttempts.countPublisher.assign(to: &$attempts)

        #if canImport(UIKit)
                        NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
        #endif
    }

    private func refresh() {
        if pinCodeAttempts.tooManyAttempts {
            completion(.failure)
        }
    }

    public func validatePinCode() async {
        guard savedPincode == pincode else {
            state = .pinIncorrect
            pinCodeAttempts.addNewAttempt()
            pincode = ""
            if pinCodeAttempts.tooManyAttempts {
                completion(.failure)
            }
            return
        }
        state = .pinCorrect
        pinCodeAttempts.removeAll()
        usageLogService.startLoginTimer(from: .pinCode)
        do {
            try await unlocker.validateMasterKey(masterKey)
            self.completion(.pinAuthenticationSuccess)
        } catch {
            self.usageLogService.resetTimer(.login)
            self.completion(.failure)
        }
    }

    public func cancel() {
        self.completion(.cancel)
    }

    public func authenticate(using biometryType: Biometry) async {
        self.usageLogService.startLoginTimer(from: biometryType)
        do {
            try await Biometry.authenticate(reasonTitle: L10n.Core.unlockDashlane, fallbackTitle: L10n.Core.enterPasscode)
            do {
                try await self.unlocker.validateMasterKey(self.masterKey)
                self.state = .biometricAuthenticationSuccess
                self.completion(.biometricAuthenticationSuccess)
            } catch {
                self.usageLogService.resetTimer(.login)
                self.state = .pinRequested
                self.completion(.failure)
            }
        } catch {
            self.state = .biometricAuthenticationFailure
        }
    }

    public func log(_ state: State?) {
        guard let state = state else {
            return
        }

        switch state {
        case .biometricAuthenticationRequested:
            activityReporter.report(UserEvent.AskAuthentication(mode: .biometric,
                                                                reason: reason,
                                                                verificationMode: verificationMode))
        case .biometricAuthenticationFailure:
            activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                    mode: .biometric,
                                                    status: .errorWrongBiometric,
                                                    verificationMode: verificationMode))
            guard self.biometryType == .touchId else { return }
            self.installerLogService.login.logTouchId(success: false)
        case .biometricAuthenticationSuccess:
            guard self.biometryType == .touchId else { return }
            self.installerLogService.login.logTouchId(success: true)
        case .pinRequested:
            activityReporter.report(UserEvent.AskAuthentication(mode: .pin,
                                                                reason: reason,
                                                                verificationMode: verificationMode))
        case .pinIncorrect:
            installerLogService.login.logWrongPinCode()
            activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                    mode: .pin,
                                                    status: .errorWrongPin,
                                                    verificationMode: verificationMode))
        case .pinCorrect:
            installerLogService.login.logPinCodeOk()
        }
    }

    public func logOnAppear() {
        activityReporter.reportPageShown(.unlockPin)
    }
}
