import Foundation

extension UserEvent {

public struct `SetupSso`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`currentBillingPlanTier`: Definition.B2BPlanTier, `emailDomainError`: Definition.EmailDomainError, `emailDomainSubmittedCount`: Int, `emailDomainValidatedCount`: Int, `encryptionServicePlatformSelected`: Definition.EncryptionServicePlatformSelected, `idpValidationResponse`: Definition.IdpValidationResponse, `ssoSetupStep`: Definition.SsoSetupStep, `ssoSolutionChosen`: Definition.SsoSolutionChosen, `testSsoResponse`: Definition.TestSsoResponse) {
self.currentBillingPlanTier = currentBillingPlanTier
self.emailDomainError = emailDomainError
self.emailDomainSubmittedCount = emailDomainSubmittedCount
self.emailDomainValidatedCount = emailDomainValidatedCount
self.encryptionServicePlatformSelected = encryptionServicePlatformSelected
self.idpValidationResponse = idpValidationResponse
self.ssoSetupStep = ssoSetupStep
self.ssoSolutionChosen = ssoSolutionChosen
self.testSsoResponse = testSsoResponse
}
public let currentBillingPlanTier: Definition.B2BPlanTier
public let emailDomainError: Definition.EmailDomainError
public let emailDomainSubmittedCount: Int
public let emailDomainValidatedCount: Int
public let encryptionServicePlatformSelected: Definition.EncryptionServicePlatformSelected
public let idpValidationResponse: Definition.IdpValidationResponse
public let name = "setup_sso"
public let ssoSetupStep: Definition.SsoSetupStep
public let ssoSolutionChosen: Definition.SsoSolutionChosen
public let testSsoResponse: Definition.TestSsoResponse
}
}
