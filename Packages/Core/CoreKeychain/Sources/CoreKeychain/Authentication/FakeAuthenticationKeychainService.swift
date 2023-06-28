import Foundation
import DashTypes
import Combine
import LocalAuthentication

public struct FakeAuthenticationKeychainService: AuthenticationKeychainServiceProtocol {
    static var defaultPasswordValidityPeriod: TimeInterval = 60

    static var defaultRemoteKeyValidityPeriod: TimeInterval = 60

    let cryptoEngine: KeychainCryptoEngine = FakeKeychainCryptoEngine()

    let accessGroup: String = ""

    init() {}

    public let masterKeyStatusChanged = PassthroughSubject<AuthenticationKeychainService.MasterKeyStatusChange, Never>()

    public func masterKeyStatus(for login: Login) -> MasterKeyStoredStatus {
        return .available(accessMode: .whenDeviceUnlocked)
    }

    public func masterKey(for login: Login) throws -> CoreKeychain.MasterKey {
        return .masterPassword("test")
    }

    public func masterKey(for login: Login, using context: LAContext?) throws -> CoreKeychain.MasterKey {
        return .masterPassword("test")
    }

    public func removeMasterKey(for login: Login) throws {

    }

    public func removeServerKey(for login: Login) throws {

    }

    public func pincode(for login: Login) throws -> String {
        return "1234"
    }

    public func setPincode(_ pincode: String?, for login: Login) throws {

    }

    public func serverKey(for login: Login) -> String? {
        return nil
    }

    public func saveServerKey(_ serverKey: String, for login: Login) throws {

    }

    public func removeAllLocalData() throws {

    }

    public func masterPasswordEquals(_ masterPassword: String, for login: Login) throws -> Bool {
        return false
    }

    public func makeResetContainerKeychainManager(userLogin: UserLogin) -> ResetContainerKeychainManager {
        FakeResetContainerKeychainManager()
    }
}

extension AuthenticationKeychainServiceProtocol where Self == FakeAuthenticationKeychainService {
    public static var fake: AuthenticationKeychainServiceProtocol {
        FakeAuthenticationKeychainService()
    }
}

class FakeKeychainCryptoEngine: KeychainCryptoEngine {
    func encrypt(data: Data, using password: String) -> Data? {
        return data.mockCrypto()
    }

    func decrypt(data: Data, using password: String) -> Data? {
        return data.mockCrypto()
    }
}

extension Data {
    func mockCrypto() -> Data {
        return Data(reversed())
    }
}

public extension FakeAuthenticationKeychainService {
	static var mock: FakeAuthenticationKeychainService {
		FakeAuthenticationKeychainService()
	}
}
