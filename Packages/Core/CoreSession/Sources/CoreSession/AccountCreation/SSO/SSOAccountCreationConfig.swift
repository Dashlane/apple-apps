import CoreTypes

public struct SSOAccountCreationConfig: Hashable {
  let ssoToken: String
  let serviceProviderKey: Base64EncodedString
  let hasUserAcceptedTermsAndConditions: Bool
  let hasUserAcceptedEmailMarketing: Bool

  public init(
    ssoToken: String,
    serviceProviderKey: Base64EncodedString,
    hasUserAcceptedTermsAndConditions: Bool,
    hasUserAcceptedEmailMarketing: Bool
  ) {
    self.ssoToken = ssoToken
    self.serviceProviderKey = serviceProviderKey
    self.hasUserAcceptedTermsAndConditions = hasUserAcceptedTermsAndConditions
    self.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
  }
}
