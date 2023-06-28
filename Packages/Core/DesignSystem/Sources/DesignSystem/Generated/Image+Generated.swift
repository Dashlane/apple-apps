import SwiftUI

extension Image {
    public enum ds {
        public enum accountSettings {
            public static let filled = Image("account-settings/filled")
            public static let outlined = Image("account-settings/outlined")
        }
        public enum action {
            public enum add {
                public static let outlined = Image("action/add/outlined")
            }
            public enum clearContent {
                public static let filled = Image("action/clear-content/filled")
            }
            public enum close {
                public static let outlined = Image("action/close/outlined")
            }
            public enum copy {
                public static let filled = Image("action/copy/filled")
                public static let outlined = Image("action/copy/outlined")
            }
            public enum delete {
                public static let filled = Image("action/delete/filled")
                public static let outlined = Image("action/delete/outlined")
            }
            public enum edit {
                public static let filled = Image("action/edit/filled")
                public static let outlined = Image("action/edit/outlined")
            }
            public enum hide {
                public static let filled = Image("action/hide/filled")
                public static let outlined = Image("action/hide/outlined")
            }
            public enum more {
                public static let outlined = Image("action/more/outlined")
            }
            public enum moreEmphasized {
                public static let outlined = Image("action/more-emphasized/outlined")
            }
            public enum openExternalLink {
                public static let outlined = Image("action/open-external-link/outlined")
            }
            public enum refer {
                public static let outlined = Image("action/refer/outlined")
            }
            public enum refresh {
                public static let outlined = Image("action/refresh/outlined")
            }
            public enum reveal {
                public static let filled = Image("action/reveal/filled")
                public static let outlined = Image("action/reveal/outlined")
            }
            public enum revoke {
                public static let filled = Image("action/revoke/filled")
                public static let outlined = Image("action/revoke/outlined")
            }
            public enum search {
                public static let outlined = Image("action/search/outlined")
            }
            public enum share {
                public static let filled = Image("action/share/filled")
                public static let outlined = Image("action/share/outlined")
            }
            public enum sort {
                public static let outlined = Image("action/sort/outlined")
            }
            public enum subtract {
                public static let outlined = Image("action/subtract/outlined")
            }
            public enum undo {
                public static let outlined = Image("action/undo/outlined")
            }
        }
        public enum activityLog {
            public static let outlined = Image("activity-log/outlined")
        }
        public enum arrowDown {
            public static let outlined = Image("arrow-down/outlined")
        }
        public enum arrowLeft {
            public static let outlined = Image("arrow-left/outlined")
        }
        public enum arrowRight {
            public static let outlined = Image("arrow-right/outlined")
        }
        public enum arrowUp {
            public static let outlined = Image("arrow-up/outlined")
        }
        public enum attachment {
            public static let outlined = Image("attachment/outlined")
        }
        public enum caretDown {
            public static let outlined = Image("caret-down/outlined")
        }
        public enum caretLeft {
            public static let outlined = Image("caret-left/outlined")
        }
        public enum caretRight {
            public static let outlined = Image("caret-right/outlined")
        }
        public enum caretUp {
            public static let outlined = Image("caret-up/outlined")
        }
        public enum checkmark {
            public static let outlined = Image("checkmark/outlined")
        }
        public enum configure {
            public static let outlined = Image("configure/outlined")
        }
        public enum csv {
            public static let filled = Image("csv/filled")
            public static let outlined = Image("csv/outlined")
        }
        public enum dashboard {
            public static let outlined = Image("dashboard/outlined")
        }
        public enum download {
            public static let outlined = Image("download/outlined")
        }
        public enum downloadCloud {
            public static let outlined = Image("download-cloud/outlined")
        }
        public enum faceId {
            public static let outlined = Image("face-id/outlined")
        }
        public enum feature {
            public enum authenticator {
                public static let filled = Image("feature/authenticator/filled")
                public static let outlined = Image("feature/authenticator/outlined")
            }
            public enum autofill {
                public static let outlined = Image("feature/autofill/outlined")
            }
            public enum darkWebMonitoring {
                public static let outlined = Image("feature/dark-web-monitoring/outlined")
            }
            public enum inboxScan {
                public static let outlined = Image("feature/inbox-scan/outlined")
            }
            public enum passwordGenerator {
                public static let filled = Image("feature/password-generator/filled")
                public static let outlined = Image("feature/password-generator/outlined")
            }
            public enum passwordHealth {
                public static let outlined = Image("feature/password-health/outlined")
            }
            public enum vpn {
                public static let filled = Image("feature/vpn/filled")
                public static let outlined = Image("feature/vpn/outlined")
            }
        }
        public enum feedback {
            public enum fail {
                public static let filled = Image("feedback/fail/filled")
                public static let outlined = Image("feedback/fail/outlined")
            }
            public enum help {
                public static let filled = Image("feedback/help/filled")
                public static let outlined = Image("feedback/help/outlined")
            }
            public enum info {
                public static let filled = Image("feedback/info/filled")
                public static let outlined = Image("feedback/info/outlined")
            }
            public enum success {
                public static let filled = Image("feedback/success/filled")
                public static let outlined = Image("feedback/success/outlined")
            }
            public enum warning {
                public static let filled = Image("feedback/warning/filled")
                public static let outlined = Image("feedback/warning/outlined")
            }
        }
        public enum fingerprint {
            public static let outlined = Image("fingerprint/outlined")
        }
        public enum folder {
            public static let filled = Image("folder/filled")
            public static let outlined = Image("folder/outlined")
        }
        public enum googleChrome {
            public static let outlined = Image("google-chrome/outlined")
        }
        public enum group {
            public static let filled = Image("group/filled")
            public static let outlined = Image("group/outlined")
        }
        public enum healthNegative {
            public static let outlined = Image("health-negative/outlined")
        }
        public enum healthPositive {
            public static let outlined = Image("health-positive/outlined")
        }
        public enum healthUnknown {
            public static let outlined = Image("health-unknown/outlined")
        }
        public enum historyBackup {
            public static let outlined = Image("history-backup/outlined")
        }
        public enum home {
            public static let filled = Image("home/filled")
            public static let outlined = Image("home/outlined")
        }
        public enum item {
            public enum bankAccount {
                public static let filled = Image("item/bank-account/filled")
                public static let outlined = Image("item/bank-account/outlined")
            }
            public enum company {
                public static let filled = Image("item/company/filled")
                public static let outlined = Image("item/company/outlined")
            }
            public enum driversLicense {
                public static let outlined = Image("item/drivers-license/outlined")
            }
            public enum email {
                public static let filled = Image("item/email/filled")
                public static let outlined = Image("item/email/outlined")
            }
            public enum id {
                public static let filled = Image("item/id/filled")
                public static let outlined = Image("item/id/outlined")
            }
            public enum login {
                public static let filled = Image("item/login/filled")
                public static let outlined = Image("item/login/outlined")
            }
            public enum passport {
                public static let filled = Image("item/passport/filled")
                public static let outlined = Image("item/passport/outlined")
            }
            public enum payment {
                public static let filled = Image("item/payment/filled")
                public static let outlined = Image("item/payment/outlined")
            }
            public enum personalInfo {
                public static let filled = Image("item/personal-info/filled")
                public static let outlined = Image("item/personal-info/outlined")
            }
            public enum phoneHome {
                public static let filled = Image("item/phone-home/filled")
                public static let outlined = Image("item/phone-home/outlined")
            }
            public enum phoneMobile {
                public static let filled = Image("item/phone-mobile/filled")
                public static let outlined = Image("item/phone-mobile/outlined")
            }
            public enum secureNote {
                public static let filled = Image("item/secure-note/filled")
                public static let outlined = Image("item/secure-note/outlined")
            }
            public enum socialSecurity {
                public static let filled = Image("item/social-security/filled")
                public static let outlined = Image("item/social-security/outlined")
            }
            public enum taxNumber {
                public static let filled = Image("item/tax-number/filled")
                public static let outlined = Image("item/tax-number/outlined")
            }
        }
        public enum itemColor {
            public static let filled = Image("item-color/filled")
            public static let outlined = Image("item-color/outlined")
        }
        public enum laptop {
            public static let filled = Image("laptop/filled")
            public static let outlined = Image("laptop/outlined")
        }
        public enum laptopCheckmark {
            public static let filled = Image("laptop-checkmark/filled")
            public static let outlined = Image("laptop-checkmark/outlined")
        }
        public enum link {
            public static let outlined = Image("link/outlined")
        }
        public enum lock {
            public static let filled = Image("lock/filled")
            public static let outlined = Image("lock/outlined")
        }
        public enum logOut {
            public static let outlined = Image("log-out/outlined")
        }
        public enum menu {
            public static let outlined = Image("menu/outlined")
        }
        public enum muteAutofill {
            public static let outlined = Image("mute-autofill/outlined")
        }
        public enum noNetwork {
            public static let outlined = Image("no-network/outlined")
        }
        public enum notification {
            public static let filled = Image("notification/filled")
            public static let outlined = Image("notification/outlined")
        }
        public enum passkey {
            public static let outlined = Image("passkey/outlined")
        }
        public enum premiumStar {
            public static let filled = Image("premium-star/filled")
            public static let outlined = Image("premium-star/outlined")
        }
        public enum protection {
            public static let filled = Image("protection/filled")
            public static let outlined = Image("protection/outlined")
        }
        public enum recoveryKey {
            public static let outlined = Image("recovery-key/outlined")
        }
        public enum settings {
            public static let filled = Image("settings/filled")
            public static let outlined = Image("settings/outlined")
        }
        public enum shared {
            public static let filled = Image("shared/filled")
            public static let outlined = Image("shared/outlined")
        }
        public enum shortcut {
            public enum command {
                public static let outlined = Image("shortcut/command/outlined")
            }
            public enum optionAlt {
                public static let outlined = Image("shortcut/option-alt/outlined")
            }
            public enum shift {
                public static let outlined = Image("shortcut/shift/outlined")
            }
        }
        public enum social {
            public enum facebook {
                public static let filled = Image("social/facebook/filled")
            }
            public enum instagram {
                public static let filled = Image("social/instagram/filled")
            }
            public enum linkedin {
                public static let filled = Image("social/linkedin/filled")
            }
            public enum reddit {
                public static let filled = Image("social/reddit/filled")
            }
            public enum twitter {
                public static let filled = Image("social/twitter/filled")
            }
            public enum youtube {
                public static let filled = Image("social/youtube/filled")
            }
        }
        public enum spaces {
            public enum all {
                public static let outlined = Image("spaces/all/outlined")
            }
        }
        public enum tip {
            public static let filled = Image("tip/filled")
            public static let outlined = Image("tip/outlined")
        }
        public enum tools {
            public static let filled = Image("tools/filled")
            public static let outlined = Image("tools/outlined")
        }
        public enum unlock {
            public static let filled = Image("unlock/filled")
            public static let outlined = Image("unlock/outlined")
        }
        public enum upload {
            public static let outlined = Image("upload/outlined")
        }
        public enum uploadCloud {
            public static let outlined = Image("upload-cloud/outlined")
        }
        public enum users {
            public static let outlined = Image("users/outlined")
        }
        public enum vault {
            public static let filled = Image("vault/filled")
            public static let outlined = Image("vault/outlined")
        }
        public enum web {
            public static let filled = Image("web/filled")
            public static let outlined = Image("web/outlined")
        }
        public enum yubikey {
            public static let filled = Image("yubikey/filled")
            public static let outlined = Image("yubikey/outlined")
        }
    }
}

fileprivate extension Image {
    init(_ name: String) {
        self.init(name, bundle: Bundle.module)
    }
}
