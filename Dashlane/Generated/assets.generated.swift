#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

internal enum FiberAsset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let authenticatorActionItemIcon = ImageAsset(name: "authenticatorActionItemIcon")
  internal static let breachActionItemIcon = ImageAsset(name: "breachActionItemIcon")
  internal static let check = ImageAsset(name: "check")
  internal static let darkwebActionItemIcon = ImageAsset(name: "darkwebActionItemIcon")
  internal static let errorState = ImageAsset(name: "error_state")
  internal static let faceIDActionItemIcon = ImageAsset(name: "faceID_action_item_icon")
  internal static let pinActionItemIcon = ImageAsset(name: "pin_action_item_icon")
  internal static let resetMasterPasswordActionItemIcon = ImageAsset(name: "resetMasterPassword_action_item_icon")
  internal static let sharingActionItemIcon = ImageAsset(name: "sharing_action_item_icon")
  internal static let touchIDActionItemIcon = ImageAsset(name: "touchID_action_item_icon")
  internal static let iconNotificationLarge = ImageAsset(name: "icon_notification_large")
  internal static let attachmentClip = ImageAsset(name: "Attachment_clip")
  internal static let attachmentClipDownloaded = ImageAsset(name: "Attachment_clip_downloaded")
  internal static let copyIcon = ImageAsset(name: "copy-icon")
  internal static let generateHotp = ImageAsset(name: "generateHotp")
  internal static let trashDelete = ImageAsset(name: "trash-delete")
  internal static let cellBackground = ColorAsset(name: "CellBackground")
  internal static let dashGreen = ColorAsset(name: "DashGreen")
  internal static let fieldBackground = ColorAsset(name: "FieldBackground")
  internal static let grey01 = ColorAsset(name: "Grey01")
  internal static let grey02 = ColorAsset(name: "Grey02")
  internal static let grey04 = ColorAsset(name: "Grey04")
  internal static let grey05 = ColorAsset(name: "Grey05")
  internal static let grey06 = ColorAsset(name: "Grey06")
  internal static let mainBackground = ColorAsset(name: "MainBackground")
  internal static let mainCopy = ColorAsset(name: "MainCopy")
  internal static let midGreen = ColorAsset(name: "MidGreen")
  internal static let neutralText = ColorAsset(name: "NeutralText")
  internal static let autofillDemoAccessoryViewBackground = ColorAsset(name: "AutofillDemoAccessoryViewBackground")
  internal static let buttonTitle = ColorAsset(name: "ButtonTitle")
  internal static let dwmBreachDetailMessageBody = ColorAsset(name: "DWMBreachDetailMessageBody")
  internal static let dwmDashGreen01 = ColorAsset(name: "DWMDashGreen01")
  internal static let dwmMainBackground = ColorAsset(name: "DWMMainBackground")
  internal static let dwmOnboardingLoadingAnimationFailure = ColorAsset(name: "DWMOnboardingLoadingAnimationFailure")
  internal static let dwmOnboardingLoadingAnimationNeutral = ColorAsset(name: "DWMOnboardingLoadingAnimationNeutral")
  internal static let dwmOnboardingResultMessageText = ColorAsset(name: "DWMOnboardingResultMessageText")
  internal static let fastSetupCardBackground = ColorAsset(name: "FastSetupCardBackground")
  internal static let fastSetupInfo = ColorAsset(name: "FastSetupInfo")
  internal static let fastSetupSubtitle = ColorAsset(name: "FastSetupSubtitle")
  internal static let fixedGrayBackground = ColorAsset(name: "FixedGrayBackground")
  internal static let guidedOnboardingSecondaryAction = ColorAsset(name: "GuidedOnboardingSecondaryAction")
  internal static let guidedOnboardingSecondaryText = ColorAsset(name: "GuidedOnboardingSecondaryText")
  internal static let littleIconPrimary = ColorAsset(name: "LittleIconPrimary")
  internal static let mainGreen = ColorAsset(name: "MainGreen")
  internal static let onboardingSecondaryText = ColorAsset(name: "OnboardingSecondaryText")
  internal static let pageControl = ColorAsset(name: "PageControl")
  internal static let pageControlSelected = ColorAsset(name: "PageControlSelected")
  internal static let dashlaneTextGrey = ColorAsset(name: "dashlaneTextGrey")
  internal static let passwordGeneratorRefreshButtonColor = ColorAsset(name: "PasswordGeneratorRefreshButtonColor")
  internal static let premiumPlanDescription = ColorAsset(name: "PremiumPlanDescription")
  internal static let premiumPlanTitle = ColorAsset(name: "PremiumPlanTitle")
  internal static let listBackground = ColorAsset(name: "listBackground")
  internal static let pride1 = ColorAsset(name: "Pride1")
  internal static let pride2 = ColorAsset(name: "Pride2")
  internal static let pride3 = ColorAsset(name: "Pride3")
  internal static let pride4 = ColorAsset(name: "Pride4")
  internal static let pride5 = ColorAsset(name: "Pride5")
  internal static let pride6 = ColorAsset(name: "Pride6")
  internal static let pride7 = ColorAsset(name: "Pride7")
  internal static let pride8 = ColorAsset(name: "Pride8")
  internal static let secondaryText = ColorAsset(name: "SecondaryText")
  internal static let sidebarSeparator = ColorAsset(name: "SidebarSeparator")
  internal static let toolbarbackground = ColorAsset(name: "Toolbarbackground")
  internal static let toolsMenuButton = ColorAsset(name: "ToolsMenuButton")
  internal static let yellow = ColorAsset(name: "Yellow")
  internal static let dashlaneBlue = ColorAsset(name: "dashlaneBlue")
  internal static let dashlaneColorTealBackground = ColorAsset(name: "dashlaneColorTealBackground")
  internal static let systemGray = ColorAsset(name: "systemGray")
  internal static let tableViewCellUnread = ColorAsset(name: "tableViewCellUnread")
  internal static let appBackground = ColorAsset(name: "AppBackground")
  internal static let buttonBackgroundIncreasedContrast = ColorAsset(name: "ButtonBackgroundIncreasedContrast")
  internal static let errorRed = ColorAsset(name: "ErrorRed")
  internal static let navigationBarBackground = ColorAsset(name: "NavigationBarBackground")
  internal static let navigationBarBackgroundIpad = ColorAsset(name: "NavigationBarBackgroundIpad")
  internal static let neutralBackground = ColorAsset(name: "NeutralBackground")
  internal static let searchBarBackgroundInactive = ColorAsset(name: "SearchBarBackgroundInactive")
  internal static let searchbarBackground = ColorAsset(name: "SearchbarBackground")
  internal static let searchbarBackgroundActive = ColorAsset(name: "SearchbarBackgroundActive")
  internal static let secondaryRed = ColorAsset(name: "SecondaryRed")
  internal static let separator = ColorAsset(name: "Separator")
  internal static let switchDefaultTint = ColorAsset(name: "SwitchDefaultTint")
  internal static let tableBackground = ColorAsset(name: "TableBackground")
  internal static let alternativePlaceholder = ColorAsset(name: "AlternativePlaceholder")
  internal static let buttonText = ColorAsset(name: "ButtonText")
  internal static let buttonTextIncreasedContrast = ColorAsset(name: "ButtonTextIncreasedContrast")
  internal static let dashGreenCopy = ColorAsset(name: "DashGreenCopy")
  internal static let mainCopyList = ColorAsset(name: "MainCopyList")
  internal static let placeholder = ColorAsset(name: "Placeholder")
  internal static let secondaryActionText = ColorAsset(name: "SecondaryActionText")
  internal static let settingsWarningRed = ColorAsset(name: "SettingsWarningRed")
  internal static let sliderAccentColor = ColorAsset(name: "SliderAccentColor")
  internal static let tertiaryCopyList = ColorAsset(name: "TertiaryCopyList")
  internal static let validatorGreen = ColorAsset(name: "ValidatorGreen")
  internal static let browserChrome = ImageAsset(name: "browser_chrome")
  internal static let browserChromeLogo = ImageAsset(name: "browser_chrome_logo")
  internal static let browserEdge = ImageAsset(name: "browser_edge")
  internal static let browserEdgeLogo = ImageAsset(name: "browser_edge_logo")
  internal static let browserFirefox = ImageAsset(name: "browser_firefox")
  internal static let browserFirefoxLogo = ImageAsset(name: "browser_firefox_logo")
  internal static let browserSafari = ImageAsset(name: "browser_safari")
  internal static let browserSafariLegacy = ImageAsset(name: "browser_safari_legacy")
  internal static let browserSafariLogo = ImageAsset(name: "browser_safari_logo")
  internal static let safariDashlaneLegacy = ImageAsset(name: "safari_dashlane_legacy")
  internal static let safariDashlaneSmall = ImageAsset(name: "safari_dashlane_small")
  internal static let safariExtensions = ImageAsset(name: "safari_extensions")
  internal static let safariLogo = ImageAsset(name: "safari_logo")
  internal static let alternateIconBorder = ColorAsset(name: "AlternateIconBorder")
  internal static let autofill = ImageAsset(name: "Autofill")
  internal static let emptyViewSolved = ImageAsset(name: "EmptyViewSolved")
  internal static let logomarkSplash = ImageAsset(name: "Logomark-splash")
  internal static let logomark = ImageAsset(name: "Logomark")
  internal static let ssoOutlined = ImageAsset(name: "SSO-outlined")
  internal static let thumbsAllGood = ImageAsset(name: "ThumbsAllGood")
  internal static let add = ImageAsset(name: "add")
  internal static let checkboxSelected = ImageAsset(name: "checkboxSelected")
  internal static let checkboxUnselected = ImageAsset(name: "checkboxUnselected")
  internal static let checkmark = ImageAsset(name: "checkmark")
  internal static let copyItem = ImageAsset(name: "copyItem")
  internal static let deleteButton = ImageAsset(name: "delete-button")
  internal static let detailDisclosureButton = ImageAsset(name: "detail-disclosure-button")
  internal static let error = ImageAsset(name: "error")
  internal static let faceId = ImageAsset(name: "faceId")
  internal static let fingerprint = ImageAsset(name: "fingerprint")
  internal static let openWebsite = ImageAsset(name: "open-website")
  internal static let quickaction = ImageAsset(name: "quickaction")
  internal static let refreshButton = ImageAsset(name: "refreshButton")
  internal static let revealButtonSelected = ImageAsset(name: "reveal-button-selected")
  internal static let revealButton = ImageAsset(name: "reveal-button")
  internal static let shareIcon = ImageAsset(name: "shareIcon")
  internal static let success = ImageAsset(name: "success")
  internal static let successStepper = ImageAsset(name: "success_stepper")
  internal static let vpnOutlined = ImageAsset(name: "vpn-outlined")
  internal static let popoverCloseButton = ImageAsset(name: "PopoverCloseButton")
  internal static let dwmAlert = ImageAsset(name: "dwmAlert")
  internal static let dwmExpert = ImageAsset(name: "dwmExpert")
  internal static let dwmMonitor = ImageAsset(name: "dwmMonitor")
  internal static let sidebarContacts = ImageAsset(name: "sidebar_contacts")
  internal static let sidebarHome = ImageAsset(name: "sidebar_home")
  internal static let sidebarNotification = ImageAsset(name: "sidebar_notification")
  internal static let sidebarSettings = ImageAsset(name: "sidebar_settings")
  internal static let sidebarToolsDarkWebMonitoring = ImageAsset(name: "sidebar_tools_darkWebMonitoring")
  internal static let sidebarToolsIdentitydashboard = ImageAsset(name: "sidebar_tools_identitydashboard")
  internal static let sidebarToolsNewdevice = ImageAsset(name: "sidebar_tools_newdevice")
  internal static let sidebarToolsPasswordgenerator = ImageAsset(name: "sidebar_tools_passwordgenerator")
  internal static let sidebarToolsVpn = ImageAsset(name: "sidebar_tools_vpn")
  internal static let sidebarVaultCredentials = ImageAsset(name: "sidebar_vault_credentials")
  internal static let sidebarVaultIds = ImageAsset(name: "sidebar_vault_ids")
  internal static let sidebarVaultNotes = ImageAsset(name: "sidebar_vault_notes")
  internal static let sidebarVaultPayments = ImageAsset(name: "sidebar_vault_payments")
  internal static let sidebarVaultPersonalinfo = ImageAsset(name: "sidebar_vault_personalinfo")
  internal static let sidebarContactsSelected = ImageAsset(name: "sidebar_contacts_selected")
  internal static let sidebarHomeSelected = ImageAsset(name: "sidebar_home_selected")
  internal static let sidebarNotificationSelected = ImageAsset(name: "sidebar_notification_selected")
  internal static let sidebarSettingsSelected = ImageAsset(name: "sidebar_settings_selected")
  internal static let sidebarToolsDarkWebMonitoringSelected = ImageAsset(name: "sidebar_tools_darkWebMonitoring_selected")
  internal static let sidebarToolsIdentitydashboardSelected = ImageAsset(name: "sidebar_tools_identitydashboard_selected")
  internal static let sidebarToolsNewdeviceSelected = ImageAsset(name: "sidebar_tools_newdevice_selected")
  internal static let sidebarToolsPasswordgeneratorSelected = ImageAsset(name: "sidebar_tools_passwordgenerator_selected")
  internal static let sidebarToolsVpnSelected = ImageAsset(name: "sidebar_tools_vpn_selected")
  internal static let sidebarVaultCredentialsSelected = ImageAsset(name: "sidebar_vault_credentials_selected")
  internal static let sidebarVaultIdsSelected = ImageAsset(name: "sidebar_vault_ids_selected")
  internal static let sidebarVaultNotesSelected = ImageAsset(name: "sidebar_vault_notes_selected")
  internal static let sidebarVaultPaymentsSelected = ImageAsset(name: "sidebar_vault_payments_selected")
  internal static let sidebarVaultPersonalinfoSelected = ImageAsset(name: "sidebar_vault_personalinfo_selected")
  internal static let tabAlertOff = ImageAsset(name: "tab-alert-off")
  internal static let tabAlertOn = ImageAsset(name: "tab-alert-on")
  internal static let tabIconContactsOff = ImageAsset(name: "tab-icon-contacts-off")
  internal static let tabIconContactsOn = ImageAsset(name: "tab-icon-contacts-on")
  internal static let tabIconHomeOff = ImageAsset(name: "tab-icon-home-off")
  internal static let tabIconHomeOn = ImageAsset(name: "tab-icon-home-on")
  internal static let tabIconRecentsOff = ImageAsset(name: "tab-icon-recents-off")
  internal static let tabIconRecentsOn = ImageAsset(name: "tab-icon-recents-on")
  internal static let tabIconSettingsOff = ImageAsset(name: "tab-icon-settings-off")
  internal static let tabIconSettingsOn = ImageAsset(name: "tab-icon-settings-on")
  internal static let tabIconToolsOff = ImageAsset(name: "tab-icon-tools-off")
  internal static let tabIconToolsOn = ImageAsset(name: "tab-icon-tools-on")
  internal static let tabPwcGenOff = ImageAsset(name: "tab-pwc-gen-off")
  internal static let tabPwcGenOn = ImageAsset(name: "tab-pwc-gen-on")
  internal static let clip = ImageAsset(name: "Clip")
  internal static let delete = ImageAsset(name: "Delete")
  internal static let lockLocked = ImageAsset(name: "Lock_locked")
  internal static let lockUnlock = ImageAsset(name: "Lock_unlock")
  internal static let share = ImageAsset(name: "Share")
  internal static let tool = ImageAsset(name: "Tool")
  internal static let actionItemDiamond = ImageAsset(name: "actionItemDiamond")
  internal static let featureCheckmark = ImageAsset(name: "featureCheckmark")
  internal static let editPen = ImageAsset(name: "edit-pen")
  internal static let passwords = ImageAsset(name: "passwords")
  internal static let bankAccountBackground = ColorAsset(name: "BankAccountBackground")
  internal static let emptyStateIconTintColor = ColorAsset(name: "EmptyStateIconTintColor")
  internal static let emptyConfidentialCards = ImageAsset(name: "empty-confidential-cards")
  internal static let emptyNotes = ImageAsset(name: "empty-notes")
  internal static let emptyPasswords = ImageAsset(name: "empty-passwords")
  internal static let emptyPayments = ImageAsset(name: "empty-payments")
  internal static let emptyPersonalInfo = ImageAsset(name: "empty-personal-info")
  internal static let emptyRecent = ImageAsset(name: "empty-recent")
  internal static let emptySearch = ImageAsset(name: "empty-search")
  internal static let identityItemBackground = ColorAsset(name: "identityItemBackground")
  internal static let iconSelection = ImageAsset(name: "IconSelection")
  internal static let imgNoteLocked = ImageAsset(name: "img-note-locked")
  internal static let menuIconConfidentialcards = ImageAsset(name: "menu-icon-confidentialcards")
  internal static let menuIconNotes = ImageAsset(name: "menu-icon-notes")
  internal static let menuIconPasswords = ImageAsset(name: "menu-icon-passwords")
  internal static let menuIconPaymentmeans = ImageAsset(name: "menu-icon-paymentmeans")
  internal static let menuIconPersonalinfos = ImageAsset(name: "menu-icon-personalinfos")
  internal static let iconPlaceholderBackground = ColorAsset(name: "iconPlaceholderBackground")
  internal static let passwordMissingImage = ImageAsset(name: "password-missing-image")
  internal static let sharingIndicator = ImageAsset(name: "sharing-indicator")
  internal static let safariDisabled = ImageAsset(name: "safari_disabled")
  internal static let chromeImport = ImageAsset(name: "chrome-import")
  internal static let chromeInstructions = ImageAsset(name: "chrome-instructions")
  internal static let emailFieldMailIcon = ImageAsset(name: "email-field-mail-icon")
  internal static let emailRegistrationCheckmark = ImageAsset(name: "email-registration-checkmark")
  internal static let noBreachesMessageIcon = ImageAsset(name: "no-breaches-message-icon")
  internal static let m2wConnect = ImageAsset(name: "m2w_connect")
  internal static let arrowUp = ImageAsset(name: "arrow-up")
  internal static let checklistCheckmark = ImageAsset(name: "checklist_checkmark")
  internal static let guidedOnboardingLogoMark = ImageAsset(name: "guided_onboarding_logo_mark")
  internal static let importMethodChrome = ImageAsset(name: "import-method-chrome")
  internal static let importMethodDash = ImageAsset(name: "import-method-dash")
  internal static let importMethodManual = ImageAsset(name: "import-method-manual")
  internal static let importMethodSafari = ImageAsset(name: "import-method-safari")
  internal static let infoButton = ImageAsset(name: "info-button")
  internal static let onboardingAnotherManager = ImageAsset(name: "onboarding-another-manager")
  internal static let onboardingAutofill = ImageAsset(name: "onboarding-autofill")
  internal static let onboardingBrowser = ImageAsset(name: "onboarding-browser")
  internal static let onboardingMemorized = ImageAsset(name: "onboarding-memorized")
  internal static let onboardingOnePlace = ImageAsset(name: "onboarding-one-place")
  internal static let onboardingProtect = ImageAsset(name: "onboarding-protect")
  internal static let onboardingSomethingElse = ImageAsset(name: "onboarding-something-else")
  internal static let sharingPaywall = ImageAsset(name: "SharingPaywall")
  internal static let paywallVpn = ImageAsset(name: "paywall_vpn")
  internal static let settingsPrimaryHighlight = ColorAsset(name: "SettingsPrimaryHighlight")
  internal static let settingsSecondaryHighlight = ColorAsset(name: "SettingsSecondaryHighlight")
  internal static let authenticator = ImageAsset(name: "authenticator")
  internal static let multidevices = ImageAsset(name: "multidevices")
  internal static let contactsBlue = ColorAsset(name: "contactsBlue")
  internal static let contactsOrange = ColorAsset(name: "contactsOrange")
  internal static let contactsPurple = ColorAsset(name: "contactsPurple")
  internal static let contactsTurquoise = ColorAsset(name: "contactsTurquoise")
  internal static let contactsViolet = ColorAsset(name: "contactsViolet")
  internal static let contactsYellow = ColorAsset(name: "contactsYellow")
  internal static let emptySharing = ImageAsset(name: "empty-sharing")
  internal static let userGroup = ImageAsset(name: "user-group")
  internal static let systemBackground = ColorAsset(name: "SystemBackground")
  internal static let allSpaces = ImageAsset(name: "all_spaces")
  internal static let personalSpaceIconColor = ColorAsset(name: "personalSpaceIconColor")
  internal static let teamSpace = ImageAsset(name: "team_space")
  internal static let teamSpaceLarge = ImageAsset(name: "team_space_large")
  internal static let teamSpaceOutline = ImageAsset(name: "team_space_outline")
  internal static let teamSpaceOutlineLarge = ImageAsset(name: "team_space_outline_large")
  internal static let teamSpaceOutlineSmall = ImageAsset(name: "team_space_outline_small")
  internal static let teamSpaceSmall = ImageAsset(name: "team_space_small")
  internal static let pictoAuthenticator = ImageAsset(name: "pictoAuthenticator")
  internal static let dashlaneOrange = ColorAsset(name: "dashlaneOrange")
  internal static let dataLeakVerifyEmail = ImageAsset(name: "data_leak_verify_email")
  internal static let securityBreachDataleak = ImageAsset(name: "security_breach_dataleak")
  internal static let securityBreachRegular = ImageAsset(name: "security_breach_regular")
  internal static let paywallIconShield = ImageAsset(name: "paywall_icon_shield")
  internal static let paywallIconWeb = ImageAsset(name: "paywall_icon_web")
  internal static let secureWifiLogo = ImageAsset(name: "secure-wifi-logo")
  internal static let history = ImageAsset(name: "history")
  internal static let historyLarge = ImageAsset(name: "historyLarge")
  internal static let toolsDarkWeb = ImageAsset(name: "tools_dark_web")
  internal static let toolsIdentityDashboard = ImageAsset(name: "tools_identity_dashboard")
  internal static let toolsNewDeviceConnector = ImageAsset(name: "tools_new_device_connector")
  internal static let toolsPasswordGenerator = ImageAsset(name: "tools_password_generator")
  internal static let toolsSharing = ImageAsset(name: "tools_sharing")
  internal static let toolsVpn = ImageAsset(name: "tools_vpn")
  internal static let shield = ImageAsset(name: "shield")
}
internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
