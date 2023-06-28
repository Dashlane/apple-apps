#if canImport(UIKit)
import UIDelight

extension UIDelight.NavigationBarStyle {
    public static var `table`: UIDelight.NavigationBarStyle {
        return .init(tintColor: .label, backgroundColor: .ds.background.alternate)
    }
}
#endif
