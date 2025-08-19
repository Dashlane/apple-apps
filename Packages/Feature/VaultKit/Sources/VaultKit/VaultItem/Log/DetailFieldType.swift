import DashlaneAPI
import Foundation
import UserTrackingFoundation

public enum DetailFieldType: String {
  case login
  case password
  case otp
  case cardNumber
  case cCNote
  case securityCode
  case bankAccountIBAN
  case bankAccountBIC
  case number
  case socialSecurityNumber
  case fiscalNumber
  case teledeclarantNumber
  case email
  case secondaryLogin
  case note
  case address
  case content
}

extension DetailFieldType {

  public var definitionField: Definition.Field {
    switch self {
    case .login:
      return .login
    case .password:
      return .password
    case .cardNumber:
      return .cardNumber
    case .securityCode:
      return .securityCode
    case .number:
      return .number
    case .socialSecurityNumber:
      return .socialSecurityNumber
    case .email:
      return .email
    case .bankAccountBIC:
      return .bic
    case .bankAccountIBAN:
      return .iban
    case .cCNote:
      return .note
    case .otp:
      return .otpSecret
    case .fiscalNumber:
      return .fiscalNumber
    case .teledeclarantNumber:
      return .teledeclarantNumber
    case .note:
      return .note
    case .secondaryLogin:
      return .secondaryLogin
    case .address:
      return .addressName
    case .content:
      return .content
    }
  }

  public var auditLogField:
    UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs.Body.AuditLogsElement.Properties.Field?
  {
    switch self {
    case .bankAccountIBAN:
      return .iban
    case .bankAccountBIC:
      return .swift
    case .password:
      return .password
    case .otp:
      return .otp
    case .number, .cardNumber:
      return .number
    case .securityCode:
      return .cvv
    default:
      return nil
    }
  }
}
