import AuthenticationServices
import Foundation

extension ASCredentialProviderExtensionContext: CredentialProviderContext {}

public protocol CredentialProviderContext {

  func completeExtensionConfigurationRequest()

  func cancelRequest(withError error: Error)

  func completeRequest(
    withSelectedCredential credential: ASPasswordCredential, completionHandler: ((Bool) -> Void)?)

  func completeAssertionRequest(using credential: ASPasskeyAssertionCredential) async -> Bool

  func completeRegistrationRequest(using credential: ASPasskeyRegistrationCredential) async -> Bool

  @available(iOS 18.0, macOS 15.0, *)
  func completeOneTimeCodeRequest(using: ASOneTimeCodeCredential) async -> Bool

  #if !targetEnvironment(macCatalyst) && !os(visionOS)
    @available(iOS 18.0, *)
    func completeRequest(withTextToInsert: String) async -> Bool
  #endif
}

@available(iOS 18.0, *)
extension CredentialProviderContext where Self == CredentialProviderContextMock {
  static func mock() -> Self {
    return CredentialProviderContextMock()
  }
}

@available(iOS 18.0, *)
struct CredentialProviderContextMock: CredentialProviderContext {
  let completeExtensionConfiguration: () -> Void

  let completePasswordRequest: (ASPasswordCredential) -> Void
  let completeOTPRequest: (ASOneTimeCodeCredential) -> Void
  let completeAnyTextRequest: (String) -> Void

  let completeAssertionRequest: () -> Void
  let completeRegistrationRequest: () -> Void
  let cancelRequest: (Error) -> Void

  public init(
    completeExtensionConfiguration: @escaping () -> Void = {},
    completePasswordRequest: @escaping (ASPasswordCredential) -> Void = { _ in },
    completeOTPRequest: @escaping (ASOneTimeCodeCredential) -> Void = { _ in },
    completeAnyTextRequest: @escaping (String) -> Void = { _ in },
    completeAssertionRequest: @escaping () -> Void = {},
    completeRegistrationRequest: @escaping () -> Void = {},
    cancelRequest: @escaping (Error) -> Void = { _ in }
  ) {
    self.completePasswordRequest = completePasswordRequest
    self.completeOTPRequest = completeOTPRequest
    self.completeAnyTextRequest = completeAnyTextRequest
    self.completeExtensionConfiguration = completeExtensionConfiguration
    self.cancelRequest = cancelRequest
    self.completeAssertionRequest = completeAssertionRequest
    self.completeRegistrationRequest = completeRegistrationRequest
  }

  func completeExtensionConfigurationRequest() {
    completeExtensionConfiguration()
  }

  func completeRequest(
    withSelectedCredential credential: ASPasswordCredential, completionHandler: ((Bool) -> Void)?
  ) {
    completePasswordRequest(credential)
    completionHandler?(true)
  }

  func completeOneTimeCodeRequest(using credential: ASOneTimeCodeCredential) async -> Bool {
    completeOTPRequest(credential)
    return true
  }

  func completeAssertionRequest(using credential: ASPasskeyAssertionCredential) async -> Bool {
    completeAssertionRequest()
    return true
  }

  func completeRegistrationRequest(using credential: ASPasskeyRegistrationCredential) async -> Bool
  {
    completeRegistrationRequest()
    return true
  }

  func completeRequest(withTextToInsert text: String) async -> Bool {
    completeAnyTextRequest(text)
    return true
  }

  func cancelRequest(withError error: Error) {
    cancelRequest(error)
  }
}
