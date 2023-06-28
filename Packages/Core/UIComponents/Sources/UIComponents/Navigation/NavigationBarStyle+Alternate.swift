#if os(iOS)
import Foundation
import UIDelight
import UIKit
import DesignSystem

extension UIDelight.NavigationBarStyle {
    public static var alternate: UIDelight.NavigationBarStyle {
        return .init(tintColor: .ds.text.neutral.catchy, backgroundColor: .ds.background.alternate)
    }
}
#endif
