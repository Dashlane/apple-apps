import Foundation
import SwiftUI

public enum GTWalsheimPro: String {
  case medium = "GTWalsheimPro-Medium"
  case bold = "GTWalsheimPro-Bold"
  case regular = "GTWalsheimPro-Regular"

  public var name: String {
    return self.rawValue
  }
}

public enum DashlaneFont {
  public enum Weight {
    case bold
    case regular
    case medium
  }

  case custom(CGFloat, Weight)
  case `default`(CGFloat)

  public var uiFont: UIFont {
    switch self {
    case .custom(let size, let weight):
      let fontName: String = {
        switch weight {
        case .bold:
          return GTWalsheimPro.bold.rawValue
        case .regular:
          return GTWalsheimPro.regular.rawValue
        default:
          return GTWalsheimPro.medium.rawValue
        }
      }()
      return UIFont.init(name: fontName, size: size)!
    case .default(let size):
      return UIFont.systemFont(ofSize: size, weight: .medium)
    }
  }

  public enum Title {
    case custom(CGFloat, UIFont.Weight)
    case `default`(CGFloat)

    public func font() -> UIFont {
      switch self {
      case .custom(let size, let weight):
        let fontName: String = {
          switch weight {
          case .bold:
            return GTWalsheimPro.bold.rawValue
          case .regular:
            return GTWalsheimPro.regular.rawValue
          default:
            return GTWalsheimPro.medium.rawValue
          }
        }()
        return UIFont.init(name: fontName, size: size)!
      case .default(let size):
        return UIFont.systemFont(ofSize: size, weight: .medium)
      }
    }
  }

  #if DEBUG
    public static func debugHelper() {
      UIFont.familyNames.forEach({ familyName in
        let fontNames = UIFont.fontNames(forFamilyName: familyName)
        print(familyName, fontNames)
      })
    }
  #endif

  public var font: Font {
    switch self {
    case .custom(let size, let weight):
      let fontName: String = {
        switch weight {
        case .bold:
          return GTWalsheimPro.bold.rawValue
        case .regular:
          return GTWalsheimPro.regular.rawValue
        default:
          return GTWalsheimPro.medium.rawValue
        }
      }()
      return Font.custom(fontName, size: size)
    case .default(let size):
      return Font.system(size: size, weight: .medium)
    }
  }
}
