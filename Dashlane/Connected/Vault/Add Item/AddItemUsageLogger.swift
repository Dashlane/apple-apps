import Foundation
import DashlaneReportKit
import CorePersonalData
import DashlaneAppKit
import VaultKit

struct AddItemUsageLogger {
    let usageLogService: UsageLogServiceProtocol

        func logAddItem(itemType: VaultItem.Type) {
        guard let action = action(from: itemType) else { return }
        let log = UsageLogCode75GeneralActions(type: "itemList", action: action, subaction: "fromDashboard")
        usageLogService.post(log)
    }

        func logTapAddItem() {
        let log = UsageLogCode75GeneralActions(type: "dashboard", action: "click", subaction: "addItem")
        usageLogService.post(log)
    }

    private func action(from type: VaultItem.Type) -> String? {
        switch type {
        case is Address.Type:
            return "AddAddress"
        case is BankAccount.Type:
            return "AddBankStatement"
        case is Company.Type:
            return "AddCompany"
        case is CreditCard.Type:
            return "AddCreditCard"
        case is DrivingLicence.Type:
            return "AddDriverLicense"
        case is Email.Type:
            return "AddEmail"
        case is FiscalInformation.Type:
            return "AddFiscalStatement"
        case is IDCard.Type:
            return "AddIdCard"
        case is Identity.Type:
            return "AddIdentity"
        case is Passport.Type:
            return "AddPassport"
        case is PersonalWebsite.Type:
            return "AddPersonalWebsite"
        case is Phone.Type:
            return "AddPhone"
        case is SecureNote.Type:
            return "AddSecureNote"
        case is SocialSecurityInformation.Type:
            return "AddSocialSecurity"
        case is Credential.Type:
            return "AddPassword"
        default:
            return nil
        }

    }
}
