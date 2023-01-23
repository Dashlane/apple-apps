import Foundation
import CoreSession
import Combine
import CoreUserTracking
import SwiftTreats
import DashTypes
import CoreKeychain
import CoreSettings

#if canImport(UIKit)
import UIKit
#endif

public protocol BiometryViewModelProtocol: ObservableObject {
    var login: Login {get}
    var biometryType: Biometry {get}
    var shouldDisplayProgress: Bool {get set}
    var canShowPrompt: Bool {get}
    var manualLockOrigin: Bool {get}
    func validate() async
    func cancel()
    func logAskAuthentication()
}

public class BiometryViewModel: BiometryViewModelProtocol {
    
    public let login: Login
    public let biometryType: Biometry
    let keychainService: AuthenticationKeychainServiceProtocol
    
    @Published
    public var shouldDisplayProgress: Bool = false
    
    @Published
    public var canShowPrompt: Bool = true
    
    let settings: LocalSettingsStore
    let unlocker: UnlockSessionHandler
    let installerLogService: InstallerLogServiceProtocol
    let usageLogService: LoginUsageLogServiceProtocol
    let completion: (_ isSuccess: Bool) -> Void
    private var cancellable: AnyCancellable?
    public let manualLockOrigin: Bool
    let activityReporter: ActivityReporterProtocol
    let context: LocalLoginFlowContext
        private let verificationMode: Definition.VerificationMode
    private let isBackupCode: Bool?
    private let reason: Definition.Reason

    public init(login: Login,
                verificationMode: Definition.VerificationMode = Definition.VerificationMode.none,
                isBackupCode: Bool? = nil,
                reason: Definition.Reason,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                settings: LocalSettingsStore,
                biometryType: Biometry,
                keychainService: AuthenticationKeychainServiceProtocol,
                unlocker: UnlockSessionHandler,
                installerLogService: InstallerLogServiceProtocol,
                manualLockOrigin: Bool = false,
                context: LocalLoginFlowContext,
                completion: @escaping (_ isSuccess: Bool) -> Void) {
        self.login = login
        self.verificationMode = verificationMode
        self.reason = reason
        self.isBackupCode = isBackupCode
        self.usageLogService = usageLogService
        self.context = context
        self.activityReporter = activityReporter
        self.biometryType = biometryType
        self.installerLogService = installerLogService
        self.keychainService = keychainService
        self.unlocker = unlocker
        self.completion = completion
        self.settings = settings
        self.manualLockOrigin = manualLockOrigin
        cancellable = NotificationCenter
            .default
            .didBecomeActiveNotificationPublisher()?
            .sink { [weak self] _ in
                    self?.validateBiometry()
            }
    }
    
    private func validateBiometry() {
        Task {
           await validate()
        }
    }
    
    @MainActor
    public func validate() async {
#if canImport(UIKit)
        if !context.isExtension {
            guard UIApplication.shared.applicationState == .active else { return }
        }
#endif
        
        guard canShowPrompt else {
            return
        }
        
        canShowPrompt = false
        
        guard let masterKey = try? await self.keychainService.masterKey(for: self.login) else {
            self.completion(false)
            self.logFailure()
            self.installerLogService.login.logTouchId(success: false)
            return
        }
        self.shouldDisplayProgress = true
        switch masterKey {
        case .masterPassword(let masterPassword):
            self.usageLogService.startLoginTimer(from: self.biometryType)
            do {
                try await self.unlocker.validateMasterKey(.masterPassword(masterPassword, serverKey: nil))
                completion(true)
                guard self.biometryType == .touchId else { return }
                self.installerLogService.login.logTouchId(success: true)
            } catch {
                self.usageLogService.resetTimer(.login)
                                try? self.keychainService.removeMasterKey(for: self.login)
                let lockSettings = self.settings.keyed(by: UserLockSettingsKey.self)
                lockSettings[.biometric] = false
                self.logFailure()
                completion(false)
                guard self.biometryType == .touchId else { return }
                self.installerLogService.login.logTouchId(success: false)
            }
        case .key(let key):
            do {
                try await self.unlocker.validateMasterKey(.ssoKey(key))
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    public func cancel() {
        self.completion(false)
    }
    
    public func logAskAuthentication() {
        activityReporter.report(UserEvent.AskAuthentication(mode: .biometric,
                                                            reason: reason,
                                                            verificationMode: verificationMode))
    }
    
    public func logFailure() {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .biometric,
                                                status: .errorWrongBiometric,
                                                verificationMode: verificationMode))
    }
}
