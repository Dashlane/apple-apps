#if canImport(UIKit)
  import DesignSystem
  import Foundation
  import UIKit
  import SwiftTreats

  public enum NavigationBarStyle {
    case `default`(largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never)
    case transparent(
      tintColor: UIColor = .ds.text.neutral.standard,
      statusBarStyle: UIStatusBarStyle = .default)
    case hidden(statusBarStyle: UIStatusBarStyle = .default)
    case custom(
      appearance: UINavigationBarAppearance,
      largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never,
      tintColor: UIColor = .ds.text.neutral.standard,
      statusBarStyle: UIStatusBarStyle = .default)
  }

  extension NavigationBarStyle {
    public static var transparent: NavigationBarStyle {
      return .transparent()
    }
  }

  extension NavigationBarStyle {
    public var shouldHide: Bool {
      switch self {
      case .hidden:
        return true
      default:
        return false
      }
    }

    public var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
      switch self {
      case let .default(largeTitleMode):
        return largeTitleMode
      case let .custom(_, largeTitleMode, _, _):
        return largeTitleMode
      default:
        return .never
      }
    }
  }

  extension UIStatusBarStyle {

    public init(navigationBarStyle: NavigationBarStyle) {
      switch navigationBarStyle {
      case let .custom(_, _, _, statusBarStyle):
        self = statusBarStyle
      case .default:
        self = .default
      case let .transparent(_, statusBarStyle):
        self = statusBarStyle
      case let .hidden(statusBarStyle):
        self = statusBarStyle

      }
    }
  }

  extension UINavigationBar {
    public func applyStyle(_ style: NavigationBarStyle) {
      switch style {
      case .default:
        applyDefaultStyle()
      case let .custom(appearance, _, tintColor, _):
        applyCustom(appearance: appearance, tintColor: tintColor)
      case .hidden: break
      case .transparent(let tintColor, _):
        applyTransparentBackgroundStyle(tintColor: tintColor)
      }
    }

    private func applyCustom(
      appearance: UINavigationBarAppearance,
      tintColor: UIColor
    ) {
      standardAppearance = appearance
      compactAppearance = appearance
      scrollEdgeAppearance = appearance
      self.tintColor = tintColor
      self.prefersLargeTitles = true
    }

    private func applyTransparentBackgroundStyle(tintColor: UIColor) {
      let appearance = UINavigationBarAppearance.transparent
      self.prefersLargeTitles = true
      self.tintColor = tintColor

      setBackgroundImage(UIImage(), for: .default)

      standardAppearance = appearance
      compactAppearance = appearance
      scrollEdgeAppearance = appearance
    }

    private func applyDefaultStyle() {
      let appearance = UINavigationBarAppearance()
      appearance.shadowColor = .clear
      appearance.backgroundColor = .ds.background.default
      standardAppearance = appearance
      compactAppearance = appearance
      scrollEdgeAppearance = appearance
      tintColor = .ds.text.brand.standard
      prefersLargeTitles = true
    }
  }

  extension UINavigationBarAppearance {
    public static var transparent: UINavigationBarAppearance {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      return appearance
    }

    public static var `default`: UINavigationBarAppearance {
      let appearance = UINavigationBarAppearance()
      appearance.shadowColor = .clear

      if Device.isIpadOrMac {
        appearance.backgroundColor = .ds.background.default
      } else {
        appearance.backgroundColor = .ds.border.brand.quiet.idle
      }
      return appearance
    }

  }

  public protocol NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle { get }
  }
#endif
