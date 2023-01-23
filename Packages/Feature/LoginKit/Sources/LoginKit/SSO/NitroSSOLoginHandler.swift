import Foundation
import DashlaneAPI
import CoreCrypto
import SwiftTreats
import CoreSession

struct NitroSSOLoginHandler: Equatable {
    static func == (lhs: NitroSSOLoginHandler, rhs: NitroSSOLoginHandler) -> Bool {
        return lhs.authorisationURL == rhs.authorisationURL && lhs.injectionScript == lhs.injectionScript
        && lhs.login == rhs.login
    }
    
    let login: String
    let authorisationURL: URL
    let injectionScript: String
    let secureTunnel: SecureTunnel
    let webservice: NitroAPIClient
    
    init(login: String, webservice: NitroAPIClient) async throws {
        let tunnelCreator = try NitroSecureTunnelCreator(webservice: webservice)
        let tunnel = try await tunnelCreator.createTunnel()
        let encryptedDomain = try tunnel.push(NitroReguestLogin(domainName: login.domainName))
        let loginResponse = try await webservice.requestLogin(encryptedPayload: encryptedDomain.hexadecimalString)
        let decrypted = try tunnel.pull(NitroLoginResponse.self, from: loginResponse.hexaData)
        self.init(login: login, authorisationURL: decrypted.idpAuthorizeUrl, injectionScript: try NitroInjectionScript.script(callbackURL: decrypted.spCallbackUrl), secureTunnel: tunnel, webservice: webservice)
    }
    
    init(login: String, authorisationURL: URL, injectionScript: String, secureTunnel: SecureTunnel, webservice: NitroAPIClient) {
        self.login = login
        self.authorisationURL = authorisationURL
        self.injectionScript = injectionScript
        self.secureTunnel = secureTunnel
        self.webservice = webservice
    }
    
    func callbackInfo(withSAML saml: String) async throws -> SSOCallbackInfos {
        let encryptedPayload = try secureTunnel.push(ConfirmLoginRequest(domainName: login.domainName, samlResponse: saml))
        let response = try await webservice.confirmLogin(encryptedPayload: encryptedPayload.hexadecimalString)
        let decrytedResponse = try secureTunnel.pull(ConfirmLoginResponse.self, from: response.hexaData)
        return SSOCallbackInfos(ssoToken: decrytedResponse.ssoToken, serviceProviderKey: decrytedResponse.userServiceProviderKey, exists: decrytedResponse.exists)
    }
}
