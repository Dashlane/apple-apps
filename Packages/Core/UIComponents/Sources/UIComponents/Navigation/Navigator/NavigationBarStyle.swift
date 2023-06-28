#if canImport(UIKit)
import DesignSystem
import Foundation
import UIKit
import SwiftTreats

public enum NavigationBarStyle {
    case `default`(largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never)
    case transparent(tintColor: UIColor = .ds.text.neutral.standard,
                     statusBarStyle: UIStatusBarStyle = .default)
    case hidden(statusBarStyle: UIStatusBarStyle = .default)
    case custom(appearance: UINavigationBarAppearance,
                largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never,
                tintColor: UIColor = .ds.text.neutral.standard,
                statusBarStyle: UIStatusBarStyle = .default)
}

public extension NavigationBarStyle {
    static var transparent: NavigationBarStyle {
        return .transparent()
    }
}

public extension NavigationBarStyle {
    var shouldHide: Bool {
        switch self {
            case .hidden:
                return true
            default:
                return false
        }
    }

    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
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

public extension UIStatusBarStyle {

        init(navigationBarStyle: NavigationBarStyle) {
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

public extension UINavigationBar {
        func applyStyle(_ style: NavigationBarStyle) {
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

    private func applyCustom(appearance: UINavigationBarAppearance,
                             tintColor: UIColor) {
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
        tintColor = .ds.text.neutral.standard
        prefersLargeTitles = true
    }
}

public extension UINavigationBarAppearance {
    static var transparent: UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        return appearance
    }

    static var `default`: UINavigationBarAppearance {
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

public extension NavigationBarStyle {
    static var homeBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        if Device.isIpadOrMac {
            appearance.backgroundColor = .ds.background.default
        } else {
            appearance.backgroundColor = .ds.background.default
        }

        return .custom(appearance: appearance,
                       largeTitleMode: .always,
                       tintColor: .ds.text.neutral.standard,
                       statusBarStyle: .default)
    }
}

public protocol NavigationBarStyleProvider {
    var navigationBarStyle: NavigationBarStyle { get }
}
#endif
