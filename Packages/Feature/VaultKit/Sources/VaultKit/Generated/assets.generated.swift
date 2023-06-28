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
  internal static let pride1 = ColorAsset(name: "Pride1")
  internal static let pride2 = ColorAsset(name: "Pride2")
  internal static let pride3 = ColorAsset(name: "Pride3")
  internal static let pride4 = ColorAsset(name: "Pride4")
  internal static let pride5 = ColorAsset(name: "Pride5")
  internal static let pride6 = ColorAsset(name: "Pride6")
  internal static let pride7 = ColorAsset(name: "Pride7")
  internal static let pride8 = ColorAsset(name: "Pride8")
  internal static let amex = ImageAsset(name: "amex")
  internal static let dinersclub = ImageAsset(name: "dinersclub")
  internal static let discover = ImageAsset(name: "discover")
  internal static let jcb = ImageAsset(name: "jcb")
  internal static let mastercard = ImageAsset(name: "mastercard")
  internal static let visa = ImageAsset(name: "visa")
  internal static let creditCardBlue = ColorAsset(name: "CreditCardBlue")
  internal static let creditCardDarkBlue = ColorAsset(name: "CreditCardDarkBlue")
  internal static let creditCardDarkGreen = ColorAsset(name: "CreditCardDarkGreen")
  internal static let creditCardGold = ColorAsset(name: "CreditCardGold")
  internal static let creditCardGreen = ColorAsset(name: "CreditCardGreen")
  internal static let creditCardOrange = ColorAsset(name: "CreditCardOrange")
  internal static let creditCardRed = ColorAsset(name: "CreditCardRed")
  internal static let creditCardSilver = ColorAsset(name: "CreditCardSilver")
  internal static let drivingLicenceCalifornia = ColorAsset(name: "DrivingLicenceCalifornia")
  internal static let drivingLicenceNewYork = ColorAsset(name: "DrivingLicenceNewYork")
  internal static let drivingLicenceRestOfTheWorld = ColorAsset(name: "DrivingLicenceRestOfTheWorld")
  internal static let tax = ImageAsset(name: "Tax")
  internal static let identityItemBackground = ColorAsset(name: "identityItemBackground")
  internal static let idCardFR = ColorAsset(name: "idCardFR")
  internal static let iconSelection = ImageAsset(name: "IconSelection")
  internal static let attachmentClip = ImageAsset(name: "Attachment_clip")
  internal static let attachmentClipDownloaded = ImageAsset(name: "Attachment_clip_downloaded")
  internal static let bankAccountThumb = ImageAsset(name: "BankAccountThumb")
  internal static let driverThumb = ImageAsset(name: "DriverThumb")
  internal static let idThumb = ImageAsset(name: "IDThumb")
  internal static let passportThumb = ImageAsset(name: "PassportThumb")
  internal static let imgAddress = ImageAsset(name: "img-address")
  internal static let imgCard = ImageAsset(name: "img-card")
  internal static let imgNoteLocked = ImageAsset(name: "img-note-locked")
  internal static let passportBurgundy = ColorAsset(name: "PassportBurgundy")
  internal static let passportGreen = ColorAsset(name: "PassportGreen")
  internal static let passportNavy = ColorAsset(name: "PassportNavy")
  internal static let passportRed = ColorAsset(name: "PassportRed")
  internal static let secureNoteBlue = ColorAsset(name: "SecureNoteBlue")
  internal static let secureNoteBrown = ColorAsset(name: "SecureNoteBrown")
  internal static let secureNoteGray = ColorAsset(name: "SecureNoteGray")
  internal static let secureNoteGreen = ColorAsset(name: "SecureNoteGreen")
  internal static let secureNoteOrange = ColorAsset(name: "SecureNoteOrange")
  internal static let secureNotePink = ColorAsset(name: "SecureNotePink")
  internal static let secureNotePurple = ColorAsset(name: "SecureNotePurple")
  internal static let secureNoteRed = ColorAsset(name: "SecureNoteRed")
  internal static let secureNoteYellow = ColorAsset(name: "SecureNoteYellow")
  internal static let socialSecurityInformationFR = ColorAsset(name: "SocialSecurityInformationFR")
  internal static let socialSecurityInformationGB = ColorAsset(name: "SocialSecurityInformationGB")
  internal static let socialSecurityInformationUS = ColorAsset(name: "SocialSecurityInformationUS")
  internal static let iconPlaceholderBackground = ColorAsset(name: "iconPlaceholderBackground")
  internal static let logomark = ImageAsset(name: "Logomark")
  internal static let history = ImageAsset(name: "history")
  internal static let allSpaces = ImageAsset(name: "all_spaces")
  internal static let personalSpaceIconColor = ColorAsset(name: "personalSpaceIconColor")
  internal static let teamSpace = ImageAsset(name: "team_space")
  internal static let teamSpaceLarge = ImageAsset(name: "team_space_large")
  internal static let teamSpaceOutline = ImageAsset(name: "team_space_outline")
  internal static let teamSpaceOutlineLarge = ImageAsset(name: "team_space_outline_large")
  internal static let teamSpaceOutlineSmall = ImageAsset(name: "team_space_outline_small")
  internal static let teamSpaceSmall = ImageAsset(name: "team_space_small")
  internal static let tableBackground = ColorAsset(name: "TableBackground")
  internal static let addButton = ImageAsset(name: "addButton")
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
