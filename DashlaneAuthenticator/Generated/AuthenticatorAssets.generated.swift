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

internal enum AuthenticatorAsset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let authLogomark = ImageAsset(name: "Auth_Logomark")
  internal static let buttonBackgroundIncreasedContrast = ColorAsset(name: "ButtonBackgroundIncreasedContrast")
  internal static let buttonText = ColorAsset(name: "ButtonText")
  internal static let buttonTextIncreasedContrast = ColorAsset(name: "ButtonTextIncreasedContrast")
  internal static let codeSectionBackground = ColorAsset(name: "CodeSectionBackground")
  internal static let dashGreen = ColorAsset(name: "DashGreen")
  internal static let dashGreenCopy = ColorAsset(name: "DashGreenCopy")
  internal static let fieldBackground = ColorAsset(name: "FieldBackground")
  internal static let mainBackground = ColorAsset(name: "MainBackground")
  internal static let midGreen = ColorAsset(name: "MidGreen")
  internal static let navigationBarBackground = ColorAsset(name: "NavigationBarBackground")
  internal static let navigationBarBackgroundIpad = ColorAsset(name: "NavigationBarBackgroundIpad")
  internal static let placeholder = ColorAsset(name: "Placeholder")
  internal static let secondaryText = ColorAsset(name: "SecondaryText")
  internal static let systemBackground = ColorAsset(name: "SystemBackground")
  internal static let iconPlaceholderBackground = ColorAsset(name: "iconPlaceholderBackground")
  internal static let oddityBrand = ColorAsset(name: "oddityBrand")
  internal static let systemGray = ColorAsset(name: "systemGray")
  internal static let logomark = ImageAsset(name: "Logomark")
  internal static let addTokenIntro = ImageAsset(name: "add_token_intro")
  internal static let addTokenMethod = ImageAsset(name: "add_token_method")
  internal static let arrow = ImageAsset(name: "arrow")
  internal static let authenticator = ImageAsset(name: "authenticator")
  internal static let close = ImageAsset(name: "close")
  internal static let copyIcon = ImageAsset(name: "copy-icon")
  internal static let cross = ImageAsset(name: "cross")
  internal static let editPen = ImageAsset(name: "edit-pen")
  internal static let editBubble = ImageAsset(name: "editBubble")
  internal static let error = ImageAsset(name: "error")
  internal static let faceId = ImageAsset(name: "faceId")
  internal static let feedbackHelp = ImageAsset(name: "feedback–help")
  internal static let fingerprint = ImageAsset(name: "fingerprint")
  internal static let generateHotp = ImageAsset(name: "generateHotp")
  internal static let help = ImageAsset(name: "help")
  internal static let infoButton = ImageAsset(name: "infoButton")
  internal static let introIllustration = ImageAsset(name: "intro_illustration")
  internal static let lock = ImageAsset(name: "lock")
  internal static let logoLockUp = ImageAsset(name: "logo-lock-up")
  internal static let onboardingIllustration = ImageAsset(name: "onboarding_illustration")
  internal static let onboardingLogo = ImageAsset(name: "onboarding_logo")
  internal static let onboardingPage2 = ImageAsset(name: "onboarding_page2")
  internal static let onboardingPage3 = ImageAsset(name: "onboarding_page3")
  internal static let onboardingStep1 = ImageAsset(name: "onboarding_step1")
  internal static let onboardingStep2 = ImageAsset(name: "onboarding_step2")
  internal static let onboardingStep3 = ImageAsset(name: "onboarding_step3")
  internal static let pushIllustration = ImageAsset(name: "push_illustration")
  internal static let qrScanFrame = ImageAsset(name: "qr-scan-frame")
  internal static let shield = ImageAsset(name: "shield")
  internal static let successCheckmark = ImageAsset(name: "success-checkmark")
  internal static let tick = ImageAsset(name: "tick")
  internal static let tokenHelp = ImageAsset(name: "tokenHelp")
  internal static let trashDelete = ImageAsset(name: "trash-delete")
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
