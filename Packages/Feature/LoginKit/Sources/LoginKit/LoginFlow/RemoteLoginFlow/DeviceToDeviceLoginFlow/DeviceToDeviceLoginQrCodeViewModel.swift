import Foundation
import CoreCrypto
import DashlaneAPI
import CoreSession
import DashTypes
import CoreLocalization

@MainActor
public class DeviceToDeviceLoginQrCodeViewModel: ObservableObject, LoginKitServicesInjecting {

    enum FullScreenItem: Identifiable {
        case error
        case recoveryFlow(AccountRecoveryInfo)
        var id: String {
            switch self {
            case .error:
                return "error"
            case let .recoveryFlow(accountInfo):
                return accountInfo.login.email
            }
        }
    }

    public enum CompletionType {
        case qrFinished
        case recoveryFinished(DeviceRegisterData)
        case cancel
    }

    @Published
    var inProgress = true

    @Published
    var qrCodeUrl: String?

    @Published
    var progressState: ProgressionState = .inProgress("")

    @Published
    var presentedItem: FullScreenItem?

    @Published
    var accountRecoveryInfo: AccountRecoveryInfo?

    var login: Login? {
        loginHandler.login
    }

    private let loginHandler: DeviceToDeviceLoginHandler
    private let completion: (CompletionType) -> Void
    private let transferService: UntrustedDeviceSecretTransferService
    private let accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

    public init(loginHandler: DeviceToDeviceLoginHandler,
                apiClient: AppAPIClient,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
                completion: @escaping (DeviceToDeviceLoginQrCodeViewModel.CompletionType) -> Void) {
        self.loginHandler = loginHandler
        self.completion = completion
        self.transferService = UntrustedDeviceSecretTransferService(appAPIClient: apiClient, sessionCryptoEngineProvider: sessionCryptoEngineProvider)
        self.accountRecoveryKeyLoginFlowModelFactory = accountRecoveryKeyLoginFlowModelFactory
        Task {
            await startTransfer()
        }
        Task {
            if let login = loginHandler.login {
                accountRecoveryInfo = try? await loginHandler.accountRecoveryInfo(for: login)
            }
        }
    }

    func startTransfer() async {
        do {
            let info = try await transferService.untrustedDeviceInfo()
            qrCodeUrl = "dashlane:///mplesslogin?key=\(info.publicKey)&id=\(info.id)"
            inProgress = false
            let transferInfo = try await transferService.transferInfo(withId: info.id)
            progressState = .inProgress(L10n.Core.deviceToDeviceLoadingProgress)
            inProgress = true
            let loginData: DevciceToDeviceTransferData = try await transferService.startTransfer(with: transferInfo)
            try await loginHandler.verifyLogin(with: loginData)
            completion(.qrFinished)
        } catch {
            guard case .recoveryFlow = presentedItem else {
                presentedItem = .error
                return
            }
        }
    }

    func retry() {
        presentedItem = nil
        Task {
            await startTransfer()
        }
    }

    func cancel() {
        completion(.cancel)
    }

    func makeAccountRecoveryKeyLoginFlowModel(accountInfo: AccountRecoveryInfo) -> AccountRecoveryKeyLoginFlowModel {
        accountRecoveryKeyLoginFlowModelFactory.make(login: accountInfo.login.email, accountType: accountInfo.accountType, context: .deviceToDevice(nil, loginHandler.deviceInfo), completion: { [weak self] result in
            if case let .completed(sessionKey, authTicket) = result {
                self?.completion(.recoveryFinished(DeviceRegisterData(login: accountInfo.login, accountType: accountInfo.accountType, sessionKey: sessionKey, authTicket: authTicket, isRecoveryLogin: true)))
            }
            self?.presentedItem = nil
        })
    }
}
