import CoreCrypto
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

struct ConfidentialSSOLoginHandler: Equatable {
  static func == (lhs: ConfidentialSSOLoginHandler, rhs: ConfidentialSSOLoginHandler) -> Bool {
    return lhs.authorisationURL == rhs.authorisationURL
      && lhs.injectionScript == lhs.injectionScript
      && lhs.login == rhs.login
  }

  let login: Login
  let authorisationURL: URL
  let injectionScript: String
  let teamUuid: String
  let domainName: String
  let secureNitroClient: NitroSecureAPIClient

  init(login: Login, nitroClient: NitroAPIClient) async throws {
    let tunnelCreator = try ConfidentialSSOSecureTunnelCreator(nitroClient: nitroClient)
    let tunnel = try await tunnelCreator.createTunnel()
    let secureNitroClient = nitroClient.makeNitroSecureAPIClient(secureTunnel: tunnel)
    let loginResponse = try await secureNitroClient.authentication.requestLogin2(login: login.email)
    let script = try ConfidentialSSOInjectionScript.script(callbackURL: loginResponse.spCallbackUrl)
    guard let idpAuthorizeUrl = URL(string: loginResponse.idpAuthorizeUrl) else {
      throw URLError(.badURL)
    }

    self.init(
      login: login,
      authorisationURL: idpAuthorizeUrl,
      injectionScript: script,
      secureNitroClient: secureNitroClient,
      teamUuid: loginResponse.teamUuid,
      domainName: loginResponse.domainName)
  }

  init(
    login: Login, authorisationURL: URL, injectionScript: String,
    secureNitroClient: NitroSecureAPIClient, teamUuid: String, domainName: String
  ) {
    self.login = login
    self.authorisationURL = authorisationURL
    self.injectionScript = injectionScript
    self.secureNitroClient = secureNitroClient
    self.teamUuid = teamUuid
    self.domainName = domainName
  }

  func callbackInfo(withSAML saml: String) async throws -> SSOCallbackInfos {
    let response = try await secureNitroClient.authentication.confirmLogin2(
      teamUuid: teamUuid, domainName: domainName, samlResponse: saml)
    return SSOCallbackInfos(
      ssoToken: response.ssoToken, serviceProviderKey: response.userServiceProviderKey,
      exists: response.exists)
  }
}
