import Foundation

public struct NitroAPIClient {
    let engine: NitroAPIClientEngine

    public init(engine: NitroAPIClientEngine) {
        self.engine = engine
    }
    
    public func clientHello(withPublicKey publicKey: String) async throws -> String {
        let result: HelloResponse =  try await engine.post("/tunnel/ClientHello", body: Hello(clientPublicKey: publicKey))
        return result.attestation
    }
    
    public func terminateHello(withClientHeader header: String) async throws{
        let _: Empty =  try await engine.post("/tunnel/TerminateHello", body: TerminateHello(clientHeader: header))
    }
    
    public func requestLogin(encryptedPayload: String) async throws -> String {
        let result: String =  try await engine.post("/authentication/RequestLogin", body: EncryptedInput(data: encryptedPayload))
        return result
    }
    
    public func confirmLogin(encryptedPayload: String) async throws -> String {
        let result: String =  try await engine.post("/authentication/ConfirmLogin", body: EncryptedInput(data: encryptedPayload))
        return result
    }
}

struct Hello: Encodable {
    let clientPublicKey: String
}

public struct HelloResponse: Decodable {
    public let attestation: String
}

struct TerminateHello: Encodable {
    let clientHeader: String
}

public struct NitroLoginResponse: Decodable {
    public let idpAuthorizeUrl: URL
    public let spCallbackUrl: String
}

struct EncryptedInput: Encodable {
    let data: String
}

public struct NitroReguestLogin: Encodable {
    let domainName: String
    public init(domainName: String) {
        self.domainName = domainName
    }
}

public struct ConfirmLoginRequest: Encodable {
    let domainName: String
    let samlResponse: String
    
    public init(domainName: String, samlResponse: String) {
        self.domainName = domainName
        self.samlResponse = samlResponse
    }
}

public struct ConfirmLoginResponse: Decodable {
    public let ssoToken: String
    public let userServiceProviderKey: String
    public let exists: Bool
    
    public init(ssoToken: String, userServiceProviderKey: String) {
        self.ssoToken = ssoToken
        self.userServiceProviderKey = userServiceProviderKey
        exists = false
    }
}
