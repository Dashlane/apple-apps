import Foundation
import CorePersonalData
import CoreUserTracking

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
        case .passkey:
            assertionFailure("Passkeys cannot be created manually")
            return .itemCredentialCreate
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
        case .passkey:
                        return .itemCredentialDetails
        }
    }
}

#if os(iOS)
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

        var fieldsEdited = [Definition.Field]()
        if let savedItem = savedItem as? Credential,
           let originalItem = originalItem as? Credential,
           savedItem.linkedServices != originalItem.linkedServices {
            fieldsEdited.append(.associatedWebsitesList)
            let item = item
            let fieldsEdited = fieldsEdited
            let selectedUserSpace = selectedUserSpace
            activityReporter.report(AnonymousEvent.UpdateCredential(
                action: Definition.Action.edit,
                associatedWebsitesAddedList: savedItem.linkedServices.associatedDomains.filterDomainsNotExisting(in: originalItem).ids(),
                associatedWebsitesRemovedList: originalItem.linkedServices.associatedDomains.filterDomainsNotExisting(in: savedItem).ids(),
                domain: item.hashedDomainForLogs(),
                fieldList: fieldsEdited,
                space: selectedUserSpace.logItemSpace)
            )
        }
        let itemCollections = itemCollections
        let item = item
        let fields = fieldsEdited
        let selectedUserSpace = selectedUserSpace
        activityReporter.report(UserEvent.UpdateVaultItem(
            action: action,
            collectionCount: itemCollections.count,
            fieldsEdited: fields.isEmpty ? nil : fields,
            itemId: item.userTrackingLogID,
            itemType: item.vaultItemType,
            space: selectedUserSpace.logItemSpace)
        )
    }

    private func log(itemAddedIn collection: VaultCollection) {
                if collection.items.count == 1, collection.contains(item) {
            activityReporter.report(UserEvent.UpdateCollection(
                action: .add,
                collectionId: collection.id.rawValue,
                isShared: collection.isShared,
                itemCount: 1)
            )
        }

        activityReporter.report(UserEvent.UpdateCollection(
            action: .addCredential,
            collectionId: collection.id.rawValue,
            isShared: collection.isShared,
            itemCount: 1)
        )
    }

    private func log(itemRemovedFrom collection: VaultCollection) {
        activityReporter.report(UserEvent.UpdateCollection(
            action: .deleteCredential,
            collectionId: collection.id.rawValue,
            isShared: collection.isShared,
            itemCount: 1)
        )
    }

    func logUpdate(originalCollections: [VaultCollection], collections: [VaultCollection]) {
        collections.difference(from: originalCollections).removals.forEach { removal in
            guard case .remove(_, let collection, _) = removal else { return }
            log(itemRemovedFrom: collection)
        }

        collections.difference(from: originalCollections).insertions.forEach { insertion in
            guard case .insert(_, let collection, _) = insertion else { return }
            log(itemAddedIn: collection)
        }
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
        activityReporter.report(UserEvent.CopyVaultItemField(field: fieldType.definitionField,
                                                             isProtected: isProtected,
                                                             itemId: item.userTrackingLogID,
                                                             itemType: item.vaultItemType))
        activityReporter.report(AnonymousEvent.CopyVaultItemField(domain: item.hashedDomainForLogs(),
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
        activityReporter.report(UserEvent.RevealVaultItemField(field: fieldType.definitionField,
                                                               isProtected: isProtected,
                                                               itemId: item.userTrackingLogID,
                                                               itemType: item.vaultItemType))

        guard let credential = item as? Credential else {
            return
        }
        activityReporter.report(AnonymousEvent.RevealVaultItemField(domain: credential.hashedDomainForLogs(),
                                                                    field: fieldType.definitionField,
                                                                    itemType: item.vaultItemType))
    }
}

private extension [LinkedServices.AssociatedDomain] {
    func filterDomainsNotExisting(in credential: Credential) -> [Definition.Domain] {
        self.filter({
            !credential.linkedServices.associatedDomains.contains($0)
        })
        .map({ $0.domain.hashedDomainForLogs() })
    }
}

private extension [Definition.Domain] {
    func ids() -> [String] {
        compactMap({ $0.id })
    }
}
#endif
