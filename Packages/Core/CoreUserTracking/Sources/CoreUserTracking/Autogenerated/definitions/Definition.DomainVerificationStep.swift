import Foundation

extension Definition {

public enum `DomainVerificationStep`: String, Encodable {
case `domainVerificationCompleted` = "domain_verification_completed"
case `domainVerificationError` = "domain_verification_error"
case `tapContinueCtaWithDomainUrl` = "tap_continue_cta_with_domain_url"
case `tapVerifyDomainCtaWithDnsInformation` = "tap_verify_domain_cta_with_dns_information"
}
}