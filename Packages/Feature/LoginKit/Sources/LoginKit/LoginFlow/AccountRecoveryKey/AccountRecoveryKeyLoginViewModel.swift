import Foundation
import DashlaneAPI
import DashlaneCrypto
import DashTypes
import CoreSession

@MainActor
public class AccountRecoveryKeyLoginViewModel: ObservableObject, LoginKitServicesInjecting {

    @Published
    var showNoMatchError = false

    @Published
    var recoveryKey: String {
        didSet {
            showNoMatchError = false
        }
    }

    private let login: String
    private let appAPIClient: AppAPIClient
    private let authTicket: AuthTicket
    private let completion: @MainActor (CoreSession.MasterKey, AuthTicket) -> Void
    let accountType: AccountType

    public init(login: String,
                appAPIClient: AppAPIClient,
                authTicket: AuthTicket,
                accountType: AccountType,
                recoveryKey: String = "",
                showNoMatchError: Bool = false,
                completion: @escaping @MainActor (CoreSession.MasterKey, AuthTicket) -> Void) {
        self.login = login
        self.recoveryKey = recoveryKey
        self.showNoMatchError = showNoMatchError
        self.appAPIClient = appAPIClient
        self.completion = completion
        self.authTicket = authTicket
        self.accountType = accountType
    }

    func validate() async {
        do {
            let encryptedVaultKey = try await appAPIClient.accountrecovery.getEncryptedVaultKey(login: login, authTicket: authTicket.value).encryptedVaultKey
            guard let cryptoCenter = CryptoCenter(from: encryptedVaultKey) else {
                throw CryptoError.decryptionFailure
            }
            let cryptoEngine = SpecializedCryptoEngine(cryptoCenter: cryptoCenter, secret: .password(recoveryKey.replacingOccurrences(of: "-", with: "")))
            guard let encryptedVaultKeyData = Data(base64Encoded: encryptedVaultKey),
                  let decryptedData = cryptoEngine.decrypt(data: encryptedVaultKeyData) else {
                throw CryptoError.decryptionFailure
            }
            let decryptedMasterKey = String(decoding: decryptedData, as: UTF8.self)
            completion(.masterPassword(decryptedMasterKey), authTicket)
        } catch {
            showNoMatchError = true
        }
    }
}
