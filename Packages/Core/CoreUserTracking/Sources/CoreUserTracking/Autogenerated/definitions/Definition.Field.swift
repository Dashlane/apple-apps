import Foundation

extension Definition {

  public enum `Field`: String, Encodable, Sendable {
    case `addressName` = "address_name"
    case `associatedAppsList` = "associated_apps_list"
    case `associatedWebsitesList` = "associated_websites_list"
    case `autoLoginOff` = "auto_login_off"
    case `autoLoginOn` = "auto_login_on"
    case `bank`
    case `bic`
    case `birthDate` = "birth_date"
    case `birthPlace` = "birth_place"
    case `building`
    case `cardNumber` = "card_number"
    case `category`
    case `city`
    case `color`
    case `content`
    case `country`
    case `customField` = "custom_field"
    case `dateOfBirth` = "date_of_birth"
    case `deliveryDate` = "delivery_date"
    case `deliveryPlace` = "delivery_place"
    case `digitCode` = "digit_code"
    case `door`
    case `email`
    case `emailName` = "email_name"
    case `excludeFromSecurityScoreOff` = "exclude_from_security_score_off"
    case `excludeFromSecurityScoreOn` = "exclude_from_security_score_on"
    case `expireDate` = "expire_date"
    case `firstName` = "first_name"
    case `fiscalNumber` = "fiscal_number"
    case `floor`
    case `fullname`
    case `iban`
    case `issueNumber` = "issue_number"
    case `jobTitle` = "job_title"
    case `lastName` = "last_name"
    case `lastName2` = "last_name2"
    case `linkedBillingAddress` = "linked_billing_address"
    case `linkedIdentity` = "linked_identity"
    case `linkedPhone` = "linked_phone"
    case `login`
    case `middleName` = "middle_name"
    case `mpProtectedOff` = "mp_protected_off"
    case `mpProtectedOn` = "mp_protected_on"
    case `nafCode` = "naf_code"
    case `name`
    case `note`
    case `number`
    case `otpCode` = "otp_code"
    case `otpSecret` = "otp_secret"
    case `otpUrl` = "otp_url"
    case `owner`
    case `ownerName` = "owner_name"
    case `password`
    case `phoneName` = "phone_name"
    case `pseudo`
    case `receiver`
    case `secondaryLogin` = "secondary_login"
    case `secret`
    case `secretId` = "secret_id"
    case `securityCode` = "security_code"
    case `sex`
    case `sirenNumber` = "siren_number"
    case `siretNumber` = "siret_number"
    case `socialSecurityFullname` = "social_security_fullname"
    case `socialSecurityNumber` = "social_security_number"
    case `space`
    case `state`
    case `stateLevel2` = "state_level2"
    case `stateNumber` = "state_number"
    case `streetName` = "street_name"
    case `streetNumber` = "street_number"
    case `streetTitle` = "street_title"
    case `subdomainOnlyOff` = "subdomain_only_off"
    case `subdomainOnlyOn` = "subdomain_only_on"
    case `teledeclarantNumber` = "teledeclarant_number"
    case `title`
    case `tvaNumber` = "tva_number"
    case `type`
    case `url`
    case `website`
    case `zipCode` = "zip_code"
  }
}
