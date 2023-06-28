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
  internal static let pinActionItemIcon = ImageAsset(name: "pin_action_item_icon")
  internal static let resetMasterPasswordActionItemIcon = ImageAsset(name: "resetMasterPassword_action_item_icon")
  internal static let iconNotificationLarge = ImageAsset(name: "icon_notification_large")
  internal static let dashGreen = ColorAsset(name: "DashGreen")
  internal static let grey01 = ColorAsset(name: "Grey01")
  internal static let grey04 = ColorAsset(name: "Grey04")
  internal static let mainBackground = ColorAsset(name: "MainBackground")
  internal static let midGreen = ColorAsset(name: "MidGreen")
  internal static let neutralText = ColorAsset(name: "NeutralText")
  internal static let autofillDemoAccessoryViewBackground = ColorAsset(name: "AutofillDemoAccessoryViewBackground")
  internal static let dwmBreachDetailMessageBody = ColorAsset(name: "DWMBreachDetailMessageBody")
  internal static let dwmDashGreen01 = ColorAsset(name: "DWMDashGreen01")
  internal static let dwmMainBackground = ColorAsset(name: "DWMMainBackground")
  internal static let dwmOnboardingLoadingAnimationFailure = ColorAsset(name: "DWMOnboardingLoadingAnimationFailure")
  internal static let dwmOnboardingLoadingAnimationNeutral = ColorAsset(name: "DWMOnboardingLoadingAnimationNeutral")
  internal static let guidedOnboardingSecondaryAction = ColorAsset(name: "GuidedOnboardingSecondaryAction")
  internal static let guidedOnboardingSecondaryText = ColorAsset(name: "GuidedOnboardingSecondaryText")
  internal static let mainGreen = ColorAsset(name: "MainGreen")
  internal static let pageControl = ColorAsset(name: "PageControl")
  internal static let pageControlSelected = ColorAsset(name: "PageControlSelected")
  internal static let listBackground = ColorAsset(name: "listBackground")
  internal static let secondaryText = ColorAsset(name: "SecondaryText")
  internal static let tableViewCellUnread = ColorAsset(name: "tableViewCellUnread")
  internal static let navigationBarBackground = ColorAsset(name: "NavigationBarBackground")
  internal static let searchBarBackgroundInactive = ColorAsset(name: "SearchBarBackgroundInactive")
  internal static let separator = ColorAsset(name: "Separator")
  internal static let dashGreenCopy = ColorAsset(name: "DashGreenCopy")
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
  internal static let key = ImageAsset(name: "key")
  internal static let dwmAlert = ImageAsset(name: "dwmAlert")
  internal static let dwmExpert = ImageAsset(name: "dwmExpert")
  internal static let dwmMonitor = ImageAsset(name: "dwmMonitor")
  internal static let actionItemDiamond = ImageAsset(name: "actionItemDiamond")
  internal static let emptyRecent = ImageAsset(name: "empty-recent")
  internal static let emptySearch = ImageAsset(name: "empty-search")
  internal static let safariDisabled = ImageAsset(name: "safari_disabled")
  internal static let chromeImport = ImageAsset(name: "chrome-import")
  internal static let chromeInstructions = ImageAsset(name: "chrome-instructions")
  internal static let m2wConnect = ImageAsset(name: "m2w_connect")
  internal static let guidedOnboardingLogoMark = ImageAsset(name: "guided_onboarding_logo_mark")
  internal static let importMethodChrome = ImageAsset(name: "import-method-chrome")
  internal static let importMethodDash = ImageAsset(name: "import-method-dash")
  internal static let importMethodSafari = ImageAsset(name: "import-method-safari")
  internal static let multidevices = ImageAsset(name: "multidevices")
  internal static let contactsBlue = ColorAsset(name: "contactsBlue")
  internal static let contactsOrange = ColorAsset(name: "contactsOrange")
  internal static let contactsPurple = ColorAsset(name: "contactsPurple")
  internal static let contactsTurquoise = ColorAsset(name: "contactsTurquoise")
  internal static let contactsViolet = ColorAsset(name: "contactsViolet")
  internal static let contactsYellow = ColorAsset(name: "contactsYellow")
  internal static let emptySharing = ImageAsset(name: "empty-sharing")
  internal static let userGroup = ImageAsset(name: "user-group")
  internal static let pictoAuthenticator = ImageAsset(name: "pictoAuthenticator")
  internal static let securityBreachDataleak = ImageAsset(name: "security_breach_dataleak")
  internal static let securityBreachRegular = ImageAsset(name: "security_breach_regular")
  internal static let qrScanFrame = ImageAsset(name: "qr-scan-frame")
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
