#if canImport(UIKit)

  import Foundation
  import SwiftUI

  public struct NavigationBarStyle: Equatable {
    let tintColor: UIColor?
    let standardAppearance: UINavigationBarAppearance
    let compactAppearance: UINavigationBarAppearance?
    let scrollEdgeAppearance: UINavigationBarAppearance?

    init(
      tintColor: UIColor?,
      standardAppearance: UINavigationBarAppearance,
      compactAppearance: UINavigationBarAppearance?,
      scrollEdgeAppearance: UINavigationBarAppearance?
    ) {
      self.tintColor = tintColor
      self.standardAppearance = standardAppearance
      self.compactAppearance = compactAppearance
      self.scrollEdgeAppearance = scrollEdgeAppearance
    }

    public init(tintColor: UIColor, backgroundColor: UIColor) {
      let appearance = UINavigationBarAppearance.default
      appearance.backgroundColor = backgroundColor
      appearance.titleTextAttributes = [.foregroundColor: tintColor]
      appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]

      self.init(
        tintColor: tintColor,
        standardAppearance: appearance,
        compactAppearance: appearance,
        scrollEdgeAppearance: appearance)
    }
  }

  extension NavigationBarStyle {
    public static var transparent: NavigationBarStyle {
      return .transparent(tintColor: nil, titleColor: nil)
    }

    public static func transparent(tintColor: UIColor?, titleColor: UIColor?) -> NavigationBarStyle
    {
      let appearance = UINavigationBarAppearance.transparent
      if let titleColor = titleColor {
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
      }

      return .init(
        tintColor: tintColor,
        standardAppearance: appearance,
        compactAppearance: appearance,
        scrollEdgeAppearance: appearance)
    }

    public static var `default`: NavigationBarStyle {
      let appearance = UINavigationBarAppearance.default
      return .init(
        tintColor: nil,
        standardAppearance: appearance,
        compactAppearance: appearance,
        scrollEdgeAppearance: appearance)
    }

    public static var purpleWhyNot: NavigationBarStyle {
      return .init(tintColor: .white, backgroundColor: .purple)
    }

    public static var yellowWhyNot: NavigationBarStyle {
      return .init(tintColor: .label, backgroundColor: .yellow)
    }

    public static var greenWhyNot: NavigationBarStyle {
      return .init(tintColor: .label, backgroundColor: .green)
    }
  }

  extension UINavigationBarAppearance {
    static var transparent: UINavigationBarAppearance {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      return appearance
    }

    static var `default`: UINavigationBarAppearance {
      let appearance = UINavigationBarAppearance()
      appearance.shadowColor = .clear

      return appearance
    }
  }

  extension NavigationBarStyle {
    public static func customLargeFontStyle(
      _ largeFont: UIFont,
      titleColor: UIColor,
      backgroundColor: UIColor
    ) -> NavigationBarStyle {
      let appearance = UINavigationBarAppearance.default
      appearance.backgroundColor = backgroundColor
      appearance.titleTextAttributes = [
        .foregroundColor: titleColor
      ]
      appearance.largeTitleTextAttributes = [
        .foregroundColor: titleColor,
        .font: largeFont,
      ]
      return .init(
        tintColor: nil,
        standardAppearance: appearance,
        compactAppearance: appearance,
        scrollEdgeAppearance: appearance)
    }

  }

  extension UINavigationBar {
    private static let defaultTintColor = UINavigationBar.appearance().tintColor

    var currentStyle: NavigationBarStyle {
      return NavigationBarStyle(
        tintColor: tintColor ?? nil,
        standardAppearance: standardAppearance,
        compactAppearance: compactAppearance.map { .init(barAppearance: $0) },
        scrollEdgeAppearance: scrollEdgeAppearance.map { .init(barAppearance: $0) })
    }

    func apply(_ style: NavigationBarStyle) {
      standardAppearance = style.standardAppearance
      compactAppearance = style.compactAppearance
      scrollEdgeAppearance = style.scrollEdgeAppearance

      if let tintColor = style.tintColor {
        self.tintColor = tintColor
      } else {
        tintColor = Self.defaultTintColor
      }
    }
  }
#endif
