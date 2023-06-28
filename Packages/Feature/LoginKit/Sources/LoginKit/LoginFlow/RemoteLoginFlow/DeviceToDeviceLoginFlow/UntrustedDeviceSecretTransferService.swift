import Foundation
import DashlaneAPI
import CoreSession
import CoreCrypto
import DashTypes
import SwiftTreats

public class UntrustedDeviceSecretTransferService {

    public enum Error: Swift.Error {
        case couldNotGeneratePublicKey
    }

    let appAPIClient: AppAPIClient
    let sessionCryptoEngineProvider: CryptoEngineProvider
    let ecdh: ECDH
    let decoder = JSONDecoder()

    public init(appAPIClient: AppAPIClient,
                sessionCryptoEngineProvider: CryptoEngineProvider) {
        self.appAPIClient = appAPIClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        ecdh = ECDH()
    }

    public func untrustedDeviceInfo() async throws -> UntrustedDeviceTransferInfo {
        let info = try await appAPIClient.mpless.requestTransfer()
        guard let publicKey = ecdh.publicKey.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            throw Error.couldNotGeneratePublicKey
        }
        return UntrustedDeviceTransferInfo(publicKey: publicKey, id: info.transferId)
    }

    public func transferInfo(withId transferId: String) async throws -> AppAPIClient.Mpless.StartTransfer.Response {
        return try await appAPIClient.mpless.startTransfer(transferId: transferId, cryptography: .init(algorithm: .directHKDFSHA256, ellipticCurve: .x25519))
    }

    public func startTransfer<T: Decodable>(with transferInfo: AppAPIClient.Mpless.StartTransfer.Response) async throws -> T {
        let trustedPublicKey = Data(base64Encoded: transferInfo.publicKey.removingPercentEncoding!)!
        let symmetricKey = try ecdh.privateKey.symmetricKey(withPublicKey: trustedPublicKey, base64EncodedSalt: ApplicationSecrets.MPTransfer.salt)
        let keyString = symmetricKey.withUnsafeBytes {
                    return Data(Array($0))
                }
        let cryptoEngine = try sessionCryptoEngineProvider.cryptoEngine(for: keyString)
        guard let data = Data(base64Encoded: transferInfo.encryptedData),
              let decryptedData = cryptoEngine.decrypt(data: data) else {
            throw TransferError.couldNotDecrypt
        }
        let decodedData = try decoder.decode(T.self, from: decryptedData)
        return decodedData
    }
}

public extension UntrustedDeviceSecretTransferService {
    static var mock: UntrustedDeviceSecretTransferService {
        UntrustedDeviceSecretTransferService(appAPIClient: .fake, sessionCryptoEngineProvider: FakeCryptoEngineProvider())
    }
}
