import Foundation
import CorePersonalData
import AuthenticatorKit
import CoreUserTracking
import Logger
import Combine
import DashTypes

@MainActor
class AddItemScanCodeFlowViewModel: ObservableObject, AuthenticatorServicesInjecting, AuthenticatorMockInjecting {

    enum Step {
        case scanCode(ScanQRCodeViewModel)
        case enterCodeManually(AddItemManuallyFlowViewModel)
        case credentialsMatchingWebsite(MatchingCredentialListViewModel)
        case failedToAddItem(String)
        case preview(TokenRowViewModel, () -> Void)
        case dashlane2FAMessage(OTPInfo)
    }

    @Published var steps: [Step] = []

    @Published
    var showSuccess = false

    let databaseService: AuthenticatorDatabaseServiceProtocol
    private let mode: AddItemMode
    private let logger: Logger
    private let didCreate: (OTPInfo, Definition.OtpAdditionMode) -> Void

    let dismissPublisher = PassthroughSubject<Void, Never>()
    private let otpInfo: OTPInfo?
    private let tokenRowViewModelFactory: TokenRowViewModel.Factory
    private let matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory
    private let addManuallyViewModelFactory: AddItemManuallyFlowViewModel.Factory
    let isFirstToken: Bool

    init(otpInfo: OTPInfo? = nil,
         databaseService: AuthenticatorDatabaseServiceProtocol,
         tokenRowViewModelFactory: TokenRowViewModel.Factory,
         matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory,
         addManuallyViewModelFactory: AddItemManuallyFlowViewModel.Factory,
         mode: AddItemMode,
         logger: Logger,
         isFirstToken: Bool,
         didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) {
        self.otpInfo = otpInfo
        self.tokenRowViewModelFactory = tokenRowViewModelFactory
        self.matchingCredentialListViewModelFactory = matchingCredentialListViewModelFactory
        self.addManuallyViewModelFactory = addManuallyViewModelFactory
        self.databaseService = databaseService
        self.mode = mode
        self.logger = logger
        self.didCreate = didCreate
        self.isFirstToken = isFirstToken

        Task {
            if let otpInfo = otpInfo {
                await start(with: otpInfo)
            } else {
                await start()
            }
            assert(!steps.isEmpty)
        }
    }

    private func start() async {
        let viewModel = ScanQRCodeViewModel(logger: logger) { [weak self] otpInfo in
            guard let self = self else { return }
            guard let otpInfo = otpInfo else {
                self.dismissPublisher.send()
                return
            }
            await self.start(with: otpInfo)
        }
        self.steps.append(.scanCode(viewModel))
    }

    func start(with otpInfo: OTPInfo) async {
        if otpInfo.isDashlaneOTP {
            handleDashlaneOTPInfo(otpInfo)
        } else {
            await handleOTPInfo(otpInfo)
        }
    }

    func handleDashlaneOTPInfo(_ otpInfo: OTPInfo) {
                self.save(otpInfo)
        self.steps.append(.preview(self.tokenRowViewModelFactory.make(token: otpInfo), {
            if otpInfo.isDashlaneOTP {
                self.steps.append(.dashlane2FAMessage(otpInfo))
            } else {
                self.complete(otpInfo, mode: .qrCode)
            }
        }))
    }

    func handleOTPInfo(_ otpInfo: OTPInfo) async {
        let matchingAction = await self.mode.matchingAction(forWebsite: otpInfo.configuration.issuerOrTitle)

        switch matchingAction {
        case .notNeeded:
                        self.save(otpInfo)
            self.steps.append(.preview(self.tokenRowViewModelFactory.make(token: otpInfo), {
                if otpInfo.isDashlaneOTP {
                    self.steps.append(.dashlane2FAMessage(otpInfo))
                } else {
                    self.complete(otpInfo, mode: .qrCode)
                }
            }))
        case let .linkToCredential(credential):
            guard case let .paired(provider) = self.mode else {
                fatalError("We should never be here. This has been called for standalone mode")
            }
            self.matchingCredentialsSaveAfterSelection(otpInfo: otpInfo,
                                                       provider: provider,
                                                       userAction: .linkToCredential(credential),
                                                       mode: .qrCode)
        case let .showList(matchingCredentials, provider):
            self.updateStepToMatchingCredentialSelection(for: otpInfo, matchingCredentials: matchingCredentials, provider: provider)
        }
    }

    private func save(_ otpInfo: OTPInfo) {
        do {
            try self.databaseService.add([otpInfo])
        } catch {
            self.steps.append(.failedToAddItem(otpInfo.configuration.issuerOrTitle))
        }
    }

    func complete(_ otpInfo: OTPInfo, mode: Definition.OtpAdditionMode) {
        self.didCreate(otpInfo, mode)
    }

    private func updateStepToMatchingCredentialSelection(for otpInfo: OTPInfo, matchingCredentials: [Credential], provider: SessionCredentialsProvider) {
        let viewModel = matchingCredentialListViewModelFactory.make(website: otpInfo.configuration.issuerOrTitle, matchingCredentials: matchingCredentials) { action in

            self.matchingCredentialsSaveAfterSelection(otpInfo: otpInfo, provider: provider, userAction: action, mode: .qrCode)
        }
        self.steps.append(.credentialsMatchingWebsite(viewModel))
    }

    func matchingCredentialsSaveAfterSelection(otpInfo: OTPInfo,
                                               provider: SessionCredentialsProvider,
                                               userAction: MatchingCredentialListViewModel.Completion,
                                               mode: Definition.OtpAdditionMode) {
        do {
            switch userAction {
            case .createCredential:
                try self.databaseService.add([otpInfo])
            case let .linkToCredential(credential):
                try provider.link(otpInfo, to: credential)
            }
            self.steps.append(.preview(tokenRowViewModelFactory.make(token: otpInfo), {
                self.complete(otpInfo, mode: mode)
            }))
        } catch {
            self.steps.append(.failedToAddItem(otpInfo.configuration.issuerOrTitle))
        }
    }

            func startManuallyChooseWebsite() {
        let viewModel = addManuallyViewModelFactory.make(mode: mode, isFirstToken: isFirstToken, didCreate: { [weak self] in
            self?.complete($0, mode: $1)
        })
        self.steps.append(.enterCodeManually(viewModel))
    }

        func resetFlow() {
        while steps.count > 1 {
            _ = steps.popLast()
        }
    }
}
