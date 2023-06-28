import Foundation
import CoreSession
import DashTypes
import Combine
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreSettings
import AutofillKit

class DeviceInformationReporting {
    private let service: DeviceInfoService
    private let logger: Logger
    private let resetMasterPasswordService: ResetMasterPasswordService
    private let userSettings: UserSettings
    private let lockService: LockService
    private let autofillService: AutofillService
    private let session: Session

    private var cancellables = Set<AnyCancellable>()

    @Published
    private var secureLockMode: SecureLockMode

    @Published
    private var isMasterPasswordResetEnabled: Bool

    @Published
    private var isAutofillEnabled: Bool

    private var reportRequested = PassthroughSubject<Void, Never>()

    init(webservice: LegacyWebService,
         logger: Logger,
         resetMasterPasswordService: ResetMasterPasswordService,
         userSettings: UserSettings,
         lockService: LockService,
         autofillService: AutofillService,
         session: Session) {
        self.service = DeviceInfoService(webService: webservice)
        self.logger = logger
        self.resetMasterPasswordService = resetMasterPasswordService
        self.userSettings = userSettings
        self.session = session
        self.lockService = lockService
        self.autofillService = autofillService
        self.secureLockMode = lockService.secureLockMode()
        self.isMasterPasswordResetEnabled = resetMasterPasswordService.isActive
        self.isAutofillEnabled = autofillService.activationStatus == .enabled

        setupSubscriptions()
    }

    func report() {
        reportRequested.send()
    }

    private func setupSubscriptions() {
        resetMasterPasswordService.activationStatusPublisher()
            .assign(to: \.isMasterPasswordResetEnabled, on: self)
            .store(in: &cancellables)

        lockService.secureLockModePublisher()
            .assign(to: \.secureLockMode, on: self)
            .store(in: &cancellables)

        autofillService.$activationStatus
            .map {
                $0 == .enabled
            }
            .assign(to: \.isAutofillEnabled, on: self)
            .store(in: &cancellables)

        $secureLockMode
            .mapToVoid()
            .merge(with: $isMasterPasswordResetEnabled.mapToVoid(), $isAutofillEnabled.mapToVoid(), reportRequested)
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.sendUpdatedInformation()
            }
            .store(in: &cancellables)
    }

        func reportOnLogout() {
        sendUpdatedInformation(forLogout: true)
    }

    private func sendUpdatedInformation(forLogout userLogsOut: Bool = false) {
        let biometryInfo = "\(Device.currentBiometryDisplayableName) - \(secureLockMode.isBiometric.description)"
        let systemIntegrationStatus = userSettings[.advancedSystemIntegration] ?? false

                        let sessionCreatedOnFiber = session.configuration.keys.serverAuthentication.isSignatureBased

        var currentInformation = DeviceInformation(biometricIdentification: biometryInfo,
                                                   authenticationMethod: secureLockMode.description,
                                                   systemIntegration: systemIntegrationStatus.description,
                                                   mpResetBiometric: isMasterPasswordResetEnabled.description,
                                                   sessionOrigin: sessionCreatedOnFiber ? .fiber : .spiegel,
                                                   autofillEnabled: isAutofillEnabled.description)

        if userLogsOut {
            currentInformation = currentInformation.updatedForLogout()
        }

        service.updateInformation(with: currentInformation) { [weak self] result in
            switch result {
            case .success: self?.logger.debug("Successfully reported extra device information")
            case .failure: self?.logger.error("Failed to report extra device information")
            }
        }
    }
}

private struct DeviceInformation: DeviceInformationProtocol {

    enum SessionOrigin: String, Encodable {
        case spiegel = "Spiegel"
        case fiber = "FIBER"
    }

    enum Status: String, Encodable {
        case enabled
        case disabled
    }

        let model = Device.hardwareName

        let osVersion = System.version

        let biometricIdentification: String

        let authenticationMethod: String

        let systemIntegration: Status

        let mpResetBiometric: Status

        let sessionOrigin: SessionOrigin

        let autofillEnabled: Status
}

private extension DeviceInformation {

    func updatedForLogout() -> DeviceInformation {
        return DeviceInformation(biometricIdentification: biometricIdentification,
                                 authenticationMethod: SecureLockMode.masterKey.description,
                                 systemIntegration: systemIntegration,
                                 mpResetBiometric: .disabled,
                                 sessionOrigin: sessionOrigin,
                                 autofillEnabled: autofillEnabled)
    }
}

private extension Bool {
    var description: DeviceInformation.Status {
        return self ? .enabled : .disabled
    }
}
