import Foundation

public extension CharonDataAPIClient {

    struct Properties {

        public struct Empty: Codable {
            public var name: String?
        }

        public struct AnyWithItemID: Codable {
            public var name: String
            public var itemId: String
        }

        public struct PageView: Codable {
            public var name = "view_page"

            public init() {}
        }

                public struct Login: Codable {
            public var name = "login"
            public var status: String?
            public var mode: String?
            public var isFirstLogin: Bool?
            public var isBackupCode: Bool?
            public var verificationMode: String?

            public init(status: String? = nil, mode: String? = nil, isFirstLogin: Bool? = nil, isBackupCode: Bool? = nil, verificationMode: String? = nil) {
                self.status = status
                self.mode = mode
                self.isFirstLogin = isFirstLogin
                self.isBackupCode = isBackupCode
                self.verificationMode = verificationMode
            }
        }

        public struct Logout: Codable {
            public var name = "logout"

            public init() { }
        }

        public struct CreateAccount: Codable {
            public var name = "create_account"
            public var isMarketingOptIn: Bool?
            public var status: String?

            public init(isMarketingOptIn: Bool? = nil, status: String? = nil) {
                self.isMarketingOptIn = isMarketingOptIn
                self.status = status
            }
        }

        public struct UseAnotherAccount: Codable {
            public var name = "use_another_account"

            public init() { }
        }

        public struct AskAuthentication: Codable {
            public var name = "ask_authentication"
            public var mode: String?
            public var reason: String?
            public var verificationMode: String?

            public init(mode: String? = nil, reason: String? = nil, verificationMode: String? = nil) {
                self.mode = mode
                self.reason = reason
                self.verificationMode = verificationMode
            }
        }

        public struct AskUseOtherAuthentication: Codable {
            public var name = "ask_use_other_authentication"
            public var next: String?
            public var previous: String?

            public init(next: String? = nil, previous: String? = nil) {
                self.next = next
                self.previous = previous
            }
        }

        public struct ResendToken: Codable {
            public var name = "resend_token"

            public init() { }
        }

        public struct ForgetMasterPassword: Codable {
            public var name = "forget_master_password"
            public var hasBiometricReset: Bool?
            public var hasTeamAccountRecovery: Bool?

            public init(hasBiometricReset: Bool? = nil, hasTeamAccountRecovery: Bool? = nil) {
                self.hasBiometricReset = hasBiometricReset
                self.hasTeamAccountRecovery = hasTeamAccountRecovery
            }
        }

        public struct ChangeMP: Codable {
            public var name = "change_master_password"
            public var flowStep: String?

            public init(flowStep: String? = nil) {
                self.flowStep = flowStep
            }
        }

                public struct PerformAutofill: Codable {
            public var name = "perform_autofill"
            public var autofillMechanism: String?
            public var autofillOrigin: String?
            public var formTypeList: [String]?
            public var isAutologin: Bool?
            public var isManual: Bool?
            public var isNativeApp: Bool?
            public var matchType: String?
            public var domain: Domain?

            public init(autofillMechanism: String? = nil, autofillOrigin: String? = nil, formTypeList: [String]? = nil, isAutologin: Bool? = nil, isManual: Bool? = nil, isNativeApp: Bool? = nil, matchType: String? = nil, domain: Domain? = nil) {
                self.autofillMechanism = autofillMechanism
                self.autofillOrigin = autofillOrigin
                self.formTypeList = formTypeList
                self.isAutologin = isAutologin
                self.isManual = isManual
                self.isNativeApp = isNativeApp
                self.matchType = matchType
                self.domain = domain
            }
        }

        public struct CallToAction: Codable {
            public var name = "call_to_action"
            public var callToActionList: [String]?
            public var chosenAction: String?
            public var hasChosenNoAction: Bool?

            public init(callToActionList: [String]? = nil, chosenAction: String? = nil, hasChosenNoAction: Bool? = nil) {
                self.callToActionList = callToActionList
                self.chosenAction = chosenAction
                self.hasChosenNoAction = hasChosenNoAction
            }
        }

                public struct UpdateCredential: Codable {
            public var name = "update_credential"
            public var action: String?
            public var space: String?
            public var fieldList: [String]?
            public var associatedWebsitesAddedList: [String]?
            public var associatedWebsitesRemovedList: [String]?
            public var domain: Domain?

            public init(action: String? = nil, space: String? = nil, fieldList: [String]? = nil, associatedWebsitesAddedList: [String]? = nil, associatedWebsitesRemovedList: [String]? = nil, domain: Domain? = nil) {
                self.action = action
                self.space = space
                self.fieldList = fieldList
                self.associatedWebsitesAddedList = associatedWebsitesAddedList
                self.associatedWebsitesRemovedList = associatedWebsitesRemovedList
                self.domain = domain
            }
        }

        public struct Domain: Codable {
            public var id: String?
            public var type: String?

            public init(id: String? = nil, type: String? = nil) {
                self.id = id
                self.type = type
            }
        }

        public struct UpdateVaultItem: Codable {
            public var name = "update_vault_item"
            public var action: String?
            public var fieldsEdited: [String]?
            public var itemType: String?
            public var space: String?
            public var updateCredentialOrigin: String?
            public var itemId: String?

            public init(action: String? = nil, fieldsEdited: [String]? = nil, itemType: String? = nil, space: String? = nil, updateCredentialOrigin: String? = nil, itemId: String? = nil) {
                self.action = action
                self.fieldsEdited = fieldsEdited
                self.itemType = itemType
                self.space = space
                self.updateCredentialOrigin = updateCredentialOrigin
                self.itemId = itemId
            }
        }

        public struct SelectVaultItem: Codable {
            public var name = "select_vault_item"
            public var itemType: String?
            public var highlight: String?
            public var totalCount: Int?

            public init(itemType: String? = nil, highlight: String? = nil, totalCount: Int? = nil) {
                self.itemType = itemType
                self.highlight = highlight
                self.totalCount = totalCount
            }
        }

        public struct CopyVaultItemField: Codable {
            public var name = "copy_vault_item_field"
            public var itemType: String?
            public var field: String?
            public var isProtected: Bool?
            public var itemId: String?

            public init(itemType: String? = nil, field: String? = nil, isProtected: Bool? = nil, itemId: String? = nil) {
                self.itemType = itemType
                self.field = field
                self.isProtected = isProtected
                self.itemId = itemId
            }
        }

        public struct RevealVaultItemField: Codable {
            public var name = "reveal_vault_item_field"
            public var itemType: String?
            public var field: String?
            public var isProtected: Bool?
            public var itemId: String?

            public init(itemType: String? = nil, field: String? = nil, isProtected: Bool? = nil, itemId: String? = nil) {
                self.itemType = itemType
                self.field = field
                self.isProtected = isProtected
                self.itemId = itemId
            }
        }

        public struct OpenExternalVaultItemLink: Codable {
            public var name = "open_external_vault_item_link"
            public var itemType: String
            public var domainType: String?

            public init(itemType: String, domainType: String? = nil) {
                self.itemType = itemType
                self.domainType = domainType
            }
        }

        public struct OpenExternalVaultItemLinkAnonymous: Codable {
            public var name = "open_external_vault_item_link"
            public var itemType: String
            public var domain: String?

            public init(itemType: String, domain: String? = nil) {
                self.itemType = itemType
                self.domain = domain
            }
        }

        public struct ViewVaultItemAttachment: Codable {
            public var name = "view_vault_item_attachment"
            public var itemType: String?
            public var itemId: String?

            public init(itemType: String? = nil, itemId: String? = nil) {
                self.itemType = itemType
                self.itemId = itemId
            }
        }

        public struct UpdateVaultItemAttachment: Codable {
            public var name = "update_vault_item_attachment"
            public var itemType: String?
            public var attachmentAction: String?
            public var itemId: String?

            public init(itemType: String? = nil, attachmentAction: String? = nil, itemId: String? = nil) {
                self.itemType = itemType
                self.attachmentAction = attachmentAction
                self.itemId = itemId
            }
        }

        public struct SelectSpace: Codable {
            public var name = "select_space"
            public var space: String?

            public init(space: String? = nil) {
                self.space = space
            }
        }

                public struct ExportData: Codable {
            public var name = "export_data"
            public var backupFileType: String?

            public init(backupFileType: String? = nil) {
                self.backupFileType = backupFileType
            }
        }

        public struct ImportData: Codable {
            public var name = "import_data"
            public var backupFileType: String?
            public var importDataStatus: String?
            public var importSource: String?

            public init(backupFileType: String? = nil, importDataStatus: String? = nil, importSource: String? = nil) {
                self.backupFileType = backupFileType
                self.importDataStatus = importDataStatus
                self.importSource = importSource
            }
        }

                public struct VersionValidity: Codable {
            public var name = "show_version_validity_message"
            public var isUpdatePossible: Bool?
            public var versionValidityStatus: String?

            public init(isUpdatePossible: Bool? = nil, versionValidityStatus: String? = nil) {
                self.isUpdatePossible = isUpdatePossible
                self.versionValidityStatus = versionValidityStatus
            }
        }

        public struct GeneratePassword: Codable {
            public var name = "generate_password"
            public var length: Int?
            public var hasDigits: Bool?
            public var hasLetters: Bool?
            public var hasSymbols: Bool?
            public var hasSimilar: Bool?

            public init(length: Int? = nil, hasDigits: Bool? = nil, hasLetters: Bool? = nil, hasSymbols: Bool? = nil, hasSimilar: Bool? = nil) {
                self.length = length
                self.hasDigits = hasDigits
                self.hasLetters = hasLetters
                self.hasSymbols = hasSymbols
                self.hasSimilar = hasSimilar
            }
        }

    }

}
