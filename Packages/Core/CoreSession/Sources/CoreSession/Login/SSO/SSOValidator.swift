import Foundation
import SwiftTreats
import DashlaneAPI

public protocol SSOValidator {
    var cryptoEngineProvider: CryptoEngineProvider { get }
    var apiClient: AppAPIClient { get }
    var serviceProviderUrl: URL { get }
    var isNitroProvider: Bool { get }
    func validateSSOTokenAndGetKeys(_ token: String, serviceProviderKey: String) async throws -> SSOKeys
    func authTicket(token: String, login: String, completion: @escaping CompletionBlock<String, Swift.Error>)
    func decipherRemoteKey(serviceProviderKey: String, remoteKey: RemoteKey?, ssoServerKey: String?, authTicket: AuthTicket) throws -> SSOKeys
}

public extension SSOValidator {

    func authTicket(token: String, login: String, completion: @escaping CompletionBlock<String, Swift.Error>) {
        Task {
            do {
                let verificationResponse = try await apiClient.authentication.performSsoVerification(login: login, ssoToken: token)
                await MainActor.run {
                    completion(.success(verificationResponse.authTicket))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }

        }
    }

    func decipherRemoteKey(serviceProviderKey: String,
                           remoteKey: RemoteKey?,
                           ssoServerKey: String?,
                           authTicket: AuthTicket) throws -> SSOKeys {
        guard let remoteKey = remoteKey,
              let ssoServerKey = ssoServerKey else {
            throw SSOAccountError.userDataNotFetched
        }

        guard let serverKeyData = Data(base64Encoded: ssoServerKey),
              let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey),
              let remoteKeyData = Data(base64Encoded: remoteKey.key) else {
            throw SSOAccountError.invalidServiceProviderKey
        }

        let ssoKey = serverKeyData ^ serviceProviderKeyData
        let cryptoCenter = try? cryptoEngineProvider.cryptoEngine(for: ssoKey)

        guard let decipheredRemoteKey = cryptoCenter?.decrypt(data: remoteKeyData) else {
            throw SSOAccountError.invalidServiceProviderKey
        }
        return SSOKeys(remoteKey: decipheredRemoteKey, ssoKey: ssoKey, authTicket: authTicket)
    }
}

extension Data {
    static func ^ (left: Data, right: Data) -> Data {
        if left.count != right.count {
            NSLog("Warning! XOR operands are not equal. left = \(left), right = \(right)")
        }

        var result: Data = Data()
        var smaller: Data, bigger: Data
        if left.count <= right.count {
            smaller = left
            bigger = right
        } else {
            smaller = right
            bigger = left
        }

        let bs: [UInt8] = Array(smaller)
        let bb: [UInt8] = Array(bigger)
        var br = [UInt8]()
        for i in 0..<bs.count {
            br.append(bs[i] ^ bb[i])
        }
        for j in bs.count..<bb.count {
            br.append(bb[j])
        }
        result = Data(br)
        return result
    }
}
