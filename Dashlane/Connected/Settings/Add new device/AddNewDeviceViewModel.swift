import Foundation
import DashlaneAPI
import CoreCrypto
import DashTypes
import Combine
import CoreSession
import DesignSystem
import LoginKit

@MainActor
class AddNewDeviceViewModel: ObservableObject, SessionServicesInjecting {

	@Published
	var isLoading = false

	@Published
	var progressState: ProgressionState = .inProgress(L10n.Localizable.addNewDeviceInProgress)

	@Published
	var showError = false

	@Published
	var showScanner = false

    private let apiClient: UserDeviceAPIClient
	private let ecdh: ECDH
	private let session: Session
	private let transferService: TrustedDeviceSecretTransferService

    var dismissPublisher = PassthroughSubject<Void, Never>()

    init(session: Session,
         apiClient: UserDeviceAPIClient,
         sessionCryptoEngineProvider: SessionCryptoEngineProvider,
         qrCodeViaSystemCamera: String? = nil) {
        self.session = session
        self.apiClient = apiClient
        self.transferService = TrustedDeviceSecretTransferService(apiClient: apiClient, sessionCryptoEngineProvider: sessionCryptoEngineProvider)
        ecdh = ECDH()
        if let qrcode = qrCodeViaSystemCamera {
            didScanQRCode(qrcode)
        }
    }

    func didScanQRCode(_ qrcode: String) {
        guard let info = UntrustedDeviceTransferInfo(qrCode: qrcode) else {
            showError = true
            return
        }
        isLoading = true
        Task {
            await startTransfer(with: info)
        }
    }

    private func startTransfer(with info: UntrustedDeviceTransferInfo) async {
        do {
            let token = try await apiClient.authentication.token()
            let transferData = DevciceToDeviceTransferData(key: session.authenticationMethod.sessionKey.transferKey(accountType: session.configuration.info.accountType), token: token, login: session.login.email, version: 1)
            try await transferService.transferData(transferData, with: UntrustedDeviceTransferInfo(publicKey: info.publicKey, id: info.id))
            self.progressState = .completed(L10n.Localizable.addNewDeviceCompleted, {
                self.dismissPublisher.send()
            })
        } catch {
            showError = true
            isLoading = false
        }
    }
}

private extension UserDeviceAPIClient.Authentication {
    func token() async throws -> String? {
        let twoFAStatus = try await get2FAStatus.callAsFunction()
        if twoFAStatus.type == .emailToken || twoFAStatus.type == .sso {
            let tokenInfo = try await requestExtraDeviceRegistration.callAsFunction(tokenType: .shortLived)
            return tokenInfo.token
        }
        return nil
    }
}

extension AddNewDeviceViewModel {
    static var mock: AddNewDeviceViewModel {
        AddNewDeviceViewModel(session: .mock, apiClient: .fake, sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()), qrCodeViaSystemCamera: nil)
    }
}
