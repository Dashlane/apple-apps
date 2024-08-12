import AuthenticationServices
import Foundation

extension ASCredentialProviderExtensionContext: CredentialProviderContext {}

public protocol CredentialProviderContext {

  func completeExtensionConfigurationRequest()

  func cancelRequest(withError error: Error)

  func completeRequest(
    withSelectedCredential credential: ASPasswordCredential, completionHandler: ((Bool) -> Void)?)

  @available(iOS 17.0, macOS 14.0, *)
  func completeAssertionRequest(using credential: ASPasskeyAssertionCredential) async -> Bool

  @available(iOS 17.0, macOS 14.0, *)
  func completeRegistrationRequest(using credential: ASPasskeyRegistrationCredential) async -> Bool
}

extension CredentialProviderContext where Self == CredentialProviderContextMock {
  static func mock() -> Self {
    return CredentialProviderContextMock()
  }
}

struct CredentialProviderContextMock: CredentialProviderContext {

  let completeRequest: (ASPasswordCredential) -> Void
  let completeExtensionConfiguration: () -> Void
  let cancelRequest: (Error) -> Void
  let completeAssertionRequest: () -> Void
  let completeRegistrationRequest: () -> Void

  public init(
    completeRequest: @escaping (ASPasswordCredential) -> Void = { _ in },
    completeExtensionConfiguration: @escaping () -> Void = {},
    cancelRequest: @escaping (Error) -> Void = { _ in },
    completeAssertionRequest: @escaping () -> Void = {},
    completeRegistrationRequest: @escaping () -> Void = {}
  ) {
    self.completeRequest = completeRequest
    self.completeExtensionConfiguration = completeExtensionConfiguration
    self.cancelRequest = cancelRequest
    self.completeAssertionRequest = completeAssertionRequest
    self.completeRegistrationRequest = completeRegistrationRequest
  }

  func completeRequest(
    withSelectedCredential credential: ASPasswordCredential, completionHandler: ((Bool) -> Void)?
  ) {
    completeRequest(credential)
    completionHandler?(true)
  }

  func completeExtensionConfigurationRequest() {
    completeExtensionConfiguration()
  }

  func cancelRequest(withError error: Error) {
    cancelRequest(error)
  }

  @available(iOS 17.0, macOS 14, *)
  func completeAssertionRequest(using credential: ASPasskeyAssertionCredential) async -> Bool {
    completeAssertionRequest()
    return true
  }

  @available(iOS 17.0, macOS 14, *)
  func completeRegistrationRequest(using credential: ASPasskeyRegistrationCredential) async -> Bool
  {
    completeRegistrationRequest()
    return true
  }
}
