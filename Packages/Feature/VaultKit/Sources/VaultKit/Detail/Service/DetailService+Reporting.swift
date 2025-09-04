import CorePersonalData
import DashlaneAPI
import Foundation
import UserTrackingFoundation

extension VaultItemEnumeration {

  var creationPage: Page {
    switch self {
    case .credential:
      return .itemCredentialCreate
    case .secureNote:
      return .itemSecureNoteCreate
    case .bankAccount:
      return .itemBankStatementCreate
    case .creditCard:
      return .itemCreditCardCreate
    case .identity:
      return .itemIdentityCreate
    case .email:
      return .itemEmailCreate
    case .phone:
      return .itemPhoneCreate
    case .address:
      return .itemAddressCreate
    case .company:
      return .itemCompanyCreate
    case .personalWebsite:
      return .itemWebsiteCreate
    case .passport:
      return .itemPassportCreate
    case .idCard:
      return .itemIdCardCreate
    case .fiscalInformation:
      return .itemFiscalStatementCreate
    case .socialSecurityInformation:
      return .itemSocialSecurityStatementCreate
    case .secret:
      return .itemSecretCreate
    case .wifi:
      return .itemWifiCreate
    case .drivingLicence:
      return .itemDriverLicenceCreate
    case .passkey:
      assertionFailure("Passkeys cannot be created manually")
      return .itemCredentialCreate
    }

  }
  var defaultPage: Page {
    switch self {
    case .credential:
      return .itemCredentialDetails
    case .secureNote:
      return .itemSecureNoteDetails
    case .bankAccount:
      return .itemBankStatementDetails
    case .creditCard:
      return .itemCreditCardDetails
    case .identity:
      return .itemIdentityDetails
    case .email:
      return .itemEmailDetails
    case .phone:
      return .itemPhoneDetails
    case .address:
      return .itemAddressDetails
    case .company:
      return .itemCompanyDetails
    case .personalWebsite:
      return .itemWebsiteDetails
    case .passport:
      return .itemPassportDetails
    case .idCard:
      return .itemIdCardDetails
    case .fiscalInformation:
      return .itemFiscalStatementDetails
    case .socialSecurityInformation:
      return .itemSocialSecurityStatementDetails
    case .drivingLicence:
      return .itemDriverLicenceDetails
    case .passkey:
      return .itemPasskeyDetails
    case .secret:
      return .itemSecretDetails
    case .wifi:
      return .itemWifiDetails

    }
  }
}

extension DetailService {
  func reportDetailViewAppearance() {
    let page: Page
    switch mode {
    case .adding:
      page = item.enumerated.creationPage
    default:
      page = item.enumerated.defaultPage
    }
    activityReporter.reportPageShown(page)
  }
}

extension DetailService {
  func sendCopyUsageLog(fieldType: DetailFieldType) {
    let item = item
    let isProtected: Bool
    if let secureItem = item as? SecureItem {
      isProtected = secureItem.secured
    } else {
      isProtected = false
    }
    activityReporter.report(
      UserEvent.CopyVaultItemField(
        field: fieldType.definitionField,
        isProtected: isProtected,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType))
    activityReporter.report(
      AnonymousEvent.CopyVaultItemField(
        domain: item.hashedDomainForLogs(),
        field: fieldType.definitionField,
        itemType: item.vaultItemType))
  }

  func sendViewUsageLog(for fieldType: DetailFieldType) {
    let isProtected: Bool
    let item = item
    if let secureItem = item as? SecureItem {
      isProtected = secureItem.secured
    } else {
      isProtected = false
    }
    activityReporter.report(
      UserEvent.RevealVaultItemField(
        field: fieldType.definitionField,
        isProtected: isProtected,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType))

    guard let credential = item as? Credential else {
      return
    }
    activityReporter.report(
      AnonymousEvent.RevealVaultItemField(
        domain: credential.hashedDomainForLogs(),
        field: fieldType.definitionField,
        itemType: item.vaultItemType))
  }
}

extension DetailService {
  func sendRevealAuditLog(for fieldType: DetailFieldType) {
    teamAuditLogsService.logReveal(item, field: fieldType.auditLogField)
  }

  func sendCopyAuditLog(for fieldType: DetailFieldType) {
    teamAuditLogsService.logCopy(item, field: fieldType.auditLogField)
  }
}
