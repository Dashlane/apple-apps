#if os(iOS)
import Foundation
import UIDelight
import UIKit
import DesignSystem


public extension NavigationBarStyle {
    static var alternate: NavigationBarStyle {
        return .init(tintColor: .ds.text.neutral.catchy,
                     backgroundColor: .ds.background.alternate)
    }
}
#endif
