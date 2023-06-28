import Foundation
import DashTypes
import CoreNetworking
import CorePersonalData
import Combine
import CoreUserTracking
import DashlaneAppKit
import AuthenticatorKit

@MainActor
class AddItemFlowViewModel: ObservableObject, AuthenticatorServicesInjecting, AuthenticatorMockInjecting {
    enum Step {
        case intro(hasAtLeastOneTokenStoredInVault: Bool)
        case accountHelp
        case settingsHelp
        case codeHelp
        case setupMethod
        case scanCode(AddItemScanCodeFlowViewModel)
        case enterCodeManually(AddItemManuallyFlowViewModel)
    }

    @Published
    var steps: [Step]

    @MainActor
    let dismissPublisher = PassthroughSubject<Void, Never>()

    let completion: (OTPInfo) -> Void

    let logger: Logger
    let databaseService: AuthenticatorDatabaseServiceProtocol
    let mode: AddItemMode
    let addItemViewModelFactory: AddItemManuallyFlowViewModel.Factory
    let scanCodeViewModelFactory: AddItemScanCodeFlowViewModel.Factory
    let activityReporter: ActivityReporterProtocol
    let skipIntro: Bool
    let isFirstToken: Bool

    init(databaseService: AuthenticatorDatabaseServiceProtocol,
         hasAtLeastOneTokenStoredInVault: Bool,
         mode: AddItemMode,
         legacyWebService: LegacyWebService,
         logger: Logger,
         activityReporter: ActivityReporterProtocol,
         addItemViewModelFactory: AddItemManuallyFlowViewModel.Factory,
         scanCodeViewModelFactory: AddItemScanCodeFlowViewModel.Factory,
         skipIntro: Bool = false,
         completion: @escaping (OTPInfo) -> Void) {
        self.databaseService = databaseService
        self.mode = mode
        self.addItemViewModelFactory = addItemViewModelFactory
        self.scanCodeViewModelFactory = scanCodeViewModelFactory
        self.logger = logger
        self.completion = completion
        isFirstToken = !hasAtLeastOneTokenStoredInVault
        if !skipIntro {
            self.steps = [.intro(hasAtLeastOneTokenStoredInVault: hasAtLeastOneTokenStoredInVault)]
        } else {
            self.steps = [.accountHelp]
        }
        self.activityReporter = activityReporter
        self.skipIntro = skipIntro
    }

        @MainActor
    func startScanCode() async {
        let viewModel = scanCodeViewModelFactory
            .make(otpInfo: nil,
                  mode: mode,
                  isFirstToken: isFirstToken,
                  didCreate: { [weak self] in self?.didCreate(otpInfo: $0, mode: $1)})
        self.steps.append(.scanCode(viewModel))
    }

    func startManuallyChooseWebsite() {
        let viewModel = addItemViewModelFactory.make(mode: mode,
                                                     isFirstToken: isFirstToken,
                                                     didCreate: { [weak self] in
            self?.didCreate(otpInfo: $0, mode: $1)
        })
        self.steps.append(.enterCodeManually(viewModel))
    }

    private func didCreate(otpInfo: OTPInfo, mode: Definition.OtpAdditionMode) {
        self.completion(otpInfo)
        self.dismissPublisher.send()
        self.logAddOTP(otpInfo, additionMode: mode)
    }

    private func logAddOTP(_ otpInfo: OTPInfo, additionMode: Definition.OtpAdditionMode) {
        activityReporter.report(UserEvent.AuthenticatorAddOtpCode(otpAdditionMode: additionMode))
        activityReporter.report(AnonymousEvent.AuthenticatorAddOtpCode(authenticatorIssuerId: otpInfo.authenticatorIssuerId, otpAdditionMode: additionMode, otpSpecifications: otpInfo.logSpecifications))
    }
}
