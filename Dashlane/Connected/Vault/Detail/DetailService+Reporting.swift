import Foundation
import CoreUserTracking
import DashlaneAppKit
import DashlaneReportKit
import CorePersonalData
import VaultKit

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
        case .drivingLicence:
            return .itemDriverLicenceCreate
        }

    }
    var defaultPage: Page {
        switch self {
        case .credential:
            return  .itemCredentialDetails
        case .secureNote:
            return  .itemSecureNoteDetails
        case .bankAccount:
            return  .itemBankStatementDetails
        case .creditCard:
            return  .itemCreditCardDetails
        case .identity:
            return  .itemIdentityDetails
        case .email:
            return  .itemEmailDetails
        case .phone:
            return  .itemPhoneDetails
        case .address:
            return  .itemAddressDetails
        case .company:
            return  .itemCompanyDetails
        case .personalWebsite:
            return  .itemWebsiteDetails
        case .passport:
            return  .itemPassportDetails
        case .idCard:
            return  .itemIdCardDetails
        case .fiscalInformation:
            return  .itemFiscalStatementDetails
        case .socialSecurityInformation:
            return  .itemSocialSecurityStatementDetails
        case .drivingLicence:
            return  .itemDriverLicenceDetails
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

    func logUpdate(of savedItem: VaultItem) {
        let action: Definition.Action = mode.isAdding ? .add : .edit
        self.usageLogger.logUpdate(for: item, from: .inApp)

        var fieldsEdited = [Definition.Field]()
        if let savedItem = savedItem as? Credential, let originalItem = originalItem as? Credential, savedItem.linkedServices != originalItem.linkedServices {
            fieldsEdited.append(.associatedWebsitesList)

            let addedWebsites = savedItem.linkedServices.associatedDomains.filter {
                !originalItem.linkedServices.associatedDomains.contains($0)
            }.compactMap { $0.domain.hashedDomainForLogs.id }

            let removedWebsites = originalItem.linkedServices.associatedDomains.filter {
                !savedItem.linkedServices.associatedDomains.contains($0)
            }.compactMap { $0.domain.hashedDomainForLogs.id }

            self.activityReporter.report(AnonymousEvent.UpdateCredential(action: Definition.Action.edit,
                                                                         associatedWebsitesAddedList: addedWebsites,
                                                                         associatedWebsitesRemovedList: removedWebsites,
                                                                         domain: item.hashedDomainForLogs,
                                                                         fieldList: fieldsEdited,
                                                                         space: selectedUserSpace.logItemSpace))

        }

        self.activityReporter.report(UserEvent.UpdateVaultItem(action: action,
                                                               fieldsEdited: fieldsEdited.isEmpty ? nil : fieldsEdited,
                                                               itemId: item.userTrackingLogID,
                                                               itemType: item.vaultItemType,
                                                               space: selectedUserSpace.logItemSpace))
    }
}

extension DetailService {
    func sendCopyUsageLog(fieldType: DetailFieldType) {
        var action  = "copy"
        if let isUniversalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled],
           isUniversalClipboardEnabled {
            action += "Universal"
        }
        var website: String?
        if let item = item as? Credential {
            website = item.url?.domain?.name
        }
        usageLogService.post(UsageLogCode75GeneralActions(type: item.usageLogType75,
                                                          subtype: fieldType.rawValue,
                                                          action: action,
                                                          subaction: "fromDetails",
                                                          website: website))
        var isProtected = false
        if let secureItem = item as? SecureItem {
            isProtected = secureItem.secured
        }
        activityReporter.report(UserEvent.CopyVaultItemField(field: fieldType.definitionField,
                                                             isProtected: isProtected,
                                                             itemId: item.userTrackingLogID,
                                                             itemType: item.vaultItemType))
        activityReporter.report(AnonymousEvent.CopyVaultItemField(domain: item.hashedDomainForLogs,
                                                                  field: fieldType.definitionField,
                                                                  itemType: item.vaultItemType))
    }

    func sendViewUsageLog(for fieldType: DetailFieldType) {
        var website: String?
        var domain: Definition.Domain?
        if let item = item as? Credential {
            website = item.url?.domain?.name
            domain = item.hashedDomainForLogs
        }
        usageLogService.post(UsageLogCode75GeneralActions(type: item.usageLogType75,
                                                          subtype: fieldType.rawValue,
                                                          action: "show",
                                                          subaction: "fromDetails",
                                                          website: website))

        var isProtected = false
        if let secureItem = item as? SecureItem {
            isProtected = secureItem.secured
        }
        activityReporter.report(UserEvent.RevealVaultItemField(field: fieldType.definitionField,
                                                               isProtected: isProtected,
                                                               itemId: item.userTrackingLogID,
                                                               itemType: item.vaultItemType))

        if let domain = domain {
            activityReporter.report(AnonymousEvent.RevealVaultItemField(domain: domain,
                                                                        field: fieldType.definitionField,
                                                                        itemType: item.vaultItemType))
        }
    }
}
