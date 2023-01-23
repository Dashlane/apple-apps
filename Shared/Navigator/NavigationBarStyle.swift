import Foundation
import UIKit
import SwiftTreats
import DashlaneAppKit

enum NavigationBarStyle {
    case `default`(largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never)
    case transparent(tintColor: UIColor = .ds.text.neutral.standard,
                     statusBarStyle: UIStatusBarStyle = .default)
    case hidden(statusBarStyle: UIStatusBarStyle = .default)
    case custom(appearance: UINavigationBarAppearance,
                largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .never,
                tintColor: UIColor = .ds.text.neutral.standard,
                statusBarStyle: UIStatusBarStyle = .default)
}

extension NavigationBarStyle {
    static var transparent: NavigationBarStyle {
        return .transparent()
    }
}

extension NavigationBarStyle {
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

extension UIStatusBarStyle {

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

extension UINavigationBar {
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
        if Device.isIpadOrMac {
            appearance.backgroundColor = FiberAsset.navigationBarBackgroundIpad.color
        } else {
            appearance.backgroundColor = FiberAsset.appBackground.color
        }
        standardAppearance = appearance
        compactAppearance = appearance
        scrollEdgeAppearance = appearance
        tintColor = .ds.text.neutral.standard
        prefersLargeTitles = true
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

        if Device.isIpadOrMac {
            appearance.backgroundColor = FiberAsset.navigationBarBackgroundIpad.color
        } else {
            appearance.backgroundColor = FiberAsset.navigationBarBackground.color
        }
        return appearance
    }
    
}


extension NavigationBarStyle {
    static var homeBarStyle: NavigationBarStyle {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        if Device.isIpadOrMac {
            appearance.backgroundColor = FiberAsset.navigationBarBackgroundIpad.color
        } else {
            appearance.backgroundColor = FiberAsset.systemBackground.color
        }

        return .custom(appearance: appearance,
                       largeTitleMode: .always,
                       tintColor: .ds.text.neutral.standard,
                       statusBarStyle: .default)
    }
}
