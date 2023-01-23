import Foundation
import CoreSession
import DashTypes
import DashlaneCrypto
import CorePersonalData
import CorePremium
import CoreNetworking
import CoreFeature

public class RemoteLoginDelegate: CoreSession.RemoteLoginDelegate {
    enum Error: Swift.Error {
        case cannotRetrieveCrypto
    }

    let logger: Logger
    var premiumStatusToPersist: Data?
    private let cryptoProvider: CryptoEngineProvider
    let appAPIClient: AppAPIClient

    public init(logger: Logger, cryptoProvider: CryptoEngineProvider, appAPIClient: AppAPIClient) {
        self.logger = logger
        self.cryptoProvider = cryptoProvider
        self.appAPIClient = appAPIClient
    }

                    public func retrieveCryptoConfig(fromEncryptedSettings content: String, using masterKey: MasterKey, remoteKey: Data?) throws -> CryptoRawConfig {
        let localCryptoEngine = MasterKeyDecryptEngine(secret: masterKey.secret)
        let decryptEngine =  remoteKey == nil ? localCryptoEngine : MasterKeyDecryptEngine(secret: .key(remoteKey!))

        guard let compressedContent = try Data(base64Encoded: content)?.decrypt(using: decryptEngine) else {
            throw Error.cannotRetrieveCrypto
        }

        let settings = try Settings.makeSettings(compressedContent: compressedContent)
        let config: CryptoRawConfig
                if let configFromSettings = settings.cryptoConfig,
           CryptoCenter(from: configFromSettings.parametersHeader) != nil {
            config = configFromSettings
            logger.debug("Crypto from settings: \(config.parametersHeader)")
        }
                else if let lastCryptoCenter = localCryptoEngine.lastCryptoCenter {
            config = CryptoRawConfig(fixedSalt: nil, parametersHeader: lastCryptoCenter.header)
            logger.debug("Crypto from encrypted settings header: \(config.parametersHeader)")
        } else {
            throw Error.cannotRetrieveCrypto
        }

        return config
    }

    public func fetchTeamSpaceCryptoConfigHeader(for login: Login, authentication: ServerAuthentication) async throws -> CryptoEngineConfigHeader? {
        return try await withCheckedThrowingContinuation { continuation in
            let logger = self.logger
            PremiumStatusService.init(login: login, authentication: authentication).getStatus { result in
                switch result {
                case let .success((status, data)):
                    self.premiumStatusToPersist = data

                    let cryptoConfigFromTeamspace =  status.spaces?.first(where: { $0.status == .accepted })?.info.cryptoForcedPayload

                    logger.debug("Crypto from teamspace: \(String(describing: cryptoConfigFromTeamspace))")
                    continuation.resume(returning: cryptoConfigFromTeamspace)
                case .failure(let error):
                    logger.warning("Failed to load premium status configuration", error: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func deviceService(for login: Login, authentication: ServerAuthentication) -> DeviceServiceProtocol {
        let signedAuthentication = authentication.signedAuthentication
        return DeviceService(apiClient: appAPIClient.makeUserClient(credentials: .init(login: login.email,
                                                                                       deviceAccessKey: signedAuthentication.deviceAccessKey,
                                                                                       deviceSecretKey: signedAuthentication.deviceSecretKey)))
    }

    public func deviceLimit(for login: Login, authentication: ServerAuthentication, completion: @escaping (Result<Int?, Swift.Error>) -> Void) {
        let webService = LegacyWebServiceImpl()
        webService.configureAuthentication(usingLogin: login.email, uki: authentication.uki.rawValue)
        let premiumService = PremiumStatusService(webservice: webService)

        premiumService.getStatus { result in
            completion(result.map { status, _ in
                if status.capabilities.devicesLimit.enabled {
                    return status.capabilities.devicesLimit.info?.limit
                } else if !status.capabilities.sync.enabled { 
                    return 1
                } else {
                    return nil
                }
            })
        }
    }

    public func didCreateSession(_ session: Session) {}
}

private class MasterKeyDecryptEngine: DecryptEngine {
    let secret: EncryptionSecret
    var lastCryptoCenter: CryptoCenter?

    init(secret: EncryptionSecret) {
        self.secret = secret
    }

    func decrypt(data: Data) -> Data? {
        let decryptionEngine = CryptoCenter(from: data)
        let decryptedData = try? decryptionEngine?.decrypt(data: data, with: secret)
        let decryptionSucceeded = (decryptedData != nil)
        if decryptionSucceeded {
            lastCryptoCenter = decryptionEngine
        }
        return decryptedData
    }
}

public extension PremiumStatusService {
    convenience init(login: Login, authentication: ServerAuthentication) {
        let webService = LegacyWebServiceImpl()
        webService.configureAuthentication(usingLogin: login.email, uki: authentication.uki.rawValue)
        self.init(webservice: webService)
    }
}
