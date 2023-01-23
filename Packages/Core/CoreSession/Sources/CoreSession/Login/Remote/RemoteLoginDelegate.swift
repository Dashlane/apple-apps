import Foundation
import DashTypes

public protocol RemoteLoginDelegate: AnyObject {
            func retrieveCryptoConfig(fromEncryptedSettings content: String, using masterKey: MasterKey, remoteKey: Data?) throws -> CryptoRawConfig

                func fetchTeamSpaceCryptoConfigHeader(for login: Login, authentication: ServerAuthentication) async throws -> CryptoEngineConfigHeader?

        func deviceService(for login: Login, authentication: ServerAuthentication) -> DeviceServiceProtocol

        func deviceLimit(for login: Login, authentication: ServerAuthentication, completion: @escaping (Result<Int?, Error>) -> Void)

        func didCreateSession(_ session: Session)
}
