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

internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let safariDisabled = ImageAsset(name: "safari_disabled")
  internal static let shushDisable = ImageAsset(name: "shush_disable")
  internal static let shushInfo = ImageAsset(name: "shush_info")
  internal static let buttonBackground = ColorAsset(name: "ButtonBackground")
  internal static let dashGreenCopy = ColorAsset(name: "DashGreenCopy")
  internal static let mainBackground = ColorAsset(name: "MainBackground")
  internal static let midGreen = ColorAsset(name: "MidGreen")
  internal static let nonSelectedTab = ColorAsset(name: "NonSelectedTab")
  internal static let otherTabsButton = ColorAsset(name: "OtherTabsButton")
  internal static let primaryHighlight = ColorAsset(name: "Primary-highlight")
  internal static let secondaryHighlight = ColorAsset(name: "Secondary-highlight")
  internal static let secondaryText = ColorAsset(name: "SecondaryText")
  internal static let separation = ColorAsset(name: "Separation")
  internal static let tooltipBackground = ColorAsset(name: "TooltipBackground")
  internal static let dashlaneColorTealBackground = ColorAsset(name: "dashlaneColorTealBackground")
  internal static let green = ColorAsset(name: "green")
  internal static let iconPlaceholderBackground = ColorAsset(name: "iconPlaceholderBackground")
  internal static let infobox = ColorAsset(name: "infobox")
  internal static let infoboxText = ColorAsset(name: "infoboxText")
  internal static let primaryInverted = ColorAsset(name: "primary-inverted")
  internal static let selection = ColorAsset(name: "selection")
  internal static let search = ImageAsset(name: "Search")
  internal static let copyInfo = ImageAsset(name: "copyInfo")
  internal static let goToWebsite = ImageAsset(name: "goToWebsite")
  internal static let searchNoResult = ImageAsset(name: "searchNoResult")
  internal static let sensitiveHide = ImageAsset(name: "sensitiveHide")
  internal static let sensitiveReveal = ImageAsset(name: "sensitiveReveal")
  internal static let emptyImage = ImageAsset(name: "EmptyImage")
  internal static let back = ImageAsset(name: "back")
  internal static let edit = ImageAsset(name: "edit")
  internal static let computerLogo = ImageAsset(name: "computerLogo")
  internal static let helpLogo = ImageAsset(name: "helpLogo")
  internal static let logomark = ImageAsset(name: "Logomark")
  internal static let tabAutofill = ImageAsset(name: "tab-autofill")
  internal static let tabPasswordGenerator = ImageAsset(name: "tab-password-generator")
  internal static let tabSelectedIndicator = ImageAsset(name: "tab-selected-indicator")
  internal static let tabSeparator = ImageAsset(name: "tab-separator")
  internal static let tabSettings = ImageAsset(name: "tab-settings")
  internal static let tabVault = ImageAsset(name: "tab-vault")
  internal static let historyLarge = ImageAsset(name: "historyLarge")
  internal static let infoboxIcon = ImageAsset(name: "infoboxIcon")
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
