import Foundation

extension Definition {

public enum `IdpValidationResponse`: String, Encodable {
case `idpEntrypointNotFound` = "idp_entrypoint_not_found"
case `invalidEntrypoint` = "invalid_entrypoint"
case `invalidIdpSsoDescriptor` = "invalid_idp_sso_descriptor"
case `keyDescriptorNotFound` = "key_descriptor_not_found"
case `missingCertificate` = "missing_certificate"
case `multipleCertificates` = "multiple_certificates"
case `success`
case `xmlParseFailed` = "xml_parse_failed"
}
}