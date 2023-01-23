import Foundation
import DashlaneReportKit
import CorePersonalData

struct CredentialDetailUsageLogger {
    let usageLogService: UsageLogServiceProtocol
    let item: Credential

        func shareUsageLog() {
        let log = UsageLogCode80SharingUX(type: .newShare1,
                                          action: .open,
                                          from: .credentials)
        usageLogService.post(log)
    }

        func logAddCredential(credential: Credential) {
        let log = UsageLogCode75GeneralActions(type: "pwd_add", action: "display", website: credential.url?.displayDomain)
        usageLogService.post(log)
    }

        func logOpenUrl(credential: Credential) {
        let log = UsageLogCode75GeneralActions(type: "KWAuthentifiantIOS",
                                               subtype: "urlStringForUI",
                                               action: "click_button", website: credential.url?.displayDomain)
        usageLogService.post(log)

                let log2 = UsageLogCode75GeneralActions(type: "KWAuthentifiantIOS",
                                               action: "gotowebsite",
                                               subaction: "fromDetails",
                                               website: credential.url?.displayDomain)
        usageLogService.post(log2)
    }

        func logSavePassword(credentialsCount: Int, url: PersonalDataURL) {
        let log = UsageLogCode6SavePassword(credentials: credentialsCount,
                                            sender: "SAVE_PASSWORD",
                                            action: "add",
                                            website: url.displayDomain,
                                            url: url.rawValue)
        usageLogService.post(log)
    }

        func logPasswordDetails(credentialsCount: Int,
                            action: UsageLogCode57PasswordDetails.ActionType,
                            isDefaultName: Bool,
                            isDeleting: Bool) {
        let credentialsCount = isDeleting ? credentialsCount - 1 : credentialsCount
        let log = UsageLogCode57PasswordDetails(action: action,
                                                website: item.url?.displayDomain,
                                                identifier: item.anonId,
                                                credentials: credentialsCount,
                                                sender: .inApp,
                                                spaceId: item.spaceId,
                                                otp: item.otpURL != nil ? "1" : nil,
                                                empty_email: item.email.isEmpty,
                                                empty_login: item.login.isEmpty,
                                                empty_secondary_login: item.secondaryLogin.isEmpty,
                                                always_login: item.autoLogin,
                                                strict_domain: item.subdomainOnly,
                                                has_note_associated: !item.note.isEmpty,
                                                is_default_name: isDefaultName)
        usageLogService.post(log)
    }

    func logTapLinkedDomains() {
        let log = UsageLogCode75GeneralActions(type: "KWAuthentifiant",
                                     action: "openAssociatedDomains",
                                     subaction: "fromDetails",
                                     website: item.url?.displayDomain)
        usageLogService.post(log)
    }
}

extension CredentialDetailViewModel {
    func logPasswordDetails(isDeleting: Bool = false) {
                let hasDefaultNameFromDomain = item.title == item.url?.displayDomain

                let hasDefaultNameFromPrefilledCredential = vaultItemsService.prefilledCredentials.contains { prefilledCredential in
            prefilledCredential.title == item.title && prefilledCredential.editableURL == item.editableURL
        }

        logger.logPasswordDetails(credentialsCount: vaultItemsService.credentials.count,
                                  action: isDeleting ? .remove : (mode.isAdding ? .add : .edit),
                                  isDefaultName: hasDefaultNameFromDomain || hasDefaultNameFromPrefilledCredential,
                                  isDeleting: isDeleting)
    }
}
