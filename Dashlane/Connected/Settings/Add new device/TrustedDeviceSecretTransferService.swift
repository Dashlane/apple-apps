import Foundation
import DashlaneAPI
import CoreSession
import CoreCrypto
import DashTypes
import LoginKit

class TrustedDeviceSecretTransferService {
    let apiClient: UserDeviceAPIClient
    let sessionCryptoEngineProvider: CryptoEngineProvider
    let ecdh: ECDH

    init(apiClient: UserDeviceAPIClient, sessionCryptoEngineProvider: CryptoEngineProvider) {
        self.apiClient = apiClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        ecdh = ECDH()
    }

    func transferData<T: Encodable>(_ transferData: T, with info: UntrustedDeviceTransferInfo) async throws {
        let untrustedPublicKey = Data(base64Encoded: info.publicKey)!
        let symmetricKey = try ecdh.privateKey.symmetricKey(withPublicKey: untrustedPublicKey, base64EncodedSalt: ApplicationSecrets.MPTransfer.salt)
        let keyString = symmetricKey.withUnsafeBytes {
            return Data(Array($0))
        }
        let cryptoEngine = try sessionCryptoEngineProvider.cryptoEngine(for: keyString)
        let data = try JSONEncoder().encode(transferData)
        let encryptedData = cryptoEngine.encrypt(data: data)!
        try await apiClient.mpless.completeTransfer.callAsFunction(transferId: info.id, encryptedData: encryptedData.base64EncodedString(), publicKey: ecdh.publicKey.base64EncodedString(), cryptography: .init(algorithm: .directHKDFSHA256, ellipticCurve: .x25519))
    }
}

extension TrustedDeviceSecretTransferService {
	static var mock: TrustedDeviceSecretTransferService {
		TrustedDeviceSecretTransferService(apiClient: .fake, sessionCryptoEngineProvider: FakeCryptoEngineProvider())
	}
}
