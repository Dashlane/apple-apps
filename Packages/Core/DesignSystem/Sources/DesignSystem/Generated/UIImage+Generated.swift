#if os(iOS)
  import UIKit

  extension UIImage {
    public enum ds {
      public enum accountSettings {
        public static let filled = UIImage("account-settings/filled")
        public static let outlined = UIImage("account-settings/outlined")
      }
      public enum action {
        public enum add {
          public static let outlined = UIImage("action/add/outlined")
        }
        public enum clearContent {
          public static let filled = UIImage("action/clear-content/filled")
        }
        public enum close {
          public static let outlined = UIImage("action/close/outlined")
        }
        public enum copy {
          public static let filled = UIImage("action/copy/filled")
          public static let outlined = UIImage("action/copy/outlined")
        }
        public enum delete {
          public static let filled = UIImage("action/delete/filled")
          public static let outlined = UIImage("action/delete/outlined")
        }
        public enum edit {
          public static let filled = UIImage("action/edit/filled")
          public static let outlined = UIImage("action/edit/outlined")
        }
        public enum hide {
          public static let filled = UIImage("action/hide/filled")
          public static let outlined = UIImage("action/hide/outlined")
        }
        public enum more {
          public static let outlined = UIImage("action/more/outlined")
        }
        public enum moreEmphasized {
          public static let outlined = UIImage("action/more-emphasized/outlined")
        }
        public enum openExternalLink {
          public static let outlined = UIImage("action/open-external-link/outlined")
        }
        public enum refer {
          public static let outlined = UIImage("action/refer/outlined")
        }
        public enum refresh {
          public static let outlined = UIImage("action/refresh/outlined")
        }
        public enum reveal {
          public static let filled = UIImage("action/reveal/filled")
          public static let outlined = UIImage("action/reveal/outlined")
        }
        public enum revoke {
          public static let filled = UIImage("action/revoke/filled")
          public static let outlined = UIImage("action/revoke/outlined")
        }
        public enum search {
          public static let outlined = UIImage("action/search/outlined")
        }
        public enum share {
          public static let filled = UIImage("action/share/filled")
          public static let outlined = UIImage("action/share/outlined")
        }
        public enum sort {
          public static let outlined = UIImage("action/sort/outlined")
        }
        public enum subtract {
          public static let outlined = UIImage("action/subtract/outlined")
        }
        public enum undo {
          public static let outlined = UIImage("action/undo/outlined")
        }
      }
      public enum activityLog {
        public static let outlined = UIImage("activity-log/outlined")
      }
      public enum arrowDown {
        public static let outlined = UIImage("arrow-down/outlined")
      }
      public enum arrowLeft {
        public static let outlined = UIImage("arrow-left/outlined")
      }
      public enum arrowRight {
        public static let outlined = UIImage("arrow-right/outlined")
      }
      public enum arrowUp {
        public static let outlined = UIImage("arrow-up/outlined")
      }
      public enum attachment {
        public static let outlined = UIImage("attachment/outlined")
      }
      public enum business {
        public static let outlined = UIImage("business/outlined")
      }
      public enum calendar {
        public static let outlined = UIImage("calendar/outlined")
      }
      public enum caretDoubleLeft {
        public static let outlined = UIImage("caret-double-left/outlined")
      }
      public enum caretDoubleRight {
        public static let outlined = UIImage("caret-double-right/outlined")
      }
      public enum caretDown {
        public static let outlined = UIImage("caret-down/outlined")
      }
      public enum caretLeft {
        public static let outlined = UIImage("caret-left/outlined")
      }
      public enum caretRight {
        public static let outlined = UIImage("caret-right/outlined")
      }
      public enum caretUp {
        public static let outlined = UIImage("caret-up/outlined")
      }
      public enum chat {
        public static let outlined = UIImage("chat/outlined")
      }
      public enum checkmark {
        public static let outlined = UIImage("checkmark/outlined")
      }
      public enum collection {
        public static let outlined = UIImage("collection/outlined")
      }
      public enum configure {
        public static let outlined = UIImage("configure/outlined")
      }
      public enum csv {
        public static let filled = UIImage("csv/filled")
        public static let outlined = UIImage("csv/outlined")
      }
      public enum dashboard {
        public static let outlined = UIImage("dashboard/outlined")
      }
      public enum download {
        public static let outlined = UIImage("download/outlined")
      }
      public enum downloadCloud {
        public static let outlined = UIImage("download-cloud/outlined")
      }
      public enum faceId {
        public static let outlined = UIImage("face-id/outlined")
      }
      public enum feature {
        public enum authenticator {
          public static let filled = UIImage("feature/authenticator/filled")
          public static let outlined = UIImage("feature/authenticator/outlined")
        }
        public enum autofill {
          public static let outlined = UIImage("feature/autofill/outlined")
        }
        public enum automations {
          public static let outlined = UIImage("feature/automations/outlined")
        }
        public enum darkWebMonitoring {
          public static let outlined = UIImage("feature/dark-web-monitoring/outlined")
        }
        public enum inboxScan {
          public static let outlined = UIImage("feature/inbox-scan/outlined")
        }
        public enum passwordGenerator {
          public static let filled = UIImage("feature/password-generator/filled")
          public static let outlined = UIImage("feature/password-generator/outlined")
        }
        public enum passwordHealth {
          public static let outlined = UIImage("feature/password-health/outlined")
        }
        public enum vpn {
          public static let filled = UIImage("feature/vpn/filled")
          public static let outlined = UIImage("feature/vpn/outlined")
        }
      }
      public enum feedback {
        public enum fail {
          public static let filled = UIImage("feedback/fail/filled")
          public static let outlined = UIImage("feedback/fail/outlined")
        }
        public enum help {
          public static let filled = UIImage("feedback/help/filled")
          public static let outlined = UIImage("feedback/help/outlined")
        }
        public enum info {
          public static let filled = UIImage("feedback/info/filled")
          public static let outlined = UIImage("feedback/info/outlined")
        }
        public enum success {
          public static let filled = UIImage("feedback/success/filled")
          public static let outlined = UIImage("feedback/success/outlined")
        }
        public enum warning {
          public static let filled = UIImage("feedback/warning/filled")
          public static let outlined = UIImage("feedback/warning/outlined")
        }
      }
      public enum fingerprint {
        public static let outlined = UIImage("fingerprint/outlined")
      }
      public enum folder {
        public static let filled = UIImage("folder/filled")
        public static let outlined = UIImage("folder/outlined")
      }
      public enum formatting {
        public enum bold {
          public static let outlined = UIImage("formatting/bold/outlined")
        }
        public enum code {
          public static let outlined = UIImage("formatting/code/outlined")
        }
        public enum heading1 {
          public static let outlined = UIImage("formatting/heading1/outlined")
        }
        public enum heading2 {
          public static let outlined = UIImage("formatting/heading2/outlined")
        }
        public enum heading3 {
          public static let outlined = UIImage("formatting/heading3/outlined")
        }
        public enum italic {
          public static let outlined = UIImage("formatting/italic/outlined")
        }
      }
      public enum geolocation {
        public static let outlined = UIImage("geolocation/outlined")
      }
      public enum googleChrome {
        public static let outlined = UIImage("google-chrome/outlined")
      }
      public enum group {
        public static let filled = UIImage("group/filled")
        public static let outlined = UIImage("group/outlined")
      }
      public enum healthNegative {
        public static let outlined = UIImage("health-negative/outlined")
      }
      public enum healthPositive {
        public static let outlined = UIImage("health-positive/outlined")
      }
      public enum healthUnknown {
        public static let outlined = UIImage("health-unknown/outlined")
      }
      public enum historyBackup {
        public static let outlined = UIImage("history-backup/outlined")
      }
      public enum home {
        public static let filled = UIImage("home/filled")
        public static let outlined = UIImage("home/outlined")
      }
      public enum item {
        public enum bankAccount {
          public static let filled = UIImage("item/bank-account/filled")
          public static let outlined = UIImage("item/bank-account/outlined")
        }
        public enum company {
          public static let filled = UIImage("item/company/filled")
          public static let outlined = UIImage("item/company/outlined")
        }
        public enum driversLicense {
          public static let outlined = UIImage("item/drivers-license/outlined")
        }
        public enum email {
          public static let filled = UIImage("item/email/filled")
          public static let outlined = UIImage("item/email/outlined")
        }
        public enum fax {
          public static let outlined = UIImage("item/fax/outlined")
        }
        public enum id {
          public static let filled = UIImage("item/id/filled")
          public static let outlined = UIImage("item/id/outlined")
        }
        public enum login {
          public static let filled = UIImage("item/login/filled")
          public static let outlined = UIImage("item/login/outlined")
        }
        public enum passport {
          public static let filled = UIImage("item/passport/filled")
          public static let outlined = UIImage("item/passport/outlined")
        }
        public enum payment {
          public static let filled = UIImage("item/payment/filled")
          public static let outlined = UIImage("item/payment/outlined")
        }
        public enum personalInfo {
          public static let filled = UIImage("item/personal-info/filled")
          public static let outlined = UIImage("item/personal-info/outlined")
        }
        public enum phoneHome {
          public static let filled = UIImage("item/phone-home/filled")
          public static let outlined = UIImage("item/phone-home/outlined")
        }
        public enum phoneMobile {
          public static let filled = UIImage("item/phone-mobile/filled")
          public static let outlined = UIImage("item/phone-mobile/outlined")
        }
        public enum secret {
          public static let outlined = UIImage("item/secret/outlined")
        }
        public enum secureNote {
          public static let filled = UIImage("item/secure-note/filled")
          public static let outlined = UIImage("item/secure-note/outlined")
        }
        public enum socialSecurity {
          public static let filled = UIImage("item/social-security/filled")
          public static let outlined = UIImage("item/social-security/outlined")
        }
        public enum taxNumber {
          public static let filled = UIImage("item/tax-number/filled")
          public static let outlined = UIImage("item/tax-number/outlined")
        }
      }
      public enum itemColor {
        public static let filled = UIImage("item-color/filled")
        public static let outlined = UIImage("item-color/outlined")
      }
      public enum laptop {
        public static let filled = UIImage("laptop/filled")
        public static let outlined = UIImage("laptop/outlined")
      }
      public enum laptopCheckmark {
        public static let filled = UIImage("laptop-checkmark/filled")
        public static let outlined = UIImage("laptop-checkmark/outlined")
      }
      public enum link {
        public static let outlined = UIImage("link/outlined")
      }
      public enum lock {
        public static let filled = UIImage("lock/filled")
        public static let outlined = UIImage("lock/outlined")
      }
      public enum logOut {
        public static let outlined = UIImage("log-out/outlined")
      }
      public enum menu {
        public static let outlined = UIImage("menu/outlined")
      }
      public enum muteAutofill {
        public static let outlined = UIImage("mute-autofill/outlined")
      }
      public enum noNetwork {
        public static let outlined = UIImage("no-network/outlined")
      }
      public enum notification {
        public static let filled = UIImage("notification/filled")
        public static let outlined = UIImage("notification/outlined")
      }
      public enum passkey {
        public static let filled = UIImage("passkey/filled")
        public static let outlined = UIImage("passkey/outlined")
      }
      public enum phishingAlert {
        public static let outlined = UIImage("phishing-alert/outlined")
      }
      public enum pinCode {
        public static let outlined = UIImage("pin-code/outlined")
      }
      public enum premium {
        public static let outlined = UIImage("premium/outlined")
      }
      public enum protection {
        public static let filled = UIImage("protection/filled")
        public static let outlined = UIImage("protection/outlined")
      }
      public enum recoveryKey {
        public static let outlined = UIImage("recovery-key/outlined")
      }
      public enum riskDetection {
        public static let outlined = UIImage("risk-detection/outlined")
      }
      public enum settings {
        public static let filled = UIImage("settings/filled")
        public static let outlined = UIImage("settings/outlined")
      }
      public enum shared {
        public static let filled = UIImage("shared/filled")
        public static let outlined = UIImage("shared/outlined")
      }
      public enum shortcut {
        public enum command {
          public static let outlined = UIImage("shortcut/command/outlined")
        }
        public enum optionAlt {
          public static let outlined = UIImage("shortcut/option-alt/outlined")
        }
        public enum shift {
          public static let outlined = UIImage("shortcut/shift/outlined")
        }
      }
      public enum social {
        public enum facebook {
          public static let filled = UIImage("social/facebook/filled")
        }
        public enum instagram {
          public static let filled = UIImage("social/instagram/filled")
        }
        public enum linkedin {
          public static let filled = UIImage("social/linkedin/filled")
        }
        public enum reddit {
          public static let filled = UIImage("social/reddit/filled")
        }
        public enum threads {
          public static let filled = UIImage("social/threads/filled")
        }
        public enum twitter {
          public static let filled = UIImage("social/twitter/filled")
        }
        public enum youtube {
          public static let filled = UIImage("social/youtube/filled")
        }
      }
      public enum spaces {
        public enum all {
          public static let outlined = UIImage("spaces/all/outlined")
        }
      }
      public enum sso {
        public static let outlined = UIImage("sso/outlined")
      }
      public enum time {
        public static let outlined = UIImage("time/outlined")
      }
      public enum tip {
        public static let filled = UIImage("tip/filled")
        public static let outlined = UIImage("tip/outlined")
      }
      public enum tools {
        public static let filled = UIImage("tools/filled")
        public static let outlined = UIImage("tools/outlined")
      }
      public enum unlock {
        public static let filled = UIImage("unlock/filled")
        public static let outlined = UIImage("unlock/outlined")
      }
      public enum upload {
        public static let outlined = UIImage("upload/outlined")
      }
      public enum uploadCloud {
        public static let outlined = UIImage("upload-cloud/outlined")
      }
      public enum users {
        public static let outlined = UIImage("users/outlined")
      }
      public enum vault {
        public static let filled = UIImage("vault/filled")
        public static let outlined = UIImage("vault/outlined")
      }
      public enum web {
        public static let filled = UIImage("web/filled")
        public static let outlined = UIImage("web/outlined")
      }
      public enum yubikey {
        public static let filled = UIImage("yubikey/filled")
        public static let outlined = UIImage("yubikey/outlined")
      }
    }
  }

  extension UIImage {
    fileprivate convenience init(_ name: String) {
      self.init(named: name, in: Bundle.module, compatibleWith: nil)!
    }
  }
#endif
