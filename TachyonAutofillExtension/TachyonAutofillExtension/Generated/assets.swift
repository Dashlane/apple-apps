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
  internal static let buttonText = ColorAsset(name: "ButtonText")
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let appBackground = ColorAsset(name: "AppBackground")
  internal static let buttonBackgroundIncreasedContrast = ColorAsset(name: "ButtonBackgroundIncreasedContrast")
  internal static let buttonTextIncreasedContrast = ColorAsset(name: "ButtonTextIncreasedContrast")
  internal static let cellBackground = ColorAsset(name: "CellBackground")
  internal static let dashGreen = ColorAsset(name: "DashGreen")
  internal static let dashGreenCopy = ColorAsset(name: "DashGreenCopy")
  internal static let defaultButtonColor = ColorAsset(name: "DefaultButtonColor")
  internal static let errorRed = ColorAsset(name: "ErrorRed")
  internal static let grey01 = ColorAsset(name: "Grey01")
  internal static let mainBackground = ColorAsset(name: "MainBackground")
  internal static let mainCopy = ColorAsset(name: "MainCopy")
  internal static let midGreen = ColorAsset(name: "MidGreen")
  internal static let navigationBarBackground = ColorAsset(name: "NavigationBarBackground")
  internal static let navigationBarBackgroundIpad = ColorAsset(name: "NavigationBarBackgroundIpad")
  internal static let neutralBackground = ColorAsset(name: "NeutralBackground")
  internal static let neutralText = ColorAsset(name: "NeutralText")
  internal static let passwordGeneratorRefreshButtonColor = ColorAsset(name: "PasswordGeneratorRefreshButtonColor")
  internal static let passwordNormalText = ColorAsset(name: "PasswordNormalText")
  internal static let passwordNumberText = ColorAsset(name: "PasswordNumberText")
  internal static let passwordSpecialText = ColorAsset(name: "PasswordSpecialText")
  internal static let pride1 = ColorAsset(name: "Pride1")
  internal static let pride2 = ColorAsset(name: "Pride2")
  internal static let pride3 = ColorAsset(name: "Pride3")
  internal static let pride4 = ColorAsset(name: "Pride4")
  internal static let pride5 = ColorAsset(name: "Pride5")
  internal static let pride6 = ColorAsset(name: "Pride6")
  internal static let pride7 = ColorAsset(name: "Pride7")
  internal static let pride8 = ColorAsset(name: "Pride8")
  internal static let switchDefaultTint = ColorAsset(name: "SwitchDefaultTint")
  internal static let systemBackground = ColorAsset(name: "SystemBackground")
  internal static let tableBackground = ColorAsset(name: "TableBackground")
  internal static let validatorGreen = ColorAsset(name: "ValidatorGreen")
  internal static let yellow = ColorAsset(name: "Yellow")
  internal static let iconPlaceholderBackground = ColorAsset(name: "iconPlaceholderBackground")
  internal static let tachyonBackground = ColorAsset(name: "tachyonBackground")
  internal static let tachyonMineShaft = ColorAsset(name: "tachyonMineShaft")
  internal static let tachyonSecondaryTitle = ColorAsset(name: "tachyonSecondaryTitle")
  internal static let tachyonSettingsBackground = ColorAsset(name: "tachyonSettingsBackground")
  internal static let emptyConfidentialCards = ImageAsset(name: "empty-confidential-cards")
  internal static let emptyNotes = ImageAsset(name: "empty-notes")
  internal static let emptyPasswords = ImageAsset(name: "empty-passwords")
  internal static let emptyPayments = ImageAsset(name: "empty-payments")
  internal static let emptyPersonalInfo = ImageAsset(name: "empty-personal-info")
  internal static let emptyRecent = ImageAsset(name: "empty-recent")
  internal static let emptySearch = ImageAsset(name: "empty-search")
  internal static let fieldBackground = ColorAsset(name: "FieldBackground")
  internal static let logomark = ImageAsset(name: "Logomark")
  internal static let menuIconConfidentialcards = ImageAsset(name: "menu-icon-confidentialcards")
  internal static let menuIconNotes = ImageAsset(name: "menu-icon-notes")
  internal static let menuIconPasswords = ImageAsset(name: "menu-icon-passwords")
  internal static let menuIconPaymentmeans = ImageAsset(name: "menu-icon-paymentmeans")
  internal static let menuIconPersonalinfos = ImageAsset(name: "menu-icon-personalinfos")
  internal static let sharingPaywall = ImageAsset(name: "SharingPaywall")
  internal static let paywallVpn = ImageAsset(name: "paywall_vpn")
  internal static let placeholder = ColorAsset(name: "Placeholder")
  internal static let searchBarBackgroundInactive = ColorAsset(name: "SearchBarBackgroundInactive")
  internal static let searchbarBackground = ColorAsset(name: "SearchbarBackground")
  internal static let searchbarBackgroundActive = ColorAsset(name: "SearchbarBackgroundActive")
  internal static let secondaryText = ColorAsset(name: "SecondaryText")
  internal static let add = ImageAsset(name: "add")
  internal static let addNewPassword = ImageAsset(name: "addNewPassword")
  internal static let checkmark = ImageAsset(name: "checkmark")
  internal static let configurationMacos = ImageAsset(name: "configuration-macos")
  internal static let dashlaneIcon = ImageAsset(name: "dashlaneIcon")
  internal static let detailDisclosureButton = ImageAsset(name: "detail-disclosure-button")
  internal static let history = ImageAsset(name: "history")
  internal static let keyIcon = ImageAsset(name: "keyIcon")
  internal static let passwordMissingImage = ImageAsset(name: "password-missing-image")
  internal static let paywallIconShield = ImageAsset(name: "paywall_icon_shield")
  internal static let revealButton = ImageAsset(name: "revealButton")
  internal static let revealButtonSelected = ImageAsset(name: "revealButtonSelected")
  internal static let success = ImageAsset(name: "success")
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
