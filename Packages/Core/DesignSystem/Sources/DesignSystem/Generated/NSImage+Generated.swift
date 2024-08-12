#if os(macOS)
  import AppKit

  extension NSImage {
    public enum ds {
      public enum accountSettings {
        public static let filled = Bundle.module.image(forResource: "account-settings/filled")
        public static let outlined = Bundle.module.image(forResource: "account-settings/outlined")
      }
      public enum action {
        public enum add {
          public static let outlined = Bundle.module.image(forResource: "action/add/outlined")
        }
        public enum clearContent {
          public static let filled = Bundle.module.image(forResource: "action/clear-content/filled")
        }
        public enum close {
          public static let outlined = Bundle.module.image(forResource: "action/close/outlined")
        }
        public enum copy {
          public static let filled = Bundle.module.image(forResource: "action/copy/filled")
          public static let outlined = Bundle.module.image(forResource: "action/copy/outlined")
        }
        public enum delete {
          public static let filled = Bundle.module.image(forResource: "action/delete/filled")
          public static let outlined = Bundle.module.image(forResource: "action/delete/outlined")
        }
        public enum edit {
          public static let filled = Bundle.module.image(forResource: "action/edit/filled")
          public static let outlined = Bundle.module.image(forResource: "action/edit/outlined")
        }
        public enum hide {
          public static let filled = Bundle.module.image(forResource: "action/hide/filled")
          public static let outlined = Bundle.module.image(forResource: "action/hide/outlined")
        }
        public enum more {
          public static let outlined = Bundle.module.image(forResource: "action/more/outlined")
        }
        public enum moreEmphasized {
          public static let outlined = Bundle.module.image(
            forResource: "action/more-emphasized/outlined")
        }
        public enum openExternalLink {
          public static let outlined = Bundle.module.image(
            forResource: "action/open-external-link/outlined")
        }
        public enum refer {
          public static let outlined = Bundle.module.image(forResource: "action/refer/outlined")
        }
        public enum refresh {
          public static let outlined = Bundle.module.image(forResource: "action/refresh/outlined")
        }
        public enum reveal {
          public static let filled = Bundle.module.image(forResource: "action/reveal/filled")
          public static let outlined = Bundle.module.image(forResource: "action/reveal/outlined")
        }
        public enum revoke {
          public static let filled = Bundle.module.image(forResource: "action/revoke/filled")
          public static let outlined = Bundle.module.image(forResource: "action/revoke/outlined")
        }
        public enum search {
          public static let outlined = Bundle.module.image(forResource: "action/search/outlined")
        }
        public enum share {
          public static let filled = Bundle.module.image(forResource: "action/share/filled")
          public static let outlined = Bundle.module.image(forResource: "action/share/outlined")
        }
        public enum sort {
          public static let outlined = Bundle.module.image(forResource: "action/sort/outlined")
        }
        public enum subtract {
          public static let outlined = Bundle.module.image(forResource: "action/subtract/outlined")
        }
        public enum undo {
          public static let outlined = Bundle.module.image(forResource: "action/undo/outlined")
        }
      }
      public enum activityLog {
        public static let outlined = Bundle.module.image(forResource: "activity-log/outlined")
      }
      public enum arrowDown {
        public static let outlined = Bundle.module.image(forResource: "arrow-down/outlined")
      }
      public enum arrowLeft {
        public static let outlined = Bundle.module.image(forResource: "arrow-left/outlined")
      }
      public enum arrowRight {
        public static let outlined = Bundle.module.image(forResource: "arrow-right/outlined")
      }
      public enum arrowUp {
        public static let outlined = Bundle.module.image(forResource: "arrow-up/outlined")
      }
      public enum attachment {
        public static let outlined = Bundle.module.image(forResource: "attachment/outlined")
      }
      public enum caretDoubleLeft {
        public static let outlined = Bundle.module.image(forResource: "caret-double-left/outlined")
      }
      public enum caretDoubleRight {
        public static let outlined = Bundle.module.image(forResource: "caret-double-right/outlined")
      }
      public enum caretDown {
        public static let outlined = Bundle.module.image(forResource: "caret-down/outlined")
      }
      public enum caretLeft {
        public static let outlined = Bundle.module.image(forResource: "caret-left/outlined")
      }
      public enum caretRight {
        public static let outlined = Bundle.module.image(forResource: "caret-right/outlined")
      }
      public enum caretUp {
        public static let outlined = Bundle.module.image(forResource: "caret-up/outlined")
      }
      public enum checkmark {
        public static let outlined = Bundle.module.image(forResource: "checkmark/outlined")
      }
      public enum collection {
        public static let outlined = Bundle.module.image(forResource: "collection/outlined")
      }
      public enum configure {
        public static let outlined = Bundle.module.image(forResource: "configure/outlined")
      }
      public enum csv {
        public static let filled = Bundle.module.image(forResource: "csv/filled")
        public static let outlined = Bundle.module.image(forResource: "csv/outlined")
      }
      public enum dashboard {
        public static let outlined = Bundle.module.image(forResource: "dashboard/outlined")
      }
      public enum download {
        public static let outlined = Bundle.module.image(forResource: "download/outlined")
      }
      public enum downloadCloud {
        public static let outlined = Bundle.module.image(forResource: "download-cloud/outlined")
      }
      public enum faceId {
        public static let outlined = Bundle.module.image(forResource: "face-id/outlined")
      }
      public enum feature {
        public enum authenticator {
          public static let filled = Bundle.module.image(
            forResource: "feature/authenticator/filled")
          public static let outlined = Bundle.module.image(
            forResource: "feature/authenticator/outlined")
        }
        public enum autofill {
          public static let outlined = Bundle.module.image(forResource: "feature/autofill/outlined")
        }
        public enum darkWebMonitoring {
          public static let outlined = Bundle.module.image(
            forResource: "feature/dark-web-monitoring/outlined")
        }
        public enum inboxScan {
          public static let outlined = Bundle.module.image(
            forResource: "feature/inbox-scan/outlined")
        }
        public enum passwordGenerator {
          public static let filled = Bundle.module.image(
            forResource: "feature/password-generator/filled")
          public static let outlined = Bundle.module.image(
            forResource: "feature/password-generator/outlined")
        }
        public enum passwordHealth {
          public static let outlined = Bundle.module.image(
            forResource: "feature/password-health/outlined")
        }
        public enum vpn {
          public static let filled = Bundle.module.image(forResource: "feature/vpn/filled")
          public static let outlined = Bundle.module.image(forResource: "feature/vpn/outlined")
        }
      }
      public enum feedback {
        public enum fail {
          public static let filled = Bundle.module.image(forResource: "feedback/fail/filled")
          public static let outlined = Bundle.module.image(forResource: "feedback/fail/outlined")
        }
        public enum help {
          public static let filled = Bundle.module.image(forResource: "feedback/help/filled")
          public static let outlined = Bundle.module.image(forResource: "feedback/help/outlined")
        }
        public enum info {
          public static let filled = Bundle.module.image(forResource: "feedback/info/filled")
          public static let outlined = Bundle.module.image(forResource: "feedback/info/outlined")
        }
        public enum success {
          public static let filled = Bundle.module.image(forResource: "feedback/success/filled")
          public static let outlined = Bundle.module.image(forResource: "feedback/success/outlined")
        }
        public enum warning {
          public static let filled = Bundle.module.image(forResource: "feedback/warning/filled")
          public static let outlined = Bundle.module.image(forResource: "feedback/warning/outlined")
        }
      }
      public enum fingerprint {
        public static let outlined = Bundle.module.image(forResource: "fingerprint/outlined")
      }
      public enum folder {
        public static let filled = Bundle.module.image(forResource: "folder/filled")
        public static let outlined = Bundle.module.image(forResource: "folder/outlined")
      }
      public enum formatting {
        public enum bold {
          public static let outlined = Bundle.module.image(forResource: "formatting/bold/outlined")
        }
        public enum code {
          public static let outlined = Bundle.module.image(forResource: "formatting/code/outlined")
        }
        public enum heading1 {
          public static let outlined = Bundle.module.image(
            forResource: "formatting/heading1/outlined")
        }
        public enum heading2 {
          public static let outlined = Bundle.module.image(
            forResource: "formatting/heading2/outlined")
        }
        public enum heading3 {
          public static let outlined = Bundle.module.image(
            forResource: "formatting/heading3/outlined")
        }
        public enum italic {
          public static let outlined = Bundle.module.image(
            forResource: "formatting/italic/outlined")
        }
      }
      public enum googleChrome {
        public static let outlined = Bundle.module.image(forResource: "google-chrome/outlined")
      }
      public enum group {
        public static let filled = Bundle.module.image(forResource: "group/filled")
        public static let outlined = Bundle.module.image(forResource: "group/outlined")
      }
      public enum healthNegative {
        public static let outlined = Bundle.module.image(forResource: "health-negative/outlined")
      }
      public enum healthPositive {
        public static let outlined = Bundle.module.image(forResource: "health-positive/outlined")
      }
      public enum healthUnknown {
        public static let outlined = Bundle.module.image(forResource: "health-unknown/outlined")
      }
      public enum historyBackup {
        public static let outlined = Bundle.module.image(forResource: "history-backup/outlined")
      }
      public enum home {
        public static let filled = Bundle.module.image(forResource: "home/filled")
        public static let outlined = Bundle.module.image(forResource: "home/outlined")
      }
      public enum item {
        public enum bankAccount {
          public static let filled = Bundle.module.image(forResource: "item/bank-account/filled")
          public static let outlined = Bundle.module.image(
            forResource: "item/bank-account/outlined")
        }
        public enum company {
          public static let filled = Bundle.module.image(forResource: "item/company/filled")
          public static let outlined = Bundle.module.image(forResource: "item/company/outlined")
        }
        public enum driversLicense {
          public static let outlined = Bundle.module.image(
            forResource: "item/drivers-license/outlined")
        }
        public enum email {
          public static let filled = Bundle.module.image(forResource: "item/email/filled")
          public static let outlined = Bundle.module.image(forResource: "item/email/outlined")
        }
        public enum fax {
          public static let outlined = Bundle.module.image(forResource: "item/fax/outlined")
        }
        public enum id {
          public static let filled = Bundle.module.image(forResource: "item/id/filled")
          public static let outlined = Bundle.module.image(forResource: "item/id/outlined")
        }
        public enum login {
          public static let filled = Bundle.module.image(forResource: "item/login/filled")
          public static let outlined = Bundle.module.image(forResource: "item/login/outlined")
        }
        public enum passport {
          public static let filled = Bundle.module.image(forResource: "item/passport/filled")
          public static let outlined = Bundle.module.image(forResource: "item/passport/outlined")
        }
        public enum payment {
          public static let filled = Bundle.module.image(forResource: "item/payment/filled")
          public static let outlined = Bundle.module.image(forResource: "item/payment/outlined")
        }
        public enum personalInfo {
          public static let filled = Bundle.module.image(forResource: "item/personal-info/filled")
          public static let outlined = Bundle.module.image(
            forResource: "item/personal-info/outlined")
        }
        public enum phoneHome {
          public static let filled = Bundle.module.image(forResource: "item/phone-home/filled")
          public static let outlined = Bundle.module.image(forResource: "item/phone-home/outlined")
        }
        public enum phoneMobile {
          public static let filled = Bundle.module.image(forResource: "item/phone-mobile/filled")
          public static let outlined = Bundle.module.image(
            forResource: "item/phone-mobile/outlined")
        }
        public enum secret {
          public static let outlined = Bundle.module.image(forResource: "item/secret/outlined")
        }
        public enum secureNote {
          public static let filled = Bundle.module.image(forResource: "item/secure-note/filled")
          public static let outlined = Bundle.module.image(forResource: "item/secure-note/outlined")
        }
        public enum socialSecurity {
          public static let filled = Bundle.module.image(forResource: "item/social-security/filled")
          public static let outlined = Bundle.module.image(
            forResource: "item/social-security/outlined")
        }
        public enum taxNumber {
          public static let filled = Bundle.module.image(forResource: "item/tax-number/filled")
          public static let outlined = Bundle.module.image(forResource: "item/tax-number/outlined")
        }
      }
      public enum itemColor {
        public static let filled = Bundle.module.image(forResource: "item-color/filled")
        public static let outlined = Bundle.module.image(forResource: "item-color/outlined")
      }
      public enum laptop {
        public static let filled = Bundle.module.image(forResource: "laptop/filled")
        public static let outlined = Bundle.module.image(forResource: "laptop/outlined")
      }
      public enum laptopCheckmark {
        public static let filled = Bundle.module.image(forResource: "laptop-checkmark/filled")
        public static let outlined = Bundle.module.image(forResource: "laptop-checkmark/outlined")
      }
      public enum link {
        public static let outlined = Bundle.module.image(forResource: "link/outlined")
      }
      public enum lock {
        public static let filled = Bundle.module.image(forResource: "lock/filled")
        public static let outlined = Bundle.module.image(forResource: "lock/outlined")
      }
      public enum logOut {
        public static let outlined = Bundle.module.image(forResource: "log-out/outlined")
      }
      public enum menu {
        public static let outlined = Bundle.module.image(forResource: "menu/outlined")
      }
      public enum muteAutofill {
        public static let outlined = Bundle.module.image(forResource: "mute-autofill/outlined")
      }
      public enum noNetwork {
        public static let outlined = Bundle.module.image(forResource: "no-network/outlined")
      }
      public enum notification {
        public static let filled = Bundle.module.image(forResource: "notification/filled")
        public static let outlined = Bundle.module.image(forResource: "notification/outlined")
      }
      public enum passkey {
        public static let filled = Bundle.module.image(forResource: "passkey/filled")
        public static let outlined = Bundle.module.image(forResource: "passkey/outlined")
      }
      public enum premium {
        public static let outlined = Bundle.module.image(forResource: "premium/outlined")
      }
      public enum protection {
        public static let filled = Bundle.module.image(forResource: "protection/filled")
        public static let outlined = Bundle.module.image(forResource: "protection/outlined")
      }
      public enum recoveryKey {
        public static let outlined = Bundle.module.image(forResource: "recovery-key/outlined")
      }
      public enum settings {
        public static let filled = Bundle.module.image(forResource: "settings/filled")
        public static let outlined = Bundle.module.image(forResource: "settings/outlined")
      }
      public enum shared {
        public static let filled = Bundle.module.image(forResource: "shared/filled")
        public static let outlined = Bundle.module.image(forResource: "shared/outlined")
      }
      public enum shortcut {
        public enum command {
          public static let outlined = Bundle.module.image(forResource: "shortcut/command/outlined")
        }
        public enum optionAlt {
          public static let outlined = Bundle.module.image(
            forResource: "shortcut/option-alt/outlined")
        }
        public enum shift {
          public static let outlined = Bundle.module.image(forResource: "shortcut/shift/outlined")
        }
      }
      public enum social {
        public enum facebook {
          public static let filled = Bundle.module.image(forResource: "social/facebook/filled")
        }
        public enum instagram {
          public static let filled = Bundle.module.image(forResource: "social/instagram/filled")
        }
        public enum linkedin {
          public static let filled = Bundle.module.image(forResource: "social/linkedin/filled")
        }
        public enum reddit {
          public static let filled = Bundle.module.image(forResource: "social/reddit/filled")
        }
        public enum threads {
          public static let filled = Bundle.module.image(forResource: "social/threads/filled")
        }
        public enum twitter {
          public static let filled = Bundle.module.image(forResource: "social/twitter/filled")
        }
        public enum youtube {
          public static let filled = Bundle.module.image(forResource: "social/youtube/filled")
        }
      }
      public enum spaces {
        public enum all {
          public static let outlined = Bundle.module.image(forResource: "spaces/all/outlined")
        }
      }
      public enum time {
        public static let outlined = Bundle.module.image(forResource: "time/outlined")
      }
      public enum tip {
        public static let filled = Bundle.module.image(forResource: "tip/filled")
        public static let outlined = Bundle.module.image(forResource: "tip/outlined")
      }
      public enum tools {
        public static let filled = Bundle.module.image(forResource: "tools/filled")
        public static let outlined = Bundle.module.image(forResource: "tools/outlined")
      }
      public enum unlock {
        public static let filled = Bundle.module.image(forResource: "unlock/filled")
        public static let outlined = Bundle.module.image(forResource: "unlock/outlined")
      }
      public enum upload {
        public static let outlined = Bundle.module.image(forResource: "upload/outlined")
      }
      public enum uploadCloud {
        public static let outlined = Bundle.module.image(forResource: "upload-cloud/outlined")
      }
      public enum users {
        public static let outlined = Bundle.module.image(forResource: "users/outlined")
      }
      public enum vault {
        public static let filled = Bundle.module.image(forResource: "vault/filled")
        public static let outlined = Bundle.module.image(forResource: "vault/outlined")
      }
      public enum web {
        public static let filled = Bundle.module.image(forResource: "web/filled")
        public static let outlined = Bundle.module.image(forResource: "web/outlined")
      }
      public enum yubikey {
        public static let filled = Bundle.module.image(forResource: "yubikey/filled")
        public static let outlined = Bundle.module.image(forResource: "yubikey/outlined")
      }
    }
  }

#endif
