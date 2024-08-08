import AuthenticationServices
import CorePersonalData
import Foundation

@available(iOS, introduced: 16, deprecated: 17.0, message: "Use CredentialProvider instead")
protocol LegacyCredentialProvider {

  func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier])

  func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity)

  func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity)

  func prepareInterfaceForExtensionConfiguration()
}

@available(iOS 17, *)
protocol CredentialProvider {

  func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier])

  func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters)

  func prepareInterfaceForExtensionConfiguration()

  func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest)

  func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest)

  func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest)
}

extension ASExtensionError.Code {
  var nsError: NSError {
    return NSError(domain: ASExtensionErrorDomain, code: self.rawValue)
  }
}
